import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/admin_model.dart';
import 'package:ai_packaging_recommender/screens/admin/widgets/admin_food_table_view.dart';
import 'package:ai_packaging_recommender/screens/admin/widgets/add_edit_food_dialog.dart';
import 'package:ai_packaging_recommender/screens/admin/widgets/scientific_properties_drawer.dart';

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

  group('AdminFoodTableView Widget Tests', () {
    final sampleFoods = [
      const AdminFoodItemModel(
        id: 1,
        name: 'Fresh Tomato',
        category: 'Produce',
        scientificName: 'Solanum lycopersicum',
        moisture: 94.5,
        ph: 4.3,
        fat: 0.2,
        respirationClass: 'High',
      ),
      const AdminFoodItemModel(
        id: 2,
        name: 'Potato Chips',
        category: 'Snacks & Wafers',
        moisture: 2.5,
        ph: 6.2,
        fat: 34.0,
        respirationClass: 'Non-respiring',
      ),
    ];

    testWidgets('renders food table with rows and action buttons', (tester) async {
      AdminFoodItemModel? editedFood;
      AdminFoodItemModel? traitsFood;
      bool addedFood = false;

      await tester.pumpWidget(
        createTestWidget(
          AdminFoodTableView(
            foods: sampleFoods,
            onSearchChanged: (_) {},
            onCategoryChanged: (_) {},
            onAddFood: () => addedFood = true,
            onEditFood: (f) => editedFood = f,
            onEditScientificProperties: (f) => traitsFood = f,
            onDeleteFood: (_) {},
          ),
        ),
      );

      expect(find.text('Fresh Tomato'), findsOneWidget);
      expect(find.text('Solanum lycopersicum'), findsOneWidget);
      expect(find.text('Potato Chips'), findsOneWidget);
      expect(find.text('Add Commodity'), findsOneWidget);

      await tester.tap(find.text('Add Commodity'));
      expect(addedFood, true);

      await tester.tap(find.text('Traits').first);
      expect(traitsFood?.name, 'Fresh Tomato');

      await tester.tap(find.byIcon(Icons.edit_outlined).first);
      expect(editedFood?.name, 'Fresh Tomato');
    });

    testWidgets('renders empty state when foods is empty', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AdminFoodTableView(
            foods: const [],
            onSearchChanged: (_) {},
            onCategoryChanged: (_) {},
            onAddFood: () {},
            onEditFood: (_) {},
            onEditScientificProperties: (_) {},
            onDeleteFood: (_) {},
          ),
        ),
      );

      expect(find.text('No food commodities found'), findsOneWidget);
    });
  });

  group('AddEditFoodDialog Widget Tests', () {
    testWidgets('populates fields and submits payload on save', (tester) async {
      Map<String, dynamic>? savedPayload;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddEditFoodDialog(
              initialFood: const AdminFoodItemModel(
                id: 1,
                name: 'Fresh Mango',
                category: 'Produce',
                scientificName: 'Mangifera indica',
                moisture: 84.0,
                ph: 4.1,
                fat: 0.4,
              ),
              onSave: (payload) async {
                savedPayload = payload;
              },
            ),
          ),
        ),
      );

      expect(find.text('Edit Food Commodity'), findsOneWidget);
      expect(find.text('Fresh Mango'), findsOneWidget);
      expect(find.text('Mangifera indica'), findsOneWidget);

      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(savedPayload != null, true);
      expect(savedPayload!['name'], 'Fresh Mango');
      expect(savedPayload!['category'], 'Produce');
      expect(savedPayload!['moisture'], 84.0);
    });
  });

  group('ScientificPropertiesDrawer Widget Tests', () {
    testWidgets('renders 14-property fields and saves changes', (tester) async {
      Map<String, dynamic>? savedProps;

      const foodDetail = AdminFoodDetailModel(
        id: 1,
        name: 'Fresh Tomato',
        category: 'Produce',
        scientificProperties: {
          'respiration_rate_20c': 32.0,
          'respiration_rate_5c': 8.5,
          'chilling_injury_threshold_c': 10.0,
          'optimum_temp_min_c': 12.0,
          'optimum_temp_max_c': 15.0,
          'ambient_shelf_life_days': 7,
          'refrigerated_shelf_life_days': 21,
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScientificPropertiesDrawer(
              food: foodDetail,
              onSave: (payload) async {
                savedProps = payload;
              },
            ),
          ),
        ),
      );

      expect(find.text('Postharvest Scientific Traits'), findsOneWidget);
      expect(find.text('Fresh Tomato'), findsOneWidget);
      expect(find.text('RR at 20°C (mg CO2/kg·h)'), findsOneWidget);
      expect(find.text('Optimum Temperature & RH Window'), findsOneWidget);

      await tester.tap(find.text('Save Scientific Traits'));
      await tester.pumpAndSettle();

      expect(savedProps != null, true);
      expect(savedProps!['respiration_rate_20c'], 32.0);
      expect(savedProps!['ambient_shelf_life_days'], 7);
    });
  });
}
