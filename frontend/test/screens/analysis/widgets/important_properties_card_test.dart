import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/packaging_model.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/important_properties_card.dart';

void main() {
  const sampleProperties = {
    'OTR (Oxygen Barrier)': '3500.0 cc/m²/day',
    'WVTR (Moisture Barrier)': '45.00 g/m²/day',
    'Film Thickness': '30.0 µm',
    'Tensile Strength': '32.0 MPa',
    'Puncture Resistance': '18.0 N',
    'Thermal Span': '0°C to 45°C',
  };

  const sampleBarrier = BarrierProfile(
    otr: '1200 cc/m²/day',
    wvtr: '25.0 g/m²/day',
    thicknessMicrons: 25.0,
    tensileStrengthMpa: 28.0,
    punctureResistanceN: 20.0,
  );

  Widget createTestWidget({
    Map<String, String> properties = sampleProperties,
    BarrierProfile? barrier,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ImportantPropertiesCard(
              importantProperties: properties,
              barrierProfile: barrier,
            ),
          ),
        ),
      ),
    );
  }

  group('ImportantPropertiesCard Widget Tests (Task 4.3)', () {
    testWidgets('renders header and all property tiles from dictionary', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('IMPORTANT PROPERTIES'), findsOneWidget);
      expect(find.text('OTR (Oxygen Barrier)'), findsOneWidget);
      expect(find.text('3500.0 cc/m²/day'), findsOneWidget);
      expect(find.text('WVTR (Moisture Barrier)'), findsOneWidget);
      expect(find.text('45.00 g/m²/day'), findsOneWidget);
      expect(find.text('Film Thickness'), findsOneWidget);
      expect(find.text('30.0 µm'), findsOneWidget);
      expect(find.text('Tensile Strength'), findsOneWidget);
      expect(find.text('32.0 MPa'), findsOneWidget);
      expect(find.text('Puncture Resistance'), findsOneWidget);
      expect(find.text('18.0 N'), findsOneWidget);
      expect(find.text('Thermal Span'), findsOneWidget);
      expect(find.text('0°C to 45°C'), findsOneWidget);
    });

    testWidgets('falls back to barrierProfile when dictionary is empty', (tester) async {
      await tester.pumpWidget(createTestWidget(
        properties: {},
        barrier: sampleBarrier,
      ));

      expect(find.text('IMPORTANT PROPERTIES'), findsOneWidget);
      expect(find.text('1200 cc/m²/day'), findsOneWidget);
      expect(find.text('25.0 g/m²/day'), findsOneWidget);
      expect(find.text('25.0 µm'), findsOneWidget);
      expect(find.text('28.0 MPa'), findsOneWidget);
    });
  });
}
