/// Multi-Device Adaptive Navigation Shell
/// (Module 20: 📱 Responsive Design)
///
/// Automatically transforms navigation architecture across device tiers:
/// - Desktop / Laptop (≥ 992px): Persistent Top Header with full navigation chips and action buttons
/// - Tablet (600px - 991px): Adaptive Left Navigation Rail with compact top action bar
/// - Mobile (< 600px): Streamlined AppBar with Bottom Navigation Bar
library adaptive_app_shell;

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/responsive_layout.dart';
import '../brand_logo.dart';
import 'language_selector_widget.dart';

/// Navigation Item Model for the Adaptive Shell
class AdaptiveNavDestination {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final String? badge;

  const AdaptiveNavDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.badge,
  });
}

/// Adaptive Top / Rail / Bottom Navigation Shell
class AdaptiveAppShell extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AdaptiveNavDestination> destinations;
  final Widget body;
  final Widget? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showLogo;
  final bool showLanguageSelector;

  const AdaptiveAppShell({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.showLogo = true,
    this.showLanguageSelector = true,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isDesktopOrLaptop) {
      return _buildDesktopLayout(context);
    } else if (context.isTablet) {
      return _buildTabletLayout(context);
    } else {
      return _buildMobileLayout(context);
    }
  }

  // --- 1. Desktop & Laptop Layout (Top App Bar + Body) ---
  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgOffWhite,
      floatingActionButton: floatingActionButton,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(bottom: BorderSide(color: AppTheme.borderSubtle, width: 1.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveSpacing.horizontalGutter(context),
            vertical: 8.0,
          ),
          child: Row(
            children: [
              if (showLogo) ...[
                const BrandLogo(iconSize: 24, fontSize: 18),
                const SizedBox(width: 12),
              ],
              if (title != null) ...[
                Flexible(child: title!),
                const SizedBox(width: 16),
              ],
              const Spacer(),
              // Top Navigation Items (Flexible & Scrollable)
              Flexible(
                flex: 3,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(destinations.length, (index) {
                      final item = destinations[index];
                      final isSelected = index == selectedIndex;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: InkWell(
                          onTap: () => onDestinationSelected(index),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primaryTeal.withValues(alpha: 0.1) : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isSelected ? (item.selectedIcon ?? item.icon) : item.icon,
                                  size: 18,
                                  color: isSelected ? AppTheme.primaryTeal : AppTheme.slateBody,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? AppTheme.primaryTeal : AppTheme.slateDark,
                                  ),
                                ),
                                if (item.badge != null) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.emeraldEco,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      item.badge!,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              if (showLanguageSelector) ...[
                const SizedBox(width: 8),
                const LanguageSelectorWidget(mode: LanguageSelectorMode.compact),
              ],
              if (actions != null && actions!.isNotEmpty) ...[
                const SizedBox(width: 8),
                ...actions!,
              ],
            ],
          ),
        ),
      ),
      body: body,
    );
  }

  // --- 2. Tablet Layout (Left Navigation Rail + Body) ---
  Widget _buildTabletLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgOffWhite,
      floatingActionButton: floatingActionButton,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Row(
          children: [
            if (showLogo) const BrandLogo(iconSize: 22, fontSize: 16),
            if (showLogo && title != null) const SizedBox(width: 10),
            if (title != null) Expanded(child: title!),
          ],
        ),
        actions: [
          if (showLanguageSelector)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Center(child: LanguageSelectorWidget(mode: LanguageSelectorMode.compact)),
            ),
          if (actions != null) ...actions!,
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.white,
            selectedIconTheme: const IconThemeData(color: AppTheme.primaryTeal),
            selectedLabelTextStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryTeal,
            ),
            unselectedLabelTextStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.slateBody,
            ),
            destinations: destinations.map((d) {
              return NavigationRailDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon ?? d.icon),
                label: Text(d.label),
              );
            }).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1, color: AppTheme.borderSubtle),
          Expanded(child: body),
        ],
      ),
    );
  }

  // --- 3. Mobile Layout (AppBar + Body + BottomNavigationBar) ---
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgOffWhite,
      floatingActionButton: floatingActionButton,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            if (showLogo) const BrandLogo(iconSize: 20, fontSize: 15),
            if (showLogo && title != null) const SizedBox(width: 8),
            if (title != null) Expanded(child: title!),
          ],
        ),
        actions: [
          if (showLanguageSelector)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Center(child: LanguageSelectorWidget(mode: LanguageSelectorMode.compact)),
            ),
          if (actions != null) ...actions!,
        ],
      ),
      body: body,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.borderSubtle, width: 1.0)),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          backgroundColor: Colors.white,
          indicatorColor: AppTheme.primaryTeal.withValues(alpha: 0.15),
          destinations: destinations.map((d) {
            return NavigationDestination(
              icon: Icon(d.icon, color: AppTheme.slateBody),
              selectedIcon: Icon(d.selectedIcon ?? d.icon, color: AppTheme.primaryTeal),
              label: d.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}
