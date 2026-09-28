from sqlalchemy import Column, Integer, String, Float, Text, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from app.db.session import Base

class Source(Base):
    __tablename__ = "sources"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False, unique=True, index=True)
    doi_or_url = Column(String(255), nullable=True)
    notes = Column(Text, nullable=True)

    # Relationships
    respiration_records = relationship("RespirationData", back_populates="source")
    packaging_materials = relationship("PackagingMaterial", back_populates="source")
    gas_properties = relationship("GasProperty", back_populates="source")
    scientific_properties = relationship("FoodScientificProperty", back_populates="source")


class Food(Base):
    __tablename__ = "foods"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False, index=True)
    category = Column(String(255), nullable=True, index=True)
    moisture = Column(Float, nullable=True)           # Moisture %
    ph = Column(Float, nullable=True)                 # pH value
    water_activity = Column(Float, nullable=True)     # a_w (Note: not explicitly in raw source, nullable)
    fat = Column(Float, nullable=True)                # Fat/Oil %
    respiration_class = Column(String(100), nullable=True)
    oxygen_sensitivity = Column(String(100), nullable=True)
    moisture_sensitivity = Column(String(100), nullable=True)

    # Relationship
    respiration_data = relationship("RespirationData", back_populates="food", cascade="all, delete-orphan")
    scientific_properties = relationship("FoodScientificProperty", back_populates="food", uselist=False, cascade="all, delete-orphan")


class RespirationData(Base):
    __tablename__ = "respiration_data"

    id = Column(Integer, primary_key=True, index=True)
    food_id = Column(Integer, ForeignKey("foods.id", ondelete="CASCADE"), nullable=False, index=True)
    temperature = Column(String(100), nullable=True)      # e.g. "Ambient / 20-25°C" (Not explicitly specified in raw sources)
    o2_consumption = Column(String(100), nullable=True)   # e.g. mL O2/kg/h (Not in raw sources)
    co2_production = Column(String(100), nullable=True)   # e.g. "2.33 mL CO2/h", "0.0 mL CO2/kg/h"
    source_id = Column(Integer, ForeignKey("sources.id"), nullable=True, index=True)

    # Relationships
    food = relationship("Food", back_populates="respiration_data")
    source = relationship("Source", back_populates="respiration_records")


class PackagingMaterial(Base):
    __tablename__ = "packaging_materials"

    id = Column(Integer, primary_key=True, index=True)
    material_id = Column(String(100), nullable=True, unique=True, index=True) # e.g. "mat_bio_emap_01"
    name = Column(String(150), nullable=False, index=True) # e.g. "LDPE", "HDPE", "PET"
    category = Column(String(100), nullable=True, index=True) # e.g. "Biodegradable Bio-Polymer"
    polymer_family = Column(String(100), nullable=True, index=True) # e.g. "BREATHABLE_BIO_EMAP"
    structure = Column(String(255), nullable=True)         # e.g. "Monolayer", "PET/Al/PE: 14/10/55 µm"
    form_factor = Column(String(100), nullable=True, default="Flexible Pouch")
    thickness_microns = Column(Float, nullable=True)       # e.g. 30.0
    otr_cc_m2_day = Column(Float, nullable=True)           # e.g. 3500.0
    wvtr_g_m2_day = Column(Float, nullable=True)           # e.g. 45.0
    co2_permeability = Column(Float, nullable=True)        # e.g. 14000.0
    selectivity_beta = Column(Float, nullable=True)        # e.g. 4.0
    tensile_strength_mpa = Column(Float, nullable=True)    # e.g. 32.0
    puncture_resistance_n = Column(Float, nullable=True)   # e.g. 18.0
    elongation_pct = Column(Float, nullable=True)          # e.g. 180.0
    uv_transmittance_pct = Column(Float, nullable=True)    # e.g. 15.0
    optical_clarity = Column(String(100), nullable=True)   # e.g. "Translucent"
    temp_min_c = Column(Float, nullable=True)              # e.g. 0.0
    temp_max_c = Column(Float, nullable=True)              # e.g. 40.0
    thermal_class = Column(String(100), nullable=True)     # e.g. "Refrigerated Stable"
    sustainability_score = Column(Float, nullable=True)    # 0 to 100
    recyclability_score = Column(Float, nullable=True)     # 0 to 100
    biodegradability_score = Column(Float, nullable=True)  # 0 to 100
    resin_code = Column(String(50), nullable=True)         # e.g. "OTHER_7"
    composting_standard = Column(String(100), nullable=True) # e.g. "EN 13432"
    cost_category = Column(String(50), nullable=True)      # e.g. "Commercial Standard"
    estimated_unit_cost_inr = Column(Float, nullable=True) # e.g. 3.85
    is_breathable = Column(Boolean, default=False)
    is_biodegradable = Column(Boolean, default=False)
    is_recyclable = Column(Boolean, default=False)
    is_retort_grade = Column(Boolean, default=False)
    is_cryogenic_grade = Column(Boolean, default=False)
    gas_flush_compatible = Column(Boolean, default=False)
    recommended_applications = Column(Text, nullable=True) # JSON or comma-separated
    regulatory_certifications = Column(Text, nullable=True)
    notes = Column(Text, nullable=True)
    is_active_entry = Column(Boolean, default=True)

    # Legacy compatibility fields
    polymer = Column(String(255), nullable=True)           # e.g. "Conventional polymer"
    thickness = Column(String(255), nullable=True)         # e.g. "25 µm reference"
    otr = Column(String(100), nullable=True)               # Oxygen transmission rate
    wvtr = Column(String(100), nullable=True)              # Water vapor transmission rate
    sealability = Column(String(100), nullable=True)       # e.g. "Heat sealable / High"
    mechanical_strength = Column(String(150), nullable=True) # e.g. "9.93 MPa (Tensile)"
    map_suitable = Column(String(255), nullable=True)      # MAP Suitability
    source_id = Column(Integer, ForeignKey("sources.id"), nullable=True, index=True)

    # Relationships
    source = relationship("Source", back_populates="packaging_materials")
    gas_properties = relationship("GasProperty", back_populates="material", cascade="all, delete-orphan")


