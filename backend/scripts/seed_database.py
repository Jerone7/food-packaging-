import os
import re
import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# Import Base and models
import sys
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.db.session import Base
from app.models.packaging import PackagingRecommendation
from app.models.food_and_packaging import (
    Source,
    Food,
    RespirationData,
    PackagingMaterial,
    GasProperty,
    IFCTFoodComposition
)
from app.core.config import settings

sync_db_url = settings.DATABASE_URL.replace("postgresql+asyncpg://", "postgresql+psycopg2://")

def get_or_create_source(session, name, doi_or_url=None, notes=None):
    if not name or pd.isna(name):
        name = "Unspecified Source"
    name = str(name).strip()
    src = session.query(Source).filter_by(name=name).first()
    if not src:
        src = Source(
            name=name,
            doi_or_url=str(doi_or_url) if doi_or_url and pd.notna(doi_or_url) else None,
            notes=str(notes) if notes and pd.notna(notes) else None
        )
        session.add(src)
        session.flush()
    return src.id

def seed():
    print(f"Connecting to database: {sync_db_url} ...")
    try:
        engine = create_engine(sync_db_url, echo=False)
        Base.metadata.create_all(bind=engine)
        print("All PostgreSQL tables created/verified successfully.")
    except Exception as e:
        print(f"Error connecting to PostgreSQL ({e}).")
        print("Please ensure PostgreSQL is running (e.g. `docker compose up -d`).")
        return

    Session = sessionmaker(bind=engine)
    session = Session()

    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    data_dir = os.path.join(base_dir, "data")
    node_modules_ifct = os.path.join(os.path.dirname(base_dir), "node_modules", "@nodef", "ifct2017")

    # Clear existing data in correct FK order
    session.query(GasProperty).delete()
    session.query(PackagingMaterial).delete()
    session.query(RespirationData).delete()
    session.query(Food).delete()
    session.query(Source).delete()
    session.query(IFCTFoodComposition).delete()
    session.commit()

    # 1. Ingest Food Commodities & Respiration Data from Ranges CSV
    ranges_csv = os.path.join(data_dir, "food_commodities_ranges.csv")
    if os.path.exists(ranges_csv):
        df_ranges = pd.read_csv(ranges_csv)
        print(f"Processing {len(df_ranges)} Food Commodity Ranges...")
        for _, row in df_ranges.iterrows():
            source_name = row.get('Source', 'Research Reference')
            source_id = get_or_create_source(session, source_name)

            # Average moisture, fat, ph if range given
            moist_min = float(row['Moisture_Content_Min_Percent']) if pd.notna(row.get('Moisture_Content_Min_Percent')) else None
            moist_max = float(row['Moisture_Content_Max_Percent']) if pd.notna(row.get('Moisture_Content_Max_Percent')) else None
            moisture_avg = (moist_min + moist_max) / 2.0 if (moist_min is not None and moist_max is not None) else moist_min

            fat_min = float(row['Fat_Oil_Content_Min_Percent']) if pd.notna(row.get('Fat_Oil_Content_Min_Percent')) else None
            fat_max = float(row['Fat_Oil_Content_Max_Percent']) if pd.notna(row.get('Fat_Oil_Content_Max_Percent')) else None
            fat_avg = (fat_min + fat_max) / 2.0 if (fat_min is not None and fat_max is not None) else fat_min

            ph_min = float(row['pH_Min']) if pd.notna(row.get('pH_Min')) else None
            ph_max = float(row['pH_Max']) if pd.notna(row.get('pH_Max')) else None
            ph_avg = (ph_min + ph_max) / 2.0 if (ph_min is not None and ph_max is not None) else ph_min

            resp_str = str(row.get('Respiration_Rate', ''))
            respiration_class = "Non-respiring" if "0.0" in resp_str or "non-respiring" in resp_str.lower() else "Low-to-Moderate"

            food_rec = Food(
                name=str(row.get('Commodity_Name', '')),
                category=str(row.get('Sub_Category', row.get('Food_Category', ''))),
                moisture=moisture_avg,
                ph=ph_avg,
                water_activity=None, # Missing in raw data
                fat=fat_avg,
                respiration_class=respiration_class,
                oxygen_sensitivity=str(row.get('Oxygen_Sensitivity', '')),
                moisture_sensitivity=str(row.get('Moisture_Sensitivity', ''))
            )
            session.add(food_rec)
            session.flush()

            # Respiration data table entry
            resp_rec = RespirationData(
                food_id=food_rec.id,
                temperature=None, # Missing in raw data
                o2_consumption=None, # Missing in raw data
                co2_production=resp_str if resp_str else None,
                source_id=source_id
            )
            session.add(resp_rec)

        session.commit()

    # 2. Ingest Food Commodities Profiles
    profiles_csv = os.path.join(data_dir, "food_commodities_profiles.csv")
    if os.path.exists(profiles_csv):
        df_profiles = pd.read_csv(profiles_csv)
        print(f"Processing {len(df_profiles)} Food Commodity Profiles...")
        for _, row in df_profiles.iterrows():
            source_name = row.get('Notes_Source', 'USDA FDC / FAO')
            source_id = get_or_create_source(session, source_name)

            resp_str = str(row.get('Respiration_Rate', ''))
            respiration_class = "Non-respiring" if "non-respiring" in resp_str.lower() or "0.0" in resp_str else "Low"

            food_rec = Food(
                name=str(row.get('Commodity_Name', '')),
                category=str(row.get('Food_Category', '')),
                moisture=float(row['Moisture_Content_Percent']) if pd.notna(row.get('Moisture_Content_Percent')) else None,
                ph=float(row['pH']) if pd.notna(row.get('pH')) else None,
                water_activity=None, # Missing in raw data
                fat=float(row['Fat_Oil_Content_Percent']) if pd.notna(row.get('Fat_Oil_Content_Percent')) else None,
                respiration_class=respiration_class,
                oxygen_sensitivity=str(row.get('Oxygen_Sensitivity', '')),
                moisture_sensitivity=str(row.get('Moisture_Sensitivity', ''))
            )
            session.add(food_rec)
            session.flush()

            resp_rec = RespirationData(
                food_id=food_rec.id,
                temperature=None, # Missing in raw data
                o2_consumption=None, # Missing in raw data
                co2_production=resp_str if resp_str else None,
                source_id=source_id
            )
            session.add(resp_rec)

        session.commit()
        print(f"Successfully populated `foods` and `respiration_data` tables.")

    # 3. Ingest Packaging Materials & Gas Properties
    packaging_csv = os.path.join(data_dir, "packaging_materials.csv")
    if os.path.exists(packaging_csv):
        df_pkg = pd.read_csv(packaging_csv)
        print(f"Processing {len(df_pkg)} Packaging Materials...")
        for _, row in df_pkg.iterrows():
            source_name = row.get('Source', 'Research Reference')
            doi_val = row.get('DOI', '')
            notes_val = row.get('Notes', '')
            source_id = get_or_create_source(session, source_name, doi_or_url=doi_val, notes=notes_val)

            # Structure detection
            thickness_val = str(row.get('Thickness', ''))
            if "PET/Al" in thickness_val:
                structure_val = thickness_val
            elif "reference" in thickness_val:
                structure_val = "Monolayer Film"
            else:
                structure_val = "Polymer Film / Formulation Dependent"

            # Sealability mapped from Scalability and notes
            scalability_val = str(row.get('Scalability', ''))
            sealability_val = "Good / Heat Sealable" if scalability_val == "High" else "Structure-dependent"

            # Mechanical strength
            mech_strength = f"{row.get('Tensile_Strength', '')} ({row.get('Mechanical_Strength', '')})" if pd.notna(row.get('Tensile_Strength')) else str(row.get('Mechanical_Strength', ''))

            mat_rec = PackagingMaterial(
                name=str(row.get('Material', '')),
                polymer=str(row.get('Material_Category', '')),
                structure=structure_val,
                thickness=thickness_val,
                otr=f"{row.get('OTR', '')} {row.get('OTR_Unit', '')}".strip(),
                wvtr=f"{row.get('WVTR', '')} {row.get('WVTR_Unit', '')}".strip(),
                sealability=sealability_val,
                mechanical_strength=mech_strength,
                map_suitable=str(row.get('MAP_Suitability', '')),
                source_id=source_id
            )
            session.add(mat_rec)
            session.flush()

            # Insert Gas Property for Oxygen (O2)
            if pd.notna(row.get('OTR')):
                gas_o2 = GasProperty(
                    material_id=mat_rec.id,
                    gas="O2",
                    value=str(row.get('OTR', '')),
                    unit=str(row.get('OTR_Unit', '')),
                    temperature=str(row.get('OTR_Temperature', '')) if pd.notna(row.get('OTR_Temperature')) else None,
                    humidity=str(row.get('OTR_RH', '')) if pd.notna(row.get('OTR_RH')) else None,
                    source_id=source_id
                )
                session.add(gas_o2)

            # Insert Gas Property for Water Vapor (WVTR)
            if pd.notna(row.get('WVTR')):
                gas_wv = GasProperty(
                    material_id=mat_rec.id,
                    gas="Water Vapor (H2O)",
                    value=str(row.get('WVTR', '')),
                    unit=str(row.get('WVTR_Unit', '')),
                    temperature=str(row.get('WVTR_Temperature', '')) if pd.notna(row.get('WVTR_Temperature')) else None,
                    humidity=str(row.get('WVTR_RH', '')) if pd.notna(row.get('WVTR_RH')) else None,
                    source_id=source_id
                )
                session.add(gas_wv)

        session.commit()
        print(f"Successfully populated `packaging_materials` and `gas_properties` tables.")

    # 4. Ingest IFCT 2017 Dataset
    desc_csv = os.path.join(node_modules_ifct, "descriptions", "index.csv")
    comp_csv = os.path.join(node_modules_ifct, "compositions", "index.csv")
    ener_csv = os.path.join(node_modules_ifct, "energies", "index.csv")

    if os.path.exists(desc_csv):
        print("Ingesting IFCT 2017 compositions...")
        df_desc = pd.read_csv(desc_csv)
        df_comp = pd.read_csv(comp_csv) if os.path.exists(comp_csv) else pd.DataFrame()
        df_ener = pd.read_csv(ener_csv) if os.path.exists(ener_csv) else pd.DataFrame()

        merged = df_desc
        if not df_comp.empty and 'code' in df_comp.columns:
            merged = pd.merge(merged, df_comp, on='code', how='left')
        if not df_ener.empty and 'code' in df_ener.columns:
            merged = pd.merge(merged, df_ener, on='code', how='left')

        for _, row in merged.iterrows():
            rec = IFCTFoodComposition(
                code=str(row.get('code', '')),
                name=str(row.get('name', '')),
                sc_name=str(row.get('scie', '')) if pd.notna(row.get('scie')) else None,
                group_name=str(row.get('grup', '')) if pd.notna(row.get('grup')) else None,
                energy_kcal=float(row['enerc']) if 'enerc' in row and pd.notna(row['enerc']) else None,
                protein_g=float(row['protcnt']) if 'protcnt' in row and pd.notna(row['protcnt']) else None,
                fat_g=float(row['fatce']) if 'fatce' in row and pd.notna(row['fatce']) else None,
                carbohydrate_g=float(row['choavldf']) if 'choavldf' in row and pd.notna(row['choavldf']) else None,
                fiber_g=float(row['fibtg']) if 'fibtg' in row and pd.notna(row['fibtg']) else None,
                water_g=float(row['water']) if 'water' in row and pd.notna(row['water']) else None,
                ash_g=float(row['ash']) if 'ash' in row and pd.notna(row['ash']) else None
            )
            session.add(rec)
        session.commit()
        print(f"Successfully ingested {len(merged)} IFCT 2017 food composition items.")

    session.close()
    print("✨ All database tables structured and seeded successfully!")

if __name__ == "__main__":
    seed()
