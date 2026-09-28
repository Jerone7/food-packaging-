import 'package:flutter/material.dart';
import '../../../../widgets/modern_card.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_translations.dart';
import '../../../../services/locale_service.dart';

class WorkflowSection extends StatelessWidget {
  const WorkflowSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleService(),
      builder: (context, _) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isDesktop = screenWidth >= 900;
        final theme = Theme.of(context);

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32 : 20,
            vertical: 48,
          ),
          color: Colors.white,
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
                      'landing.workflow_title'.tr(),
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
                    'landing.workflow_title'.tr(),
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
                      'landing.workflow_subtitle'.tr(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.slateBody,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Steps Layout
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildStepCard(
                            stepNumber: '01',
                            title: 'landing.step1_title'.tr(),
                            description: 'landing.step1_desc'.tr(),
                            icon: Icons.restaurant_rounded,
                            accentColor: AppTheme.primaryTeal,
                          ),
                        ),
                        _buildStepArrow(),
                        Expanded(
                          child: _buildStepCard(
                            stepNumber: '02',
                            title: 'landing.step2_title'.tr(),
                            description: 'landing.step2_desc'.tr(),
                            icon: Icons.science_rounded,
                            accentColor: const Color(0xFF2563EB),
                          ),
                        ),
                        _buildStepArrow(),
                        Expanded(
                          child: _buildStepCard(
                            stepNumber: '03',
                            title: 'landing.step3_title'.tr(),
                            description: 'landing.step3_desc'.tr(),
                            icon: Icons.verified_rounded,
                            accentColor: AppTheme.emeraldEco,
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildStepCard(
                          stepNumber: '01',
                          title: 'landing.step1_title'.tr(),
                          description: 'landing.step1_desc'.tr(),
                          icon: Icons.restaurant_rounded,
                          accentColor: AppTheme.primaryTeal,
                        ),
                        const SizedBox(height: 20),
                        _buildStepCard(
                          stepNumber: '02',
                          title: 'landing.step2_title'.tr(),
                          description: 'landing.step2_desc'.tr(),
                          icon: Icons.science_rounded,
                          accentColor: const Color(0xFF2563EB),
                        ),
                        const SizedBox(height: 20),
                        _buildStepCard(
                          stepNumber: '03',
                          title: 'landing.step3_title'.tr(),
                          description: 'landing.step3_desc'.tr(),
                          icon: Icons.verified_rounded,
                          accentColor: AppTheme.emeraldEco,
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

  Widget _buildStepCard({
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
    required Color accentColor,
  }) {
    return ModernCard(
      enableHover: true,
      padding: const EdgeInsets.all(24),
      backgroundColor: AppTheme.bgOffWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 28),
              ),
              Text(
                stepNumber,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: accentColor.withValues(alpha: 0.3),
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.slateDark,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.slateBody,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepArrow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      margin: const EdgeInsets.only(top: 60),
      child: Icon(
        Icons.arrow_forward_rounded,
        color: AppTheme.primaryTeal.withValues(alpha: 0.4),
        size: 24,
      ),
    );
  }
}
