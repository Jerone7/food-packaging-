import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/services/locale_service.dart';
import 'package:ai_packaging_recommender/screens/landing/widgets/home_header.dart';
import 'package:ai_packaging_recommender/widgets/brand_logo.dart';

void main() {
  setUp(() {
    LocaleService().initForTesting(languageCode: 'en');
  });

  group('HomeHeader Widget Tests', () {
    testWidgets('renders brand logo and desktop navigation links on wide screen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: HomeHeader(
              onStartAnalysis: () {},
              onOpenHistory: () {},
            ),
          ),
        ),
      );

      expect(find.byType(BrandLogo), findsOneWidget);
      expect(find.text('How It Works'), findsOneWidget);
      expect(find.text('Benefits'), findsOneWidget);
      expect(find.text('Commodities'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
      expect(find.text('Launch Analysis'), findsOneWidget);
    });

    testWidgets('triggers onStartAnalysis and onOpenHistory callbacks', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool startTriggered = false;
      bool historyTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: HomeHeader(
              onStartAnalysis: () => startTriggered = true,
              onOpenHistory: () => historyTriggered = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Launch Analysis'));
      await tester.pumpAndSettle();
      expect(startTriggered, isTrue);

      await tester.tap(find.byIcon(Icons.history_rounded));
      await tester.pumpAndSettle();
      expect(historyTriggered, isTrue);
    });

    testWidgets('collapses desktop links into mobile compact view on small screen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: HomeHeader(
              onStartAnalysis: () {},
              onOpenHistory: () {},
            ),
          ),
        ),
      );

      expect(find.byType(BrandLogo), findsOneWidget);
      expect(find.text('How It Works'), findsNothing); // Collapsed on mobile
      expect(find.byIcon(Icons.history_rounded), findsOneWidget);
    });
  });
}
