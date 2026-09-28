import 'package:flutter/material.dart';
import '../../../../widgets/brand_logo.dart';
import '../../../../widgets/modern_card.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_translations.dart';
import '../../../../services/locale_service.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

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
            vertical: 56,
          ),
          color: AppTheme.slateDark,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // About Content Row
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: _buildProjectMission(theme)),
                        const SizedBox(width: 48),
                        Expanded(flex: 6, child: _buildDataProvenanceCard(theme)),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildProjectMission(theme),
                        const SizedBox(height: 36),
                        _buildDataProvenanceCard(theme),
                      ],
                    ),

                  const SizedBox(height: 48),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 24),

                  // Footer Bottom Row
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 24,
                    runSpacing: 16,
                    children: [
                      const BrandLogo(isDark: true),
                      _buildFooterLinks(),
                      Text(
                        'landing.footer_copyright'.tr(),
                        style: const TextStyle(fontSize: 12, color: Colors.white54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProjectMission(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.mintAccent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'landing.about_title'.tr(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.mintAccent,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'landing.about_title'.tr(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'landing.about_desc'.tr(),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
        // Tech Stack Badges
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _techBadge('Flutter 3.x'),
            _techBadge('FastAPI Async'),
            _techBadge('PostgreSQL 16'),
            _techBadge('SQLAlchemy 2.0'),
            _techBadge('Material 3'),
          ],
        ),
      ],
    );
  }

  Widget _buildDataProvenanceCard(ThemeData theme) {
    return ModernCard(
      backgroundColor: const Color(0xFF1E293B), // Dark Slate Card
      borderColor: const Color(0xFF334155),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_user_outlined, color: AppTheme.mintAccent, size: 22),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  'Scientific Datasets & Citations',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _provenanceItem(
            'ICMR - National Institute of Nutrition',
            'Indian Food Composition Tables (IFCT 2017) nutritional datasets & composition values across 540+ food items.',
            Icons.menu_book_rounded,
          ),
          const SizedBox(height: 14),
          _provenanceItem(
            'USDA FoodData Central & FAO',
            'Empirical baseline references for processed food respiration, hygroscopic moisture pickup, and fat oxidation rates.',
            Icons.public_rounded,
          ),
          const SizedBox(height: 14),
          _provenanceItem(
            'Polymer Testing & Barrier Literature',
            'Published barrier specs for LDPE, HDPE, PET, Metallized films, and PLA (CRFS 2021, Polymer Testing).',
            Icons.layers_outlined,
          ),
        ],
      ),
    );
  }

  Widget _provenanceItem(String title, String desc, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.mintAccent),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white60,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _techBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF475569)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFooterLinks() {
    return Wrap(
      spacing: 16,
      children: [
        _footerTextLink('Documentation'),
        _footerTextLink('API Reference'),
        _footerTextLink('Privacy Policy'),
        _footerTextLink('GitHub'),
      ],
    );
  }

  Widget _footerTextLink(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        color: Colors.white70,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
