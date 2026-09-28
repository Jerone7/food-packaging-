import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/storage_condition.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/quantity_unit_input.dart';

void main() {
  group('QuantityUnitInput Widget Tests', () {
    testWidgets('renders quantity input and changes unit selection', (WidgetTester tester) async {
      final controller = TextEditingController(text: '500');
      QuantityUnit unit = QuantityUnit.g;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuantityUnitInput(
              quantityController: controller,
              selectedUnit: unit,
              onUnitChanged: (u) => unit = u,
            ),
          ),
        ),
      );

      expect(find.text('Batch / Production Quantity'), findsOneWidget);
      expect(find.text('500'), findsOneWidget);
      expect(find.textContaining('0.50 kg total'), findsOneWidget);
    });
  });
}
