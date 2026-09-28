import 'package:flutter/material.dart';
import 'widgets/home_header.dart';
import 'widgets/hero_section.dart';
import 'widgets/workflow_section.dart';
import 'widgets/benefits_section.dart';
import 'widgets/food_preview_section.dart';
import 'widgets/about_section.dart';
import '../analysis/food_analysis_screen.dart';
import '../history/history_screen.dart';
import '../materials/packaging_catalog_screen.dart';
import '../comparison/packaging_comparison_screen.dart';
import '../cost_estimation/cost_estimation_screen.dart';
import '../sustainability/sustainability_analysis_screen.dart';
import '../user_profile_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../analytics/analytics_dashboard_screen.dart';
import '../../services/locale_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _workflowKey = GlobalKey();
  final GlobalKey _benefitsKey = GlobalKey();
  final GlobalKey _commoditiesKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();

  void _scrollToSection(String sectionKey) {
    GlobalKey? targetKey;
    switch (sectionKey) {
      case 'workflow':
        targetKey = _workflowKey;
        break;
      case 'benefits':
        targetKey = _benefitsKey;
        break;
      case 'commodities':
        targetKey = _commoditiesKey;
        break;
      case 'about':
        targetKey = _aboutKey;
        break;
      default:
        targetKey = _heroKey;
    }

    final context = targetKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UserProfileScreen(),
      ),
    );
  }

  void _navigateToAnalysis({String? category}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoodAnalysisScreen(initialCategory: category),
      ),
    );
  }

  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HistoryScreen(),
      ),
    );
  }

  void _navigateToMaterials() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PackagingCatalogScreen(),
      ),
    );
  }

  void _navigateToComparison() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PackagingComparisonScreen(),
      ),
    );
  }

  void _navigateToCostEstimation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CostEstimationScreen(),
      ),
    );
  }

  void _navigateToSustainability({String? materialName, String? foodName}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SustainabilityAnalysisScreen(
          initialMaterialName: materialName,
          foodCommodityName: foodName,
        ),
      ),
    );
  }

  void _navigateToAnalytics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AnalyticsDashboardScreen(),
      ),
    );
  }

  void _navigateToAdmin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminDashboardScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleService(),
      builder: (context, _) {
        return Scaffold(
          appBar: HomeHeader(
            onStartAnalysis: () => _navigateToAnalysis(),
            onOpenHistory: _navigateToHistory,
            onOpenMaterials: _navigateToMaterials,
            onOpenComparison: _navigateToComparison,
            onOpenCostEstimator: _navigateToCostEstimation,
            onOpenSustainability: _navigateToSustainability,
            onOpenAnalytics: _navigateToAnalytics,
            onOpenProfile: _navigateToProfile,
            onOpenAdmin: _navigateToAdmin,
            onNavigateToSection: _scrollToSection,
          ),
          body: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                Container(
                  key: _heroKey,
                  child: HeroSection(
                    onStartAnalysis: () => _navigateToAnalysis(),
                    onExploreCommodities: () => _scrollToSection('commodities'),
                  ),
                ),
                Container(
                  key: _workflowKey,
                  child: const WorkflowSection(),
                ),
                Container(
                  key: _benefitsKey,
                  child: const BenefitsSection(),
                ),
                Container(
                  key: _commoditiesKey,
                  child: FoodPreviewSection(
                    onSelectCategory: (category) => _navigateToAnalysis(category: category),
                  ),
                ),
                Container(
                  key: _aboutKey,
                  child: const AboutSection(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
