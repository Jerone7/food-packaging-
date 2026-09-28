import 'package:flutter/material.dart';
import '../../../../widgets/gradient_button.dart';
import '../../../../widgets/feature_badge.dart';
import '../../../../widgets/modern_card.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_translations.dart';
import '../../../../services/locale_service.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onStartAnalysis;
  final VoidCallback onExploreCommodities;

  const HeroSection({
    super.key,
    required this.onStartAnalysis,
    required this.onExploreCommodities,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleService(),
      builder: (context, _) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isDesktop = screenWidth >= 1024;
        final theme = Theme.of(context);

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32 : 20,
            vertical: isDesktop ? 64 : 36,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 6, child: _buildLeftHeroContent(theme)),
                        const SizedBox(width: 48),
                        Expanded(flex: 5, child: _buildHeroSampleCard(theme)),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildLeftHeroContent(theme),
                        const SizedBox(height: 36),
                        _buildHeroSampleCard(theme),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeftHeroContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Feature Badges Row
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FeatureBadge.eco(label: 'Eco-Friendly Polymer Matching'),
            FeatureBadge.barrier(label: '540+ IFCT 2017 Food Database'),
            const FeatureBadge(
              label: 'Real-Time OTR / WVTR Sizing',
              icon: Icons.bolt_rounded,
              backgroundColor: Color(0xFFFEF3C7),
              foregroundColor: Color(0xFFD97706),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Main Headline
        Text(
          '${'landing.hero_title_prefix'.tr()} ${'landing.hero_title_highlight'.tr()} ${'landing.hero_title_suffix'.tr()}',
          style: theme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppTheme.slateDark,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),

        // Subtitle
        Text(
          'landing.hero_subtitle'.tr(),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.slateBody,
            fontSize: 16,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 28),

        // Action Buttons
        Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            GradientButton(
              text: 'landing.cta_start_analysis'.tr(),
              icon: Icons.arrow_forward_rounded,
              height: 52,
              fontSize: 16,
              onPressed: onStartAnalysis,
            ),
            OutlinedButton.icon(
              onPressed: onExploreCommodities,
              icon: const Icon(Icons.travel_explore_rounded, size: 20),
              label: Text('landing.cta_explore_catalog'.tr()),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(180, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroSampleCard(ThemeData theme) {
    return ModernCard(
      enableHover: true,
      borderColor: AppTheme.borderTeal,
      backgroundColor: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header of Sample Card
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome, color: AppTheme.primaryTeal, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Live Analysis Sample',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.slateDark),
                    ),
                    Text(
                      'Fried Potato Chips (Low Moisture / High Fat)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.emeraldLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Score: 94/100',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.emeraldEco),
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Commodity Inputs Preview
          Row(
            children: [
              _metricPill('Moisture', '1.5%', Icons.water_drop_outlined),
              const SizedBox(width: 6),
              _metricPill('Fat', '32.4%', Icons.opacity_rounded),
              const SizedBox(width: 6),
              _metricPill('pH', '6.0', Icons.science_outlined),
              const SizedBox(width: 6),
              _metricPill('O2 Sens.', 'High', Icons.air_rounded),
            ],
          ),
          const SizedBox(height: 16),

          // Recommended Solution
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.bgOffWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.layers_rounded, size: 16, color: AppTheme.primaryTeal),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Recommended Barrier Film',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.slateDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Metallized PET (OTR: 0.65 cc/m²/day | WVTR: 1.00 g/m²/day)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cushioning: Honeycomb Kraft + Biodegradable Peanuts. Provides airtight oxidation and moisture pickup defense.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricPill(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, size: 14, color: AppTheme.slateBody),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9, color: AppTheme.slateBody),
            ),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.slateDark),
            ),
          ],
        ),
      ),
    );
  }
}
