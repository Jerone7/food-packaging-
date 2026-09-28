from pydantic import BaseModel, Field
from typing import Optional, Dict, Any

class PhysicochemicalTraits(BaseModel):
    moisture_pct: float = Field(..., description="Total water fraction in percentage")
    fat_pct: float = Field(..., description="Total lipid / fat fraction in percentage")
    ph: float = Field(..., description="pH value")
    water_activity: float = Field(..., description="Water activity a_w")
    moisture_sensitivity: str = Field(..., description="Moisture vulnerability rating (Low, Moderate, High, Extreme)")
    equilibrium_rh_target_pct: Optional[float] = Field(default=None, description="Target equilibrium relative humidity %")

class PhysiologicalKinetics(BaseModel):
    respiration_class: str = Field(..., description="Respiration classification")
    respiration_rate_5c: Optional[float] = Field(default=None, description="Respiration rate in mg CO2/kg/h at 5°C")
    respiration_rate_20c: Optional[float] = Field(default=None, description="Respiration rate in mg CO2/kg/h at 20°C")
    respiratory_quotient: Optional[float] = Field(default=1.0, description="Respiratory Quotient (RQ)")
    ethylene_production_class: str = Field(default="Low", description="Ethylene synthesis class (Very Low, Low, Moderate, High, Very High)")
    ethylene_prod_rate: Optional[float] = Field(default=None, description="Ethylene production rate in µL/kg/h at 20°C")
    ethylene_sensitivity: str = Field(default="Low", description="Ethylene vulnerability rating (Insensitive, Low, Moderate, High, Extreme)")

class AtmosphereSensitivities(BaseModel):
    oxygen_sensitivity: str = Field(..., description="Oxygen vulnerability (Low, Moderate, High, Critical)")
    co2_sensitivity: str = Field(..., description="CO2 physiological tolerance (Tolerant, Moderate, Highly Sensitive)")
    max_tolerable_co2_pct: Optional[float] = Field(default=None, description="Max safe CO2 concentration % before physiological injury")
    target_emap_o2_pct: Optional[str] = Field(default=None, description="Target equilibrium O2 % range in EMAP")
    target_emap_co2_pct: Optional[str] = Field(default=None, description="Target equilibrium CO2 % range in EMAP")

class ThermalAndStorage(BaseModel):
    perishability: str = Field(..., description="Perishability classification")
    optimum_temp_min_c: float = Field(..., description="Minimum optimum storage temperature °C")
    optimum_temp_max_c: float = Field(..., description="Maximum optimum storage temperature °C")
    chilling_injury_threshold_c: Optional[float] = Field(default=None, description="Critical chilling injury threshold °C (None if not chilling sensitive)")
    freezing_point_c: float = Field(default=-0.5, description="Initial freezing point °C")
    ambient_shelf_life_days: int = Field(..., description="Typical shelf life at ambient 20-25°C in days")
    refrigerated_shelf_life_days: Optional[int] = Field(default=None, description="Typical shelf life under refrigeration in days")
    controlled_atmosphere_shelf_life_days: Optional[int] = Field(default=None, description="Shelf life under optimized CA/MAP in days")

class SpoilageAndVulnerabilities(BaseModel):
    light_sensitivity: str = Field(..., description="Photo-oxidation and greening vulnerability (Low, Moderate, High, Critical)")
    aroma_sensitivity: str = Field(..., description="Aroma loss and volatile scalping vulnerability (Low, Moderate, High)")
    microbial_spoilage_vector: str = Field(..., description="Primary microbial spoilage agent")
    mechanical_sensitivity: str = Field(..., description="Bruising, compression, and impact vulnerability (Low, Moderate, High, Extreme)")

class PackagingPrescriptions(BaseModel):
    recommended_barrier_type: str = Field(..., description="Primary recommended polymer / laminate barrier")
    required_otr_range: str = Field(..., description="Target Oxygen Transmission Rate range (cc/m²/day)")
    required_wvtr_range: str = Field(..., description="Target Water Vapor Transmission Rate range (g/m²/day)")
    ethylene_action_required: bool = Field(default=False, description="Whether active KMnO4 ethylene scrubber is prescribed")
    thermal_warning: Optional[str] = Field(default=None, description="Chilling injury warning if stored below safe threshold")
    cushioning_directive: Optional[str] = Field(default=None, description="Recommended protective cushioning material")

class FoodScientificPropertiesResponse(BaseModel):
    food_id: Optional[int] = Field(default=None, description="Unique food database ID")
    commodity_name: str = Field(..., description="Standard commodity name")
    scientific_name: Optional[str] = Field(default=None, description="Botanical or biological scientific name")
    category: str = Field(..., description="Food category")
    physicochemical: PhysicochemicalTraits
    physiological_kinetics: PhysiologicalKinetics
    atmosphere_sensitivities: AtmosphereSensitivities
    thermal_and_storage: ThermalAndStorage
    spoilage_and_vulnerabilities: SpoilageAndVulnerabilities
    packaging_prescriptions: PackagingPrescriptions
    source: str = Field(default="ICMR-NIN IFCT 2017 & UC Davis Postharvest Compendium", description="Scientific data provenance")
    confidence_score: float = Field(default=0.98, description="Data confidence index (0.0 - 1.0)")


class FoodCreate(BaseModel):
    name: str = Field(..., min_length=1, description="Food commodity name (e.g., Fresh Grapes)")
    category: str = Field(..., description="Food category (Fruits, Vegetables, Grains, Dairy, Meat, Bakery, Other perishables)")
    scientific_name: Optional[str] = Field(default=None, description="Botanical or scientific name")
    moisture: Optional[float] = Field(default=80.0, description="Moisture percentage")
    ph: Optional[float] = Field(default=6.0, description="pH level")
    fat: Optional[float] = Field(default=0.5, description="Fat percentage")
    water_activity: Optional[float] = Field(default=0.95, description="Water activity a_w")
    respiration_class: Optional[str] = Field(default="Moderate", description="Respiration class")
    oxygen_sensitivity: Optional[str] = Field(default="Moderate", description="Oxygen sensitivity")
    moisture_sensitivity: Optional[str] = Field(default="Moderate", description="Moisture sensitivity")
    recommended_storage: Optional[str] = Field(default=None, description="Recommended baseline storage condition")


class FoodResponse(BaseModel):
    id: Optional[int] = None
    name: str
    category: str
    scientific_name: Optional[str] = None
    moisture: Optional[float] = None
    ph: Optional[float] = None
    water_activity: Optional[float] = None
    fat: Optional[float] = None
    respiration_class: Optional[str] = None
    oxygen_sensitivity: Optional[str] = None
    moisture_sensitivity: Optional[str] = None
    recommended_storage: Optional[str] = None

    class Config:
        from_attributes = True
