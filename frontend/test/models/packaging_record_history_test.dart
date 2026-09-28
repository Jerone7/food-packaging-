import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/packaging_model.dart';

void main() {
  group('PackagingRecord History Extensions & Re-Open Mapping (Module 13 - Task 3.1)', () {
    test('fromJson deserializes user_id, formatted_date, and metrics', () {
      final json = {
        'id': 201,
        'user_id': 1,
        'item_name': 'Tomato',
        'length': 30.0,
        'width': 20.0,
        'height': 15.0,
        'weight': 5.0,
        'is_fragile': true,
        'eco_friendly': true,
        'recommended_box_type': 'Corrugated Kraft Box (5-Ply)',
        'recommended_dimensions': '30.0 x 20.0 x 15.0 cm',
        'cushioning_material': 'Kraft Honeycomb Pad',
        'estimated_cost': 3.10,
        'sustainability_score': 96.5,
        'created_at': '2026-09-26T14:30:00.000Z',
        'formatted_date': '26 Sep 2026',
      };

      final record = PackagingRecord.fromJson(json);

      expect(record.id, 201);
      expect(record.userId, 1);
      expect(record.itemName, 'Tomato');
      expect(record.length, 30.0);
      expect(record.width, 20.0);
      expect(record.height, 15.0);
      expect(record.weight, 5.0);
      expect(record.isFragile, isTrue);
      expect(record.ecoFriendly, isTrue);
      expect(record.recommendedBoxType, 'Corrugated Kraft Box (5-Ply)');
      expect(record.estimatedCost, 3.10);
      expect(record.sustainabilityScore, 96.5);
      expect(record.formattedDisplayDate, '26 Sep 2026');
    });

    test('formattedDisplayDate automatically formats DateTime when formatted_date is absent', () {
      final record1 = PackagingRecord(
        id: 1,
        itemName: 'Apple',
        length: 25.0,
        width: 18.0,
        height: 12.0,
        weight: 3.0,
        isFragile: false,
        ecoFriendly: true,
        createdAt: DateTime(2026, 9, 25, 10, 0),
        recommendedBoxType: 'Molded Pulp Tray',
        recommendedDimensions: '25x18x12 cm',
        boxVolumeCm3: 5400,
        itemVolumeCm3: 4000,
        spaceUtilizationPct: 74.0,
        cushioningMaterial: 'Molded Pulp',
        estimatedCost: 2.85,
        sustainabilityScore: 94.0,
      );

      final record2 = PackagingRecord(
        id: 2,
        itemName: 'Potato',
        length: 35.0,
        width: 25.0,
        height: 20.0,
        weight: 10.0,
        isFragile: false,
        ecoFriendly: true,
        createdAt: DateTime(2026, 9, 23, 16, 45),
        recommendedBoxType: 'Paper Sack',
        recommendedDimensions: '35x25x20 cm',
        boxVolumeCm3: 17500,
        itemVolumeCm3: 14000,
        spaceUtilizationPct: 80.0,
        cushioningMaterial: 'None',
        estimatedCost: 1.75,
        sustainabilityScore: 98.0,
      );

      expect(record1.formattedDisplayDate, '25 Sep 2026');
      expect(record2.formattedDisplayDate, '23 Sep 2026');
    });

    test('toPackagingInput converts record accurately for 1-click cockpit reload', () {
      final record = PackagingRecord(
        id: 10,
        itemName: 'Fresh Strawberries',
        length: 18.0,
        width: 12.0,
        height: 6.0,
        weight: 0.5,
        isFragile: true,
        ecoFriendly: true,
        createdAt: DateTime(2026, 9, 26),
        recommendedBoxType: 'Bio-PLA Clamshell',
        recommendedDimensions: '18x12x6 cm',
        boxVolumeCm3: 1296,
        itemVolumeCm3: 1000,
        spaceUtilizationPct: 77.0,
        cushioningMaterial: 'Liner Pad',
        estimatedCost: 4.25,
        sustainabilityScore: 94.0,
      );

      final input = record.toPackagingInput();

      expect(input.itemName, 'Fresh Strawberries');
      expect(input.length, 18.0);
      expect(input.width, 12.0);
      expect(input.height, 6.0);
      expect(input.weight, 0.5);
      expect(input.isFragile, isTrue);
      expect(input.ecoFriendly, isTrue);
    });

    test('toRecommendationResult provides complete analytical recommendation payload', () {
      final record = PackagingRecord(
        id: 10,
        itemName: 'Fresh Tomato',
        length: 30.0,
        width: 20.0,
        height: 15.0,
        weight: 5.0,
        isFragile: false,
        ecoFriendly: true,
        createdAt: DateTime(2026, 9, 26),
        recommendedBoxType: 'Corrugated Kraft Box (5-Ply)',
        recommendedDimensions: '30x20x15 cm',
        boxVolumeCm3: 9000,
        itemVolumeCm3: 7500,
        spaceUtilizationPct: 83.3,
        cushioningMaterial: 'Kraft Pad',
        estimatedCost: 3.10,
        sustainabilityScore: 96.5,
        notes: 'Ventilated box structure.',
      );

      final rec = record.toRecommendationResult();

      expect(rec.recommendedBoxType, 'Corrugated Kraft Box (5-Ply)');
      expect(rec.estimatedCost, 3.10);
      expect(rec.sustainabilityScore, 96.5);
      expect(rec.notes, 'Ventilated box structure.');
    });

    test('toJson produces structured dictionary with formatted_date', () {
      final record = PackagingRecord(
        id: 42,
        userId: 7,
        itemName: 'Tomato',
        length: 30.0,
        width: 20.0,
        height: 15.0,
        weight: 5.0,
        isFragile: true,
        ecoFriendly: true,
        createdAt: DateTime(2026, 9, 26, 12, 0),
        recommendedBoxType: 'Corrugated Kraft Box',
        recommendedDimensions: '30x20x15 cm',
        boxVolumeCm3: 9000,
        itemVolumeCm3: 7500,
        spaceUtilizationPct: 83.3,
        cushioningMaterial: 'Kraft Pad',
        estimatedCost: 3.10,
        sustainabilityScore: 96.5,
      );

      final map = record.toJson();
      expect(map['id'], 42);
      expect(map['user_id'], 7);
      expect(map['item_name'], 'Tomato');
      expect(map['formatted_date'], '26 Sep 2026');
      expect(map['estimated_cost'], 3.10);
      expect(map['sustainability_score'], 96.5);
    });
  });
}
