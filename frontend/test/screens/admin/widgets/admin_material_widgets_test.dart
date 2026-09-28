import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/admin_model.dart';
import 'package:ai_packaging_recommender/screens/admin/widgets/admin_material_table_view.dart';
import 'package:ai_packaging_recommender/screens/admin/widgets/add_edit_material_dialog.dart';

void main() {
  Widget createTestWidget(Widget child, {Size size = const Size(1200, 800)}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: size.width,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  group('AdminMaterialTableView Widget Tests', () {
    final sampleMaterials = [
      const AdminMaterialItemModel(
        id: 1,
        materialId: 'mat_01',
        name: 'Micro-Perforated Bio-Film',
        category: 'Biodegradable Bio-Polymer',
        polymerFamily: 'BREATHABLE_BIO_EMAP',
        structure: 'PLA/PBAT 30 µm',
        thicknessMicrons: 30.0,
        otr: 4500.0,
        wvtr: 65.0,
        sustainabilityScore: 96.0,
        estimatedUnitCostInr: 3.85,
        isActiveEntry: true,
      ),
      const AdminMaterialItemModel(
        id: 2,
        materialId: 'mat_02',
        name: 'Corrugated Kraft Box',
        category: 'Paper & Fiber Board',
        polymerFamily: 'CELLULOSE_KRAFT_LINED',
        thicknessMicrons: 400.0,
        sustainabilityScore: 96.5,
        estimatedUnitCostInr: 3.10,
        isActiveEntry: false,
      ),
    ];

    testWidgets('renders material rows, metrics, status chip, and triggers actions', (tester) async {
      AdminMaterialItemModel? editedMat;
      AdminMaterialItemModel? toggledMat;
      bool addedMat = false;

      await tester.pumpWidget(
        createTestWidget(
          AdminMaterialTableView(
            materials: sampleMaterials,
            onSearchChanged: (_) {},
            onCategoryChanged: (_) {},
            onAddMaterial: () => addedMat = true,
            onEditMaterial: (m) => editedMat = m,
            onToggleStatus: (m) => toggledMat = m,
            onDeleteMaterial: (_) {},
          ),
        ),
      );

      expect(find.text('Micro-Perforated Bio-Film'), findsOneWidget);
      expect(find.text('mat_01 • BREATHABLE_BIO_EMAP'), findsOneWidget);
      expect(find.text('Corrugated Kraft Box'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Archived'), findsOneWidget);

      await tester.tap(find.text('Add Material'));
      expect(addedMat, true);

      await tester.tap(find.byIcon(Icons.edit_outlined).first);
      expect(editedMat?.materialId, 'mat_01');

      await tester.tap(find.byIcon(Icons.toggle_on_rounded).first);
      expect(toggledMat?.materialId, 'mat_01');
    });

    testWidgets('renders empty state when materials list is empty', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AdminMaterialTableView(
            materials: const [],
            onSearchChanged: (_) {},
            onCategoryChanged: (_) {},
            onAddMaterial: () {},
            onEditMaterial: (_) {},
            onToggleStatus: (_) {},
            onDeleteMaterial: (_) {},
          ),
        ),
      );

      expect(find.text('No packaging materials found'), findsOneWidget);
    });
  });

  group('AddEditMaterialDialog Widget Tests', () {
    testWidgets('populates fields and submits payload on save', (tester) async {
      Map<String, dynamic>? savedPayload;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddEditMaterialDialog(
              initialMaterial: const AdminMaterialItemModel(
                id: 1,
                materialId: 'mat_custom_01',
                name: 'High-Barrier Bio-PET',
                category: 'Metallized Film',
                polymerFamily: 'METALLIZED_BARRIER',
                structure: 'PET / Alu-Oxide / Bio-PE',
                thicknessMicrons: 25.0,
                otr: 0.65,
                wvtr: 0.85,
                sustainabilityScore: 88.0,
                estimatedUnitCostInr: 2.95,
                gasFlushCompatible: true,
                isActiveEntry: true,
              ),
              onSave: (payload) async {
                savedPayload = payload;
              },
            ),
          ),
        ),
      );

      expect(find.text('Edit Packaging Material'), findsOneWidget);
      expect(find.text('Substrate Identification & Category'), findsOneWidget);
      expect(find.text('Barrier & Gas Permeability'), findsOneWidget);

      await tester.tap(find.text('Save Material'));
      await tester.pumpAndSettle();

      expect(savedPayload != null, true);
      expect(savedPayload!['material_id'], 'mat_custom_01');
      expect(savedPayload!['name'], 'High-Barrier Bio-PET');
      expect(savedPayload!['estimated_unit_cost_inr'], 2.95);
      expect(savedPayload!['is_active_entry'], true);
    });
  });
}
