import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../models/food_commodity.dart';
import '../../models/food_scientific_profile.dart';
import '../../models/storage_condition.dart';
import '../../models/food_analysis_request.dart';
import '../../models/packaging_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/recent_foods_service.dart';
import '../history/history_screen.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_translations.dart';
import '../../services/locale_service.dart';
import '../../widgets/navigation/language_selector_widget.dart';
import '../../widgets/modern_card.dart';
import '../../widgets/gradient_button.dart';

import 'widgets/category_selector.dart';
import 'widgets/food_search_bar.dart';
import 'widgets/recent_foods_bar.dart';
import 'widgets/food_profile_card.dart';
import 'widgets/food_analysis_dashboard.dart';
import 'widgets/quantity_unit_input.dart';
import 'widgets/storage_condition_card.dart';
import 'widgets/storage_duration_input.dart';
import 'widgets/transport_condition_accordion.dart';
import 'widgets/recommendation_results_cockpit.dart';

class FoodAnalysisScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialFoodName;
  final bool? initialFragile;
  final bool? initialEco;

  const FoodAnalysisScreen({
    super.key,
    this.initialCategory,
    this.initialFoodName,
    this.initialFragile,
    this.initialEco,
  });

  @override
  State<FoodAnalysisScreen> createState() => _FoodAnalysisScreenState();
}

