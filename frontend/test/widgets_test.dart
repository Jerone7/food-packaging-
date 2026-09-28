import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/widgets/brand_logo.dart';
import 'package:ai_packaging_recommender/widgets/gradient_button.dart';

void main() {
  group('BrandLogo Widget Tests', () {
    testWidgets('renders SmartPack AI brand title and subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BrandLogo(),
          ),
        ),
      );

      expect(find.byType(BrandLogo), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is RichText && widget.text.toPlainText().contains('SmartPack AI'),
        ),
        findsOneWidget,
      );
      expect(find.text('Sustainable Food Packaging'), findsOneWidget);
      expect(find.byIcon(Icons.inventory_2_rounded), findsOneWidget);
      expect(find.byIcon(Icons.eco_rounded), findsOneWidget);
    });

    testWidgets('triggers onTap callback when tapped', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BrandLogo(onTap: () => tapped = true),
          ),
        ),
      );

      await tester.tap(find.byType(BrandLogo));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });

  group('GradientButton Widget Tests', () {
    testWidgets('renders button text and icon correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: 'Start Analysis',
              icon: Icons.arrow_forward_rounded,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Start Analysis'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets('executes onPressed callback on user tap', (WidgetTester tester) async {
      int count = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: 'Launch',
              onPressed: () => count++,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Launch'));
      await tester.pumpAndSettle();
      expect(count, 1);
    });
  });
}
