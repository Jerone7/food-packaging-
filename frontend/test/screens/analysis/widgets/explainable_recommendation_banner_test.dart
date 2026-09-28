import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/explainable_recommendation_banner.dart';

void main() {
  const sampleExplanation =
      'This option is recommended because the selected food has high respiration and moisture sensitivity, requiring appropriate gas exchange and moisture management.';
  const sampleDrivers = [
    'High respiration rate (65.0 mg CO₂/kg/h) requires micro-perforations to prevent anaerobic souring.',
    'High moisture content (91.0%) requires anti-fog surfactant to prevent condensation droplets.',
  ];

  Widget createTestWidget({
    String explanation = sampleExplanation,
    List<String> keyDrivers = const [],
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ExplainableRecommendationBanner(
              explanation: explanation,
              keyDrivers: keyDrivers,
            ),
          ),
        ),
      ),
    );
  }

  group('ExplainableRecommendationBanner Widget Tests (Task 4.2)', () {
    testWidgets('renders header badge and exact natural language explanation', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('RECOMMENDATION EXPLANATION'), findsOneWidget);
      expect(find.text('Explainable AI Physiological Rationale'), findsOneWidget);
      expect(find.text(sampleExplanation), findsOneWidget);
    });

    testWidgets('renders key physiological triggers when provided', (tester) async {
      await tester.pumpWidget(createTestWidget(keyDrivers: sampleDrivers));

      expect(find.text('Key Physiological Triggers:'), findsOneWidget);
      expect(find.text(sampleDrivers[0]), findsOneWidget);
      expect(find.text(sampleDrivers[1]), findsOneWidget);
    });
  });
}