class _FoodAnalysisScreenState extends State<FoodAnalysisScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityCtrl = TextEditingController(text: "500");
  final _durationCtrl = TextEditingController(text: "30");

  String? _selectedCategory;
  late FoodCommodity _selectedFood;
  late BiochemicalProfile _currentProfile;
  FoodScientificProfile? _scientificProfile;

  QuantityUnit _selectedUnit = QuantityUnit.g;
  StorageMode _storageCondition = StorageMode.roomTemperature;
  DurationUnit _durationUnit = DurationUnit.days;

  TransportMode _transportMode = TransportMode.ambientRoad;
  int _transitDays = 2;
  bool _isFragile = false;
  bool _ecoFriendlyPriority = true;

  bool _isLoading = false;
  PackagingRecommendationResult? _result;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    if (widget.initialFragile != null) _isFragile = widget.initialFragile!;
    if (widget.initialEco != null) _ecoFriendlyPriority = widget.initialEco!;

    // Pick initial food based on initial food name, category, or default to first
    if (widget.initialFoodName != null) {
      final nameClean = widget.initialFoodName!.toLowerCase();
      final match = ApiService.defaultCommodities.where(
        (f) => f.name.toLowerCase().contains(nameClean) || nameClean.contains(f.name.toLowerCase()),
      );
      if (match.isNotEmpty) {
        _selectedFood = match.first;
        _selectedCategory = _selectedFood.category;
      } else {
        _selectedFood = ApiService.defaultCommodities.first;
      }
    } else if (_selectedCategory != null) {
      final matching = ApiService.defaultCommodities.where(
        (f) => f.category.toLowerCase().contains(_selectedCategory!.toLowerCase()),
      );
      _selectedFood = matching.isNotEmpty ? matching.first : ApiService.defaultCommodities.first;
    } else {
      _selectedFood = ApiService.defaultCommodities.first;
    }

    _currentProfile = _selectedFood.toBiochemicalProfile();
    _scientificProfile = ApiService.getFallbackScientificProfile(
      _selectedFood.name,
      category: _selectedFood.category,
    );
    _fetchScientificProfile(_selectedFood);
  }

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchScientificProfile(FoodCommodity food) async {
    try {
      final profile = await ApiService.lookupScientificProfile(
        food.name,
        category: food.category,
        foodId: food.id,
      );
      if (mounted) {
        setState(() {
          _scientificProfile = profile;
        });
      }
    } catch (_) {
      // Fallback already assigned in memory
    }
  }

  void _onFoodSelected(FoodCommodity food) {
    setState(() {
      _selectedFood = food;
      _selectedCategory = food.category;
      _currentProfile = food.toBiochemicalProfile();
      _scientificProfile = ApiService.getFallbackScientificProfile(
        food.name,
        category: food.category,
      );
      _result = null;
      _errorMessage = null;
    });
    _fetchScientificProfile(food);
  }

  Future<void> _submitAnalysis() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _result = null;
    });

    final qty = double.parse(_quantityCtrl.text.trim());
    final normalizedKg = _selectedUnit.toKilograms(qty);
    final durationDays = _durationUnit.toDays(int.parse(_durationCtrl.text.trim()));

    // Persist to recent history
    await RecentFoodsService.addFood(_selectedFood);

    final request = FoodAnalysisRequest(
      foodId: _selectedFood.id,
      commodityName: _selectedFood.name,
      category: _selectedFood.category,
      biochemicalProfile: _currentProfile,
      quantity: qty,
      unit: _selectedUnit,
      normalizedQuantityKg: normalizedKg,
      storageCondition: _storageCondition,
      storageDurationDays: durationDays,
      transportCondition: TransportCondition(
        mode: _transportMode,
        transitDays: _transitDays,
        isFragile: _isFragile,
      ),
      ecoFriendlyPriority: _ecoFriendlyPriority,
    );

    try {
      double storageTemp;
      switch (_storageCondition) {
        case StorageMode.frozen:
          storageTemp = -18.0;
          break;
        case StorageMode.refrigerated:
          storageTemp = 4.0;
          break;
        case StorageMode.roomTemperature:
        default:
          storageTemp = 20.0;
          break;
      }

      final input = PackagingInput(
        itemName: request.commodityName,
        weight: normalizedKg,
        isFragile: _isFragile,
        ecoFriendly: _ecoFriendlyPriority,
        category: _selectedFood.category,
        moisture: _currentProfile.moisture,
        fat: _currentProfile.fat,
        ph: _currentProfile.ph,
        waterActivity: _currentProfile.waterActivity,
        respirationClass: _currentProfile.respirationClass,
        respirationRate20c: _scientificProfile?.physiologicalKinetics.respirationRate20c,
        ethyleneSensitivity: _scientificProfile?.physiologicalKinetics.ethyleneSensitivity,
        chillingInjuryThresholdC: _scientificProfile?.thermalAndStorage.chillingInjuryThresholdC,
        storageCondition: _storageCondition.displayName,
        storageTempC: storageTemp,
        storageDurationDays: durationDays,
        transportMode: _transportMode.displayName,
      );

      final res = await ApiService.getRecommendation(input);
      if (mounted) {
        setState(() {
          _result = res;
        });

        if (AuthService().isAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: AppTheme.emeraldEco, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('analysis.history_saved'.tr().replaceAll('{item}', input.itemName)),
                  ),
                ],
              ),
              backgroundColor: AppTheme.slateDark,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getRecommendedBarrierName() {
    if (_storageCondition == StorageMode.frozen) {
      return "Cryogenic Puncture-Resistant LLDPE / Cast Polyamide Deep-Freeze Pouch";
    } else if (_currentProfile.fat > 18 || _currentProfile.moisture < 8) {
      return _ecoFriendlyPriority
          ? "Metallized High-Barrier Bio-PET (Met-PET) Film with N₂ Gas Flush"
          : "Tri-Layer Aluminium Foil Barrier Laminate (PET/AL/PE)";
    } else if (_currentProfile.moisture > 75 && (_currentProfile.respirationClass == 'High' || _currentProfile.respirationClass == 'Very High')) {
      return _ecoFriendlyPriority
          ? "Micro-Perforated Equilibrium MAP Bio-Film (PLA/PBAT)"
          : "Antifog Micro-Perforated Polyolefin Breathable Film (LDPE)";
    } else if (_currentProfile.ph < 4.6) {
      return "Acid-Resistant Multi-Layer Retort Barrier Pouch (PET/AL/PA/PP)";
    } else if (_selectedFood.category.toLowerCase().contains("meat") || _selectedFood.category.toLowerCase().contains("dairy")) {
      return "High-Barrier EVOH Vacuum Skin Film (VSP / MAP CO₂ Flush)";
    } else if (_selectedFood.category.toLowerCase().contains("grain") || _selectedFood.category.toLowerCase().contains("bakery")) {
      return _ecoFriendlyPriority
          ? "Unbleached Recycled Kraft with Biodegradable PLA Moisture Liner"
          : "Biaxially Oriented Polypropylene (BOPP) Pouch";
    } else {
      return "Recyclable High-Density Polyethylene (HDPE) Barrier Pouch";
    }
  }

  String _getStorageNotes() {
    if (_storageCondition == StorageMode.frozen) {
      return "Puncture-proof barrier prevents cryogenic dehydration and freezer burn at sub-zero temperatures.";
    } else if (_currentProfile.fat > 18 || _currentProfile.moisture < 8) {
      return "Ultra-low OTR & WVTR with nitrogen flush prevents oxidative rancidity and preserves crisp texture.";
    } else if (_currentProfile.moisture > 75 && (_currentProfile.respirationClass == 'High' || _currentProfile.respirationClass == 'Very High')) {
      return "Equilibrium Modified Atmosphere (EMAP) balances O₂/CO₂ exchange to suppress decay and condensation.";
    } else if (_currentProfile.ph < 4.6) {
      return "Acid-resistant inert barrier prevents organic acid corrosion and pinholing.";
    } else {
      return "Optimized barrier layer preserves natural moisture balance and inhibits microbial spoilage.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleService(),
      builder: (context, _) {
        final theme = Theme.of(context);
        final screenWidth = MediaQuery.of(context).size.width;
        final isDesktop = screenWidth >= 1024;

        return Scaffold(
          appBar: AppBar(
            title: Text('analysis.title'.tr()),
            actions: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Center(
                  child: LanguageSelectorWidget(mode: LanguageSelectorMode.compact),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.history_rounded),
                tooltip: 'nav.history'.tr(),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  );
                },
              )
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32 : 16,
              vertical: 24,
            ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Form(
              key: _formKey,
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column (55%): Food Selection & Biochemical Specs
                        Expanded(
                          flex: 11,
                          child: _buildLeftFoodColumn(theme),
                        ),
                        const SizedBox(width: 32),

                        // Right Column (45%): Logistics, Storage, Quantity & Action
                        Expanded(
                          flex: 9,
                          child: _buildRightLogisticsColumn(theme),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildLeftFoodColumn(theme),
                        const SizedBox(height: 24),
                        _buildRightLogisticsColumn(theme),
                      ],
                    ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

  Widget _buildLeftFoodColumn(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Chips
        CategorySelector(
          selectedCategory: _selectedCategory,
          onSelectCategory: (cat) {
            setState(() {
              _selectedCategory = cat;
              if (cat != null) {
                final matching = ApiService.defaultCommodities.where(
                  (f) => f.category.toLowerCase().contains(cat.toLowerCase()),
                );
                if (matching.isNotEmpty) {
                  _onFoodSelected(matching.first);
                }
              }
            });
          },
        ),
        const SizedBox(height: 18),

        // Search Bar with Autocomplete
        FoodSearchBar(
          selectedCategory: _selectedCategory,
          onSelectFood: _onFoodSelected,
        ),
        const SizedBox(height: 14),

        // Recently Selected Foods
        RecentFoodsBar(
          onSelectRecent: _onFoodSelected,
        ),
        const SizedBox(height: 18),

        // Selected Food Profile Card with Scientific Gauges & Overrides
        FoodProfileCard(
          food: _selectedFood,
          currentProfile: _currentProfile,
          onProfileChanged: (p) => setState(() => _currentProfile = p),
        ),

        // Food Analysis Dashboard (Vulnerability Alerts, Radar, Bar Matrix, Shelf Life & Storage)
        if (_scientificProfile != null) ...[
          const SizedBox(height: 18),
          FoodAnalysisDashboard(
            profile: _scientificProfile!,
            currentStorageMode: _storageCondition,
          ),
        ],
      ],
    );
  }

  Widget _buildRightLogisticsColumn(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Production Quantity & Unit
        ModernCard(
          backgroundColor: Colors.white,
          borderColor: AppTheme.borderSubtle,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuantityUnitInput(
                quantityController: _quantityCtrl,
                selectedUnit: _selectedUnit,
                onUnitChanged: (u) => setState(() => _selectedUnit = u),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              StorageConditionCard(
                selectedCondition: _storageCondition,
                onConditionChanged: (m) => setState(() => _storageCondition = m),
              ),
              const SizedBox(height: 20),
              StorageDurationInput(
                durationController: _durationCtrl,
                durationUnit: _durationUnit,
                onUnitChanged: (u) => setState(() => _durationUnit = u),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(
                  'analysis.eco_priority_title'.tr(),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.slateDark),
                ),
                subtitle: Text(
                  'analysis.eco_priority_subtitle'.tr(),
                  style: const TextStyle(fontSize: 11, color: AppTheme.slateBody),
                ),
                value: _ecoFriendlyPriority,
                activeThumbColor: AppTheme.emeraldEco,
                onChanged: (val) => setState(() => _ecoFriendlyPriority = val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Optional Transportation Accordion
        TransportConditionAccordion(
          selectedMode: _transportMode,
          transitDays: _transitDays,
          isFragile: _isFragile,
          onModeChanged: (m) => setState(() => _transportMode = m),
          onDaysChanged: (d) => setState(() => _transitDays = d),
          onFragileChanged: (f) => setState(() => _isFragile = f),
        ),
        const SizedBox(height: 20),

        // Primary Action Button
        GradientButton(
          text: 'analysis.btn_calculate'.tr(),
          icon: Icons.auto_awesome_rounded,
          height: 52,
          fontSize: 16,
          isFullWidth: true,
          onPressed: _isLoading ? null : _submitAnalysis,
        ),

        const SizedBox(height: 16),

        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(
              child: SpinKitThreeBounce(
                color: AppTheme.primaryTeal,
                size: 32.0,
              ),
            ),
          ),

        if (_result != null && !_isLoading) ...[
          const SizedBox(height: 24),
          RecommendationResultsCockpit(
            result: _result!,
            onResetAnalysis: () => setState(() => _result = null),
          ),
        ],
      ],
    );
  }
}
