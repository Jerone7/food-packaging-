import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/advantages_limitations_card.dart';

void main() {
  const sampleAdvantages = [
    'Equilibrium modified atmosphere (EMAP) prevents anaerobic souring',
    'Anti-fog coating suppresses condensation water droplets',
  ];

  const sampleLimitations = [
    'Not suitable for vacuum packing or high-temperature retort processing',
    'Storage duration limited to 14–21 days under ambient conditions',
  ];

  Widget createTestWidget({
    List<String> advantages = sampleAdvantages,
    List<String> limitations = sampleLimitations,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: AdvantagesAndLimitationsCard(
              advantages: advantages,
              limitations: limitations,
            ),
          ),
        ),
      ),
    );
  }

  group('AdvantagesAndLimitationsCard Widget Tests (Task 4.4)', () {
    testWidgets('renders advantages and limitations titles and items', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('ADVANTAGES'), findsOneWidget);
      expect(find.text('LIMITATIONS'), findsOneWidget);
      expect(find.text(sampleAdvantages[0]), findsOneWidget);
      expect(find.text(sampleAdvantages[1]), findsOneWidget);
      expect(find.text(sampleLimitations[0]), findsOneWidget);
      expect(find.text(sampleLimitations[1]), findsOneWidget);
    });

    testWidgets('renders empty fallback message when lists are empty', (tester) async {
      await tester.pumpWidget(createTestWidget(advantages: [], limitations: []));

      expect(find.text('No specific advantages identified.'), findsOneWidget);
      expect(find.text('No specific operational limitations recorded.'), findsOneWidget);
    });
  });
}
