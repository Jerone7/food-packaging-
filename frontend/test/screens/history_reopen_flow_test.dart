import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/services/auth_service.dart';
import 'package:ai_packaging_recommender/screens/user_profile_screen.dart';
import 'package:ai_packaging_recommender/screens/history/widgets/my_analyses_card.dart';
import 'package:ai_packaging_recommender/screens/analysis/food_analysis_screen.dart';

void main() {
  group('History 1-Click Re-Open Flow Integration Tests (Module 13 - Task 5.1)', () {
    setUp(() {
      AuthService().activateDemoMode();
    });

    tearDown(() {
      AuthService().logout();
    });

    testWidgets('UserProfileScreen Tab 1 displays My Analyses and allows 1-click re-open', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: UserProfileScreen(initialTabIndex: 1),
        ),
      );

      // Settle loading states
      await tester.pumpAndSettle();

      // Verify My Analyses header and cards are present
      expect(find.text('My Analyses'), findsOneWidget);
      expect(find.byType(MyAnalysesCard), findsWidgets);

      // Verify empirical items like Tomato or Apple exist
      final tomatoCard = find.widgetWithText(MyAnalysesCard, 'Tomato');
      expect(tomatoCard, findsOneWidget);

      // Tap on Tomato card to test 1-click re-open
      await tester.tap(tomatoCard);
      await tester.pumpAndSettle();

      // Verify navigation to FoodAnalysisScreen
      expect(find.byType(FoodAnalysisScreen), findsOneWidget);
    });
  });
}
