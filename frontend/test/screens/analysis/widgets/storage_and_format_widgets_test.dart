import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/packaging_model.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/packaging_format_card.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/storage_application_card.dart';

void main() {
  const sampleStorage = 'Cold Storage: 10°C - 12°C (90-95% RH)';
  const sampleApplication =
      'High-respiration fresh produce, strawberries, cut fruits, cherry tomatoes';

  const sampleGeometry = BoxGeometrySpecs(
    lengthCm: 25.0,
    widthCm: 15.0,
    heightCm: 10.0,
    totalVolumeCm3: 3750.0,
    spaceUtilizationPct: 76.5,
    cushioningMaterial: 'Molded Cellulose Pulp Nest Cushioning',
  );

  group('StorageAndApplicationCard Widget Tests (Task 4.5)', () {
    testWidgets('renders storage conditions, applications, and chilling risk', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StorageAndApplicationCard(
              suitableStorageCondition: sampleStorage,
              expectedApplication: sampleApplication,
              chillingInjuryThresholdC: 10.0,
            ),
          ),
        ),
      );

      expect(find.text('SUITABLE STORAGE & APPLICATION'), findsOneWidget);
      expect(find.text(sampleStorage), findsOneWidget);
      expect(find.text(sampleApplication), findsOneWidget);
      expect(find.text('Min 10°C (No Chilling)'), findsOneWidget);
    });
  });

  group('PackagingFormatCard Widget Tests (Task 4.5)', () {
    testWidgets('renders format title, dimensions, space utilization, and cushioning', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PackagingFormatCard(
              packagingFormat: 'Micro-Perforated Hinged Clamshell',
              geometry: sampleGeometry,
            ),
          ),
        ),
      );

      expect(find.text('PACKAGING FORMAT & GEOMETRY'), findsOneWidget);
      expect(find.text('Micro-Perforated Hinged Clamshell'), findsOneWidget);
      expect(find.text('25.0 cm'), findsOneWidget);
      expect(find.text('15.0 cm'), findsOneWidget);
      expect(find.text('10.0 cm'), findsOneWidget);
      expect(find.text('76.5%'), findsOneWidget);
      expect(find.textContaining('Molded Cellulose Pulp Nest Cushioning'), findsOneWidget);
    });
  });
}
