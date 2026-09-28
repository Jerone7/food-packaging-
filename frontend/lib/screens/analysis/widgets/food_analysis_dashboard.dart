import 'package:flutter/material.dart';
import '../../../models/food_scientific_profile.dart';
import '../../../models/storage_condition.dart';
import 'critical_vulnerability_banner.dart';
import 'sensitivity_bar_matrix.dart';
import 'characteristics_radar_chart.dart';
import 'shelf_life_matrix_card.dart';
import 'storage_requirements_card.dart';
import 'food_scientific_dossier_card.dart';

class FoodAnalysisDashboard extends StatelessWidget {
  final FoodScientificProfile profile;
  final StorageMode? currentStorageMode;
  final bool initiallyExpandedDossier;

  const FoodAnalysisDashboard({
    super.key,
    required this.profile,
    this.currentStorageMode,
    this.initiallyExpandedDossier = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 900;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Critical Vulnerability Banner
            CriticalVulnerabilityBanner(profile: profile),
            const SizedBox(height: 16),

            // 2. Middle Row: Sensitivity Bar Matrix & Characteristics Radar Chart
            if (isDesktop) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: SensitivityBarMatrix(profile: profile),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 5,
                    child: CharacteristicsRadarChart(profile: profile),
                  ),
                ],
              ),
            ] else ...[
              SensitivityBarMatrix(profile: profile),
              const SizedBox(height: 16),
              CharacteristicsRadarChart(profile: profile),
            ],
            const SizedBox(height: 16),

            // 3. Bottom Row: Shelf-Life Matrix & Storage Requirements Safeguards
            if (isDesktop) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: ShelfLifeMatrixCard(profile: profile),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: StorageRequirementsCard(profile: profile),
                  ),
                ],
              ),
            ] else ...[
              ShelfLifeMatrixCard(profile: profile),
              const SizedBox(height: 16),
              StorageRequirementsCard(profile: profile),
            ],
            const SizedBox(height: 16),

            // 4. Granular Empirical Dossier Accordion
            FoodScientificDossierCard(
              profile: profile,
              currentStorageMode: currentStorageMode,
              initialExpanded: initiallyExpandedDossier,
            ),
          ],
        );
      },
    );
  }
}
