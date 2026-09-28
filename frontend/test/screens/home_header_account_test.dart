import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/services/auth_service.dart';
import 'package:ai_packaging_recommender/models/packaging_model.dart';
import 'package:ai_packaging_recommender/screens/landing/widgets/home_header.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/recommendation_results_cockpit.dart';

void main() {
  setUp(() {
    AuthService().resetForTest();
  });

  group('Home Header Account & Cockpit Bookmark Integration Tests (Module 14 - Task 6.2)', () {
    testWidgets('HomeHeader shows Sign In button when logged out and triggers onOpenProfile',
        (WidgetTester tester) async {
      bool profileOpened = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: HomeHeader(
              onStartAnalysis: () {},
              onOpenHistory: () {},
              onOpenProfile: () => profileOpened = true,
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('home_header_signin_button')), findsOneWidget);
      expect(find.byKey(const Key('home_header_profile_avatar')), findsNothing);

      await tester.tap(find.byKey(const Key('home_header_signin_button')));
      await tester.pumpAndSettle();

      expect(profileOpened, isTrue);
    });

    testWidgets('HomeHeader shows initials avatar badge when authenticated',
        (WidgetTester tester) async {
      AuthService().activateDemoMode();
      bool profileOpened = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: HomeHeader(
              onStartAnalysis: () {},
              onOpenHistory: () {},
              onOpenProfile: () => profileOpened = true,
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('home_header_profile_avatar')), findsOneWidget);
      expect(find.text('SJ'), findsOneWidget);

      await tester.tap(find.byKey(const Key('home_header_profile_avatar')));
      await tester.pumpAndSettle();

      expect(profileOpened, isTrue);
    });

    testWidgets('RecommendationResultsCockpit renders Bookmark Preset button and opens dialog',
        (WidgetTester tester) async {
      final mockResult = PackagingRecommendationResult(
        recommendedBoxType: 'Recycled Kraft Corrugated Shipper',
        recommendedDimensions: '25x15x10 cm',
        boxVolumeCm3: 3750.0,
        itemVolumeCm3: 2000.0,
        spaceUtilizationPct: 80.0,
        cushioningMaterial: 'Kraft Paper',
        estimatedCost: 3.20,
        sustainabilityScore: 96.5,
        primaryRecommendation: const PrimaryRecommendation(
          materialName: 'Recycled Kraft Corrugated',
          materialType: 'Bio-Paperboard',
          polymerFamily: 'CELLULOSE',
          structure: 'Single-wall Flute B',
          barrierProfile: BarrierProfile(
            otr: '< 1200 cc/m²/day',
            wvtr: '25.0 g/m²/day',
            thicknessMicrons: 120.0,
            tensileStrengthMpa: 45.0,
            punctureResistanceN: 80.0,
          ),
          sustainabilityScore: 96.5,
          estimatedUnitCostInr: 3.20,
          suitabilityScore: 0.96,
          activeAdditives: ['Water-resistant sizing'],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecommendationResultsCockpit(
                result: mockResult,
              ),
            ),
          ),
        ),
      );

      // Verify Bookmark Preset button exists
      expect(find.byKey(const Key('cockpit_bookmark_preset_button')), findsOneWidget);

      // Tap Bookmark Preset button
      await tester.tap(find.byKey(const Key('cockpit_bookmark_preset_button')));
      await tester.pumpAndSettle();

      // Verify SaveAnalysisDialog opened
      expect(find.text('Bookmark Analysis Preset'), findsOneWidget);
      expect(find.textContaining('Recycled Kraft Corrugated'), findsWidgets);
    });
  });
}
