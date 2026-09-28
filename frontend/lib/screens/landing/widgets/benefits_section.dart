import 'package:flutter/material.dart';
import '../../../../widgets/modern_card.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_translations.dart';
import '../../../../services/locale_service.dart';

class BenefitsSection extends StatelessWidget {
  const BenefitsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleService(),
      builder: (context, _) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isDesktop = screenWidth >= 1024;
        final isTablet = screenWidth >= 640 && screenWidth < 1024;
        final isMobile = screenWidth < 640;
        final theme = Theme.of(context);

        final benefits = [
          {
            'title': 'landing.benefit1_title'.tr(),
            'description': 'landing.benefit1_desc'.tr(),
            'icon': Icons.timer_outlined,
            'color': const Color(0xFF0F766E),
            'tag': 'Barrier Sizing',
          },
          {
            'title': 'landing.benefit2_title'.tr(),
            'description': 'landing.benefit2_desc'.tr(),
            'icon': Icons.compost_rounded,
            'color': const Color(0xFF059669),
            'tag': 'Sustainability Score',
          },
          {
            'title': 'landing.benefit3_title'.tr(),
            'description': 'landing.benefit3_desc'.tr(),
            'icon': Icons.aspect_ratio_rounded,
            'color': const Color(0xFF2563EB),
            'tag': 'Volume Efficiency',
          },
          {
            'title': 'landing.benefit4_title'.tr(),
            'description': 'landing.benefit4_desc'.tr(),
            'icon': Icons.menu_book_rounded,
            'color': const Color(0xFFD97706),
            'tag': 'Peer-Reviewed Data',
          },
        ];

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32 : 20,
            vertical: 56,
          ),
          color: AppTheme.bgOffWhite,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                children: [
                  // Section Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.borderTeal,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'landing.benefits_title'.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTeal,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'landing.benefits_title'.tr(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.slateDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 650),
                    child: Text(
                      'landing.benefits_subtitle'.tr(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.slateBody,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Benefits Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = isDesktop ? 2 : (isTablet ? 2 : 1);
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: isMobile ? 16 : 24,
                          mainAxisSpacing: isMobile ? 16 : 24,
                          mainAxisExtent: isMobile ? 220 : 200,
                        ),
                        itemCount: benefits.length,
                        itemBuilder: (context, index) {
                          final item = benefits[index];
                          return _buildBenefitCard(
                            title: item['title'] as String,
                            description: item['description'] as String,
                            icon: item['icon'] as IconData,
                            color: item['color'] as Color,
                            tag: item['tag'] as String,
                            isMobile: isMobile,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBenefitCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String tag,
    bool isMobile = false,
  }) {
    return ModernCard(
      enableHover: true,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isMobile ? 15 : 17,
              fontWeight: FontWeight.bold,
              color: AppTheme.slateDark,
            ),
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Expanded(
            child: Text(
              description,
              overflow: TextOverflow.ellipsis,
              maxLines: isMobile ? 4 : 3,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.slateBody,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