class GasProperty(Base):
    __tablename__ = "gas_properties"

    id = Column(Integer, primary_key=True, index=True)
    material_id = Column(Integer, ForeignKey("packaging_materials.id", ondelete="CASCADE"), nullable=False, index=True)
    gas = Column(String(50), nullable=False)               # e.g. "O2", "Water Vapor"
    value = Column(String(100), nullable=True)             # e.g. "7400", "12.50", "<0.05"
    unit = Column(String(100), nullable=True)              # e.g. "cc/m²/day", "g/m²/day"
    temperature = Column(String(50), nullable=True)        # e.g. "23°C", "38°C"
    humidity = Column(String(50), nullable=True)           # e.g. "0%", "90%"
    source_id = Column(Integer, ForeignKey("sources.id"), nullable=True, index=True)

    # Relationships
    material = relationship("PackagingMaterial", back_populates="gas_properties")
    source = relationship("Source", back_populates="gas_properties")


class IFCTFoodComposition(Base):
    __tablename__ = "ifct2017_compositions"

    id = Column(Integer, primary_key=True, index=True)
    code = Column(String(50), unique=True, index=True)
    name = Column(String(255), nullable=False, index=True)
    sc_name = Column(String(255), nullable=True)
    group_name = Column(String(255), nullable=True, index=True)
    energy_kcal = Column(Float, nullable=True)
    protein_g = Column(Float, nullable=True)
    fat_g = Column(Float, nullable=True)
    carbohydrate_g = Column(Float, nullable=True)
    fiber_g = Column(Float, nullable=True)
    water_g = Column(Float, nullable=True)
    ash_g = Column(Float, nullable=True)


class FoodScientificProperty(Base):
    __tablename__ = "food_scientific_properties"

    id = Column(Integer, primary_key=True, index=True)
    food_id = Column(Integer, ForeignKey("foods.id", ondelete="CASCADE"), nullable=False, unique=True, index=True)

    # 1 & 2: Moisture Dynamics
    moisture_sensitivity = Column(String(50), nullable=False, default="Moderate")  # Low, Moderate, High, Extreme
    equilibrium_rh_target_pct = Column(Float, nullable=True)  # e.g. 85-95% for produce, <50% for crisps

    # 3: Respiration Kinetics
    respiration_class = Column(String(50), nullable=False, default="Low")  # Non-respiring, Very Low, Low, Moderate, High, Very High, Extremely High
    respiration_rate_20c = Column(Float, nullable=True)  # mg CO2 / kg / h at 20°C
    respiration_rate_5c = Column(Float, nullable=True)  # mg CO2 / kg / h at 5°C
    respiratory_quotient = Column(Float, nullable=True, default=1.0)  # RQ = CO2 produced / O2 consumed

    # 4 & 5: Gas Sensitivities (O2 / CO2)
    oxygen_sensitivity = Column(String(50), nullable=False, default="Moderate")  # Low, Moderate, High, Critical
    co2_sensitivity = Column(String(50), nullable=False, default="Tolerant")  # Tolerant, Moderate, Highly Sensitive
    max_tolerable_co2_pct = Column(Float, nullable=True)  # % CO2 limit before physiological injury

    # 6 & 7: Ethylene Dynamics
    ethylene_production_class = Column(String(50), nullable=False, default="Low")  # Very Low, Low, Moderate, High, Very High
    ethylene_prod_rate = Column(Float, nullable=True)  # µL / kg / h at 20°C
    ethylene_sensitivity = Column(String(50), nullable=False, default="Low")  # Insensitive, Low, Moderate, High, Extreme

    # 8: Perishability
    perishability = Column(String(50), nullable=False, default="Highly perishable")

    # 9: Thermal Stability & Chilling Sensitivity
    optimum_temp_min_c = Column(Float, nullable=False, default=20.0)
    optimum_temp_max_c = Column(Float, nullable=False, default=25.0)
    chilling_injury_threshold_c = Column(Float, nullable=True)  # e.g. 10-12°C for bananas/tomatoes, None if non-sensitive
    freezing_point_c = Column(Float, nullable=True, default=-0.5)

    # 10, 11, 12, 13: Physical & Biological Sensitivities
    light_sensitivity = Column(String(50), nullable=False, default="Low")  # Low, Moderate, High, Critical
    aroma_sensitivity = Column(String(50), nullable=False, default="Low")  # Low, Moderate, High
    microbial_spoilage_vector = Column(String(100), nullable=False, default="Molds and ambient bacteria")
    mechanical_sensitivity = Column(String(50), nullable=False, default="Moderate")  # Low, Moderate, High, Extreme

    # 14: Shelf Life Baselines
    ambient_shelf_life_days = Column(Integer, nullable=False, default=7)
    refrigerated_shelf_life_days = Column(Integer, nullable=True, default=21)
    controlled_atmosphere_shelf_life_days = Column(Integer, nullable=True)

    # Scientific Provenance
    source_id = Column(Integer, ForeignKey("sources.id"), nullable=True)

    # Relationships
    food = relationship("Food", back_populates="scientific_properties")
    source = relationship("Source", back_populates="scientific_properties")

