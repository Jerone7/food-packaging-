import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/services/api_service.dart';
import 'package:ai_packaging_recommender/models/material_catalog_model.dart';

void main() {
  group('ApiService Material Database Tests', () {
    test('getMaterials returns fallback materials when offline', () async {
      final materials = await ApiService.getMaterials(limit: 10);
      expect(materials.isNotEmpty, isTrue);
      expect(materials.length, greaterThanOrEqualTo(5));

      final first = materials.first;
      expect(first.materialId.isNotEmpty, isTrue);
      expect(first.name.isNotEmpty, isTrue);
      expect(first.radarScores.barrierScore, greaterThan(0));
    });

    test('getMaterials supports category and text filtering', () async {
      final bioList = await ApiService.getMaterials(category: 'Biodegradable');
      expect(bioList.isNotEmpty, isTrue);
      for (final m in bioList) {
        expect(m.category.toLowerCase(), contains('biodegradable'));
      }

      final searchList = await ApiService.getMaterials(search: 'Foil');
      expect(searchList.isNotEmpty, isTrue);
      expect(searchList.any((m) => m.name.toLowerCase().contains('foil')), isTrue);
    });

    test('getMaterialById finds valid material', () async {
      final mat = await ApiService.getMaterialById('mat_al_foil_lam_13');
      expect(mat, isNotNull);
      expect(mat!.name, contains('Aluminium Foil'));
      expect(mat.barrierProfile.barrierTier, 'Hermetic Zero-Permeation');
    });

    test('createMaterial adds custom material to in-memory store', () async {
      const customMat = PackagingMaterialDetail(
        materialId: 'mat_custom_test_01',
        name: 'Custom Flax Bio-Resin',
        category: 'Biodegradable Bio-Polymer',
        polymerFamily: 'BIO_RESIN',
        structure: 'Flax / Polyhydroxyalkanoate Matrix',
        barrierProfile: BarrierProfileDetail(
          otrCcM2Day: 12.0,
          wvtrGM2Day: 8.0,
          thicknessMicrons: 40.0,
          barrierTier: 'High Barrier',
        ),
        mechanicalProfile: MechanicalProfile(
          tensileStrengthMpa: 45.0,
          punctureResistanceN: 35.0,
          formFactor: 'Flexible Pouch',
        ),
        thermalProfile: ThermalProfile(
          tempMinC: -10.0,
          tempMaxC: 85.0,
          thermalClass: 'Ambient',
        ),
        opticalProfile: OpticalProfile(
          opticalClarity: 'Translucent',
        ),
        environmentalProfile: EnvironmentalProfile(
          sustainabilityScore: 97.0,
          isBiodegradable: true,
          isRecyclable: true,
        ),
        economicProfile: EconomicProfile(
          costCategory: 'Commercial Standard',
          estimatedUnitCostInr: 4.10,
        ),
        radarScores: MaterialRadarScores(
          barrierScore: 80.0,
          mechanicalScore: 50.0,
          sustainabilityScore: 97.0,
          thermalScore: 60.0,
          costEfficiencyScore: 63.0,
          opticalScore: 65.0,
        ),
      );

      final created = await ApiService.createMaterial(customMat);
      expect(created.materialId, 'mat_custom_test_01');

      final retrieved = await ApiService.getMaterialById('mat_custom_test_01');
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Custom Flax Bio-Resin');
      expect(retrieved.environmentalProfile.sustainabilityScore, 97.0);
    });

    test('compareMaterials synthesizes multi-material radar comparison', () async {
      final result = await ApiService.compareMaterials([
        'mat_bio_emap_01',
        'mat_al_foil_lam_13',
        'mat_sbs_paperboard_22',
      ]);

      expect(result.materials.length, 3);
      expect(result.radarDatasets.length, 3);
      expect(result.bestInClassHighlights.isNotEmpty, isTrue);
      expect(result.tradeOffAnalysis.isNotEmpty, isTrue);
    });

    test('getMaterialCategories provides grouped category counts', () async {
      final categories = await ApiService.getMaterialCategories();
      expect(categories.isNotEmpty, isTrue);
      for (final cat in categories) {
        expect(cat.count, greaterThan(0));
        expect(cat.sampleMaterials.isNotEmpty, isTrue);
      }
    });
  });
}
