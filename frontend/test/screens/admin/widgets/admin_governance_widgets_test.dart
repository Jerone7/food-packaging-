import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/admin_model.dart';
import 'package:ai_packaging_recommender/screens/admin/widgets/rule_thresholds_editor.dart';
import 'package:ai_packaging_recommender/screens/admin/widgets/model_registry_card.dart';
import 'package:ai_packaging_recommender/screens/admin/widgets/recommendations_audit_list_view.dart';

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

  group('RuleThresholdsEditor Widget Tests', () {
    testWidgets('renders rule sliders and saves updated configuration', (tester) async {
      RuleThresholdConfigModel? savedRules;

      await tester.pumpWidget(
        createTestWidget(
          RuleThresholdsEditor(
            initialRules: const RuleThresholdConfigModel(
              lipidOxidationFatThresholdPct: 20.0,
              highRespirationMoistureThresholdPct: 78.0,
              acidicCorrosionPhThreshold: 4.5,
            ),
            onSave: (rules) async {
              savedRules = rules;
            },
          ),
        ),
      );

      expect(find.text('Scientific Rule Thresholds'), findsOneWidget);
      expect(find.text('Lipid Oxidation Fat Threshold'), findsOneWidget);
      expect(find.text('20.0%'), findsOneWidget);
      expect(find.text('78.0%'), findsOneWidget);

      await tester.ensureVisible(find.text('Save Rule Thresholds'));
      await tester.tap(find.text('Save Rule Thresholds'));
      await tester.pumpAndSettle();

      expect(savedRules != null, true);
      expect(savedRules!.lipidOxidationFatThresholdPct, 20.0);
      expect(savedRules!.highRespirationMoistureThresholdPct, 78.0);
    });

    testWidgets('reset defaults button resets values', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          RuleThresholdsEditor(
            initialRules: const RuleThresholdConfigModel(
              lipidOxidationFatThresholdPct: 35.0,
            ),
            onSave: (_) async {},
          ),
        ),
      );

      expect(find.text('35.0%'), findsOneWidget);

      await tester.tap(find.text('Reset Defaults'));
      await tester.pumpAndSettle();

      expect(find.text('18.0%'), findsOneWidget);
    });
  });

  group('ModelRegistryCard Widget Tests', () {
    testWidgets('renders active model specifications and fires toggle ML callback', (tester) async {
      bool toggled = false;

      final model = ModelRegistryModel(
        activeModelName: 'RandomForest-v2.3-18D',
        algorithm: 'Random Forest Ensemble (100 Estimators)',
        featureDimension: 18,
        accuracyScore: 0.984,
        isMlEnabled: true,
        isHeuristicFallbackActive: true,
        lastTrainedAt: DateTime.now(),
        versionTag: 'v2.3.0-prod',
      );

      await tester.pumpWidget(
        createTestWidget(
          ModelRegistryCard(
            modelRegistry: model,
            onToggleMl: () => toggled = true,
          ),
        ),
      );

      expect(find.text('AI Model Registry & Engine'), findsOneWidget);
      expect(find.text('RandomForest-v2.3-18D'), findsOneWidget);
      expect(find.text('18 Dimensions'), findsOneWidget);
      expect(find.text('98.4%'), findsOneWidget);
      expect(find.text('ML Active'), findsOneWidget);

      await tester.tap(find.byType(Switch));
      expect(toggled, true);
    });
  });

  group('RecommendationsAuditListView Widget Tests', () {
    final sampleLogs = [
      AdminRecommendationAuditModel(
        id: 1,
        userId: 1,
        userEmail: 'engineer@smartpack.io',
        itemName: 'Fresh Tomato',
        length: 12.0,
        width: 10.0,
        height: 15.0,
        weight: 0.45,
        isFragile: true,
        ecoFriendly: true,
        recommendedBoxType: 'Corrugated Kraft Box (5-Ply)',
        recommendedDimensions: '15x12x18 cm',
        cushioningMaterial: 'Honeycomb Kraft Partitions',
        estimatedCost: 3.10,
        sustainabilityScore: 96.5,
        createdAt: DateTime.now(),
        formattedDate: '27 Sep 2026',
      ),
    ];

    testWidgets('renders audit rows and opens detail modal', (tester) async {
      bool refreshed = false;

      await tester.pumpWidget(
        createTestWidget(
          RecommendationsAuditListView(
            auditLogs: sampleLogs,
            onRefresh: () => refreshed = true,
          ),
        ),
      );

      expect(find.text('System Recommendation Audit Stream'), findsOneWidget);
      expect(find.text('Fresh Tomato'), findsOneWidget);
      expect(find.text('engineer@smartpack.io'), findsOneWidget);
      expect(find.text('Corrugated Kraft Box (5-Ply)'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.refresh_rounded));
      expect(refreshed, true);

      await tester.tap(find.byIcon(Icons.info_outline_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Fresh Tomato Recommendation Audit'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Fresh Tomato Recommendation Audit'), findsNothing);
    });

    testWidgets('renders empty state when audit logs is empty', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          RecommendationsAuditListView(
            auditLogs: const [],
            onRefresh: () {},
          ),
        ),
      );

      expect(find.text('No recommendations recorded in audit trail'), findsOneWidget);
    });
  });
}
