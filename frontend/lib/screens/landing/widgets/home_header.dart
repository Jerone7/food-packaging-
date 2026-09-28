import 'package:flutter/material.dart';
import '../../../../widgets/brand_logo.dart';
import '../../../../widgets/gradient_button.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_translations.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/locale_service.dart';
import '../../../../widgets/navigation/language_selector_widget.dart';

class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onStartAnalysis;
  final VoidCallback onOpenHistory;
  final VoidCallback? onOpenMaterials;
  final VoidCallback? onOpenComparison;
  final VoidCallback? onOpenCostEstimator;
  final VoidCallback? onOpenSustainability;
  final VoidCallback? onOpenAnalytics;
  final VoidCallback? onOpenProfile;
  final VoidCallback? onOpenAdmin;
  final Function(String section)? onNavigateToSection;

  const HomeHeader({
    super.key,
    required this.onStartAnalysis,
    required this.onOpenHistory,
    this.onOpenMaterials,
    this.onOpenComparison,
    this.onOpenCostEstimator,
    this.onOpenSustainability,
    this.onOpenAnalytics,
    this.onOpenProfile,
    this.onOpenAdmin,
    this.onNavigateToSection,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleService(),
      builder: (context, _) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isDesktop = screenWidth >= 1150;
        final isTablet = screenWidth >= 650 && screenWidth < 1150;
        final isMobile = screenWidth < 650;

        return Container(
          height: preferredSize.height,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite.withValues(alpha: 0.95),
        border: const Border(
          bottom: BorderSide(color: AppTheme.borderSubtle, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final showDesktopNav = isDesktop && constraints.maxWidth >= 950;
              final showToolIcons = !isMobile && constraints.maxWidth >= 780;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Brand Logo
                  Flexible(
                    child: BrandLogo(
                      fontSize: !isMobile ? 20 : 16,
                      iconSize: !isMobile ? 28 : 22,
                      showSubtitle: !isMobile,
                    ),
                  ),

                  // Desktop Navigation Links (Only on desktop screens with adequate layout width >= 950px)
                  if (showDesktopNav) ...[
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _navLink('landing.nav_workflow'.tr(), 'workflow'),
                            _navLink('landing.nav_benefits'.tr(), 'benefits'),
                            _navLink('landing.nav_commodities'.tr(), 'commodities'),
                            _navLink('landing.nav_about'.tr(), 'about'),
                          ],
                        ),
                      ),
                    ),
                  ],

              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Universal Language Selector Widget (Compact)
                  const Padding(
                    padding: EdgeInsets.only(right: 6.0),
                    child: LanguageSelectorWidget(mode: LanguageSelectorMode.compact),
                  ),

                  // Desktop, Laptop & Tablet Tool Icon Buttons
                  if (showToolIcons) ...[
                    if (onOpenMaterials != null)
                      IconButton(
                        icon: const Icon(Icons.dataset_outlined, color: AppTheme.primaryTeal),
                        tooltip: 'nav.materials'.tr(),
                        onPressed: onOpenMaterials,
                      ),
                    if (onOpenComparison != null)
                      IconButton(
                        icon: const Icon(Icons.balance_rounded, color: Color(0xFF0284C7)),
                        tooltip: 'nav.compare'.tr(),
                        onPressed: onOpenComparison,
                      ),
                    if (onOpenCostEstimator != null)
                      IconButton(
                        icon: const Icon(Icons.payments_outlined, color: Color(0xFFD97706)),
                        tooltip: '${'nav.cost'.tr()} 💰',
                        onPressed: onOpenCostEstimator,
                      ),
                    if (onOpenSustainability != null)
                      IconButton(
                        icon: const Icon(Icons.eco_rounded, color: Color(0xFF10B981)),
                        tooltip: '${'nav.sustainability'.tr()} 🌱',
                        onPressed: onOpenSustainability,
                      ),
                    if (onOpenAnalytics != null)
                      IconButton(
                        icon: const Icon(Icons.insights_rounded, color: Color(0xFF6366F1)),
                        tooltip: '${'nav.analytics'.tr()} 📈',
                        onPressed: onOpenAnalytics,
                      ),
                    if (onOpenAdmin != null)
                      AnimatedBuilder(
                        animation: AuthService(),
                        builder: (ctx, _) {
                          final auth = AuthService();
                          final isAdmin = auth.currentUser?.isAdmin == true;
                          if (!isAdmin) return const SizedBox.shrink();
                          if (isDesktop) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: OutlinedButton.icon(
                                key: const Key('home_header_admin_button'),
                                icon: const Icon(Icons.admin_panel_settings_rounded, size: 14, color: Color(0xFFD97706)),
                                label: Text(
                                  '${'nav.admin'.tr()} ⚙️',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  side: const BorderSide(color: Color(0xFFD97706), width: 1.2),
                                ),
                                onPressed: onOpenAdmin,
                              ),
                            );
                          }
                          return IconButton(
                            key: const Key('home_header_admin_button'),
                            icon: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFFD97706)),
                            tooltip: '${'nav.admin'.tr()} ⚙️',
                            onPressed: onOpenAdmin,
                          );
                        },
                      ),
                  ] else ...[
                    // Compact Popup Menu for Tools (Mobile + narrow tablet)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.apps_rounded, color: AppTheme.primaryTeal),
                      tooltip: 'Analysis Tools',
                      constraints: isMobile ? const BoxConstraints(minWidth: 32, minHeight: 32) : null,
                      padding: isMobile ? EdgeInsets.zero : const EdgeInsets.all(8.0),
                      onSelected: (val) {
                        switch (val) {
                          case 'materials':
                            onOpenMaterials?.call();
                            break;
                          case 'comparison':
                            onOpenComparison?.call();
                            break;
                          case 'cost':
                            onOpenCostEstimator?.call();
                            break;
                          case 'sustainability':
                            onOpenSustainability?.call();
                            break;
                          case 'analytics':
                            onOpenAnalytics?.call();
                            break;
                          case 'admin':
                            onOpenAdmin?.call();
                            break;
                        }
                      },
                      itemBuilder: (ctx) {
                        final auth = AuthService();
                        final isAdmin = auth.currentUser?.isAdmin == true;
                        return [
                          if (onOpenMaterials != null)
                            PopupMenuItem(
                              value: 'materials',
                              child: Row(
                                children: [
                                  const Icon(Icons.dataset_outlined, size: 16, color: AppTheme.primaryTeal),
                                  const SizedBox(width: 8),
                                  Text('nav.materials'.tr(), style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                          if (onOpenComparison != null)
                            PopupMenuItem(
                              value: 'comparison',
                              child: Row(
                                children: [
                                  const Icon(Icons.balance_rounded, size: 16, color: Color(0xFF0284C7)),
                                  const SizedBox(width: 8),
                                  Text('nav.compare'.tr(), style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                          if (onOpenCostEstimator != null)
                            PopupMenuItem(
                              value: 'cost',
                              child: Row(
                                children: [
                                  const Icon(Icons.payments_outlined, size: 16, color: Color(0xFFD97706)),
                                  const SizedBox(width: 8),
                                  Text('${'nav.cost'.tr()} 💰', style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                          if (onOpenSustainability != null)
                            PopupMenuItem(
                              value: 'sustainability',
                              child: Row(
                                children: [
                                  const Icon(Icons.eco_rounded, size: 16, color: Color(0xFF10B981)),
                                  const SizedBox(width: 8),
                                  Text('${'nav.sustainability'.tr()} 🌱', style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                          if (onOpenAnalytics != null)
                            PopupMenuItem(
                              value: 'analytics',
                              child: Row(
                                children: [
                                  const Icon(Icons.insights_rounded, size: 16, color: Color(0xFF6366F1)),
                                  const SizedBox(width: 8),
                                  Text('${'nav.analytics'.tr()} 📈', style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                          if (onOpenAdmin != null && isAdmin)
                            PopupMenuItem(
                              value: 'admin',
                              child: Row(
                                children: [
                                  const Icon(Icons.admin_panel_settings_rounded, size: 16, color: Color(0xFFD97706)),
                                  const SizedBox(width: 8),
                                  Text('${'nav.admin'.tr()} ⚙️', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                                ],
                              ),
                            ),
                        ];
                      },
                    ),
                  ],

                  const SizedBox(width: 2),
                  IconButton(
                    key: const Key('home_header_history_button'),
                    icon: const Icon(Icons.history_rounded, color: AppTheme.slateDark),
                    tooltip: 'nav.history'.tr(),
                    constraints: isMobile ? const BoxConstraints(minWidth: 32, minHeight: 32) : null,
                    visualDensity: isMobile ? VisualDensity.compact : null,
                    padding: isMobile ? EdgeInsets.zero : const EdgeInsets.all(8.0),
                    onPressed: onOpenHistory,
                  ),
                  const SizedBox(width: 4),

                  // User Account / Profile Navigation Trigger
                  if (onOpenProfile != null)
                    AnimatedBuilder(
                      animation: AuthService(),
                      builder: (ctx, _) {
                        final auth = AuthService();
                        if (auth.isAuthenticated) {
                          final user = auth.currentUser!;
                          return InkWell(
                            key: const Key('home_header_profile_avatar'),
                            onTap: onOpenProfile,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.borderTeal),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: AppTheme.primaryTeal,
                                    child: Text(
                                      user.initials,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  if (isDesktop) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      user.fullName.split(' ').first,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryTeal,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }

                        // Unauthenticated / Guest View
                        if (isMobile) {
                          return IconButton(
                            key: const Key('home_header_signin_button'),
                            onPressed: onOpenProfile,
                            icon: const Icon(Icons.person_outline_rounded, size: 20, color: AppTheme.primaryTeal),
                            tooltip: 'profile.sign_in'.tr(),
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          );
                        }

                        return TextButton.icon(
                          key: const Key('home_header_signin_button'),
                          onPressed: onOpenProfile,
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primaryTeal,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          ),
                          icon: const Icon(Icons.person_outline_rounded, size: 16),
                          label: Text(
                            isDesktop ? 'profile.sign_in'.tr() : '',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        );
                      },
                    ),

                  const SizedBox(width: 4),
                  if (isDesktop)
                    GradientButton(
                      text: 'landing.cta_start_analysis'.tr(),
                      icon: Icons.auto_awesome_rounded,
                      height: 38,
                      fontSize: 13,
                      onPressed: onStartAnalysis,
                    )
                  else if (!isMobile)
                    IconButton(
                      icon: const Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryTeal),
                      tooltip: 'landing.cta_start_analysis'.tr(),
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.all(8.0),
                      onPressed: onStartAnalysis,
                    ),
                ],
              ),
            ],
          );
        },
      ),
        ),
      ),
    );
  },
);
}

  Widget _navLink(String title, String sectionKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextButton(
        onPressed: () => onNavigateToSection?.call(sectionKey),
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.slateDark,
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        child: Text(title),
      ),
    );
  }
}
