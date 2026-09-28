import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/widgets/modern_card.dart';
import 'package:ai_packaging_recommender/widgets/feature_badge.dart';

void main() {
  group('ModernCard Widget Tests', () {
    testWidgets('renders child content with custom padding and styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ModernCard(
              padding: EdgeInsets.all(24),
              child: Text('Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      expect(find.byType(ModernCard), findsOneWidget);
    });

    testWidgets('triggers onTap callback when tapped', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModernCard(
              onTap: () => tapped = true,
              child: const Text('Clickable Card'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Clickable Card'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });

  group('FeatureBadge Widget Tests', () {
    testWidgets('renders badge text and icon with eco preset', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeatureBadge.eco(label: 'Biodegradable PLA'),
          ),
        ),
      );

      expect(find.text('Biodegradable PLA'), findsOneWidget);
      expect(find.byIcon(Icons.eco_rounded), findsOneWidget);
    });

    testWidgets('renders barrier badge preset correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeatureBadge.barrier(label: 'Ultra High Barrier'),
          ),
        ),
      );

      expect(find.text('Ultra High Barrier'), findsOneWidget);
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
    });
  });
}
