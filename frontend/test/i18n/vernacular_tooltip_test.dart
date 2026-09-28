import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/services/locale_service.dart';
import 'package:ai_packaging_recommender/widgets/common/vernacular_tooltip.dart';

void main() {
  group('VernacularGlossary Unit Tests', () {
    test('contains core barrier and packaging terms', () {
      expect(VernacularGlossary.hasTerm('aw'), isTrue);
      expect(VernacularGlossary.hasTerm('otr'), isTrue);
      expect(VernacularGlossary.hasTerm('wvtr'), isTrue);
      expect(VernacularGlossary.hasTerm('emap'), isTrue);
      expect(VernacularGlossary.hasTerm('astm_d6400'), isTrue);
      expect(VernacularGlossary.hasTerm('tensile_strength'), isTrue);
      expect(VernacularGlossary.hasTerm('hermetic_seal'), isTrue);
      expect(VernacularGlossary.hasTerm('biodegradable'), isTrue);
    });

    test('case-insensitive lookup with whitespace trimming', () {
      final def1 = VernacularGlossary.get('AW');
      final def2 = VernacularGlossary.get('  wvtR  ');
      final def3 = VernacularGlossary.get('EMAP');

      expect(def1, isNotNull);
      expect(def1!.key, 'aw');
      expect(def2, isNotNull);
      expect(def2!.key, 'wvtr');
      expect(def3, isNotNull);
      expect(def3!.key, 'emap');
    });

    test('returns null for unknown term', () {
      expect(VernacularGlossary.get('non_existent_chemical_term'), isNull);
      expect(VernacularGlossary.hasTerm('unknown_term'), isFalse);
    });

    test('provides accurate multilingual titles', () {
      final aw = VernacularGlossary.get('aw')!;
      expect(aw.getTitle('en'), contains('Water Activity'));
      expect(aw.getTitle('ta'), contains('நீர் செயல்பாடு'));
      expect(aw.getTitle('hi'), contains('जल गतिविधि'));

      // Fallback for unknown language
      expect(aw.getTitle('fr'), contains('Water Activity'));
    });

    test('provides farmer-friendly plain summaries in all languages', () {
      final otr = VernacularGlossary.get('otr')!;
      expect(otr.getPlainSummary('en'), contains('air leaks'));
      expect(otr.getPlainSummary('ta'), contains('காற்று'));
      expect(otr.getPlainSummary('hi'), contains('हवा'));

      final wvtr = VernacularGlossary.get('wvtr')!;
      expect(wvtr.getPlainSummary('en'), contains('moisture'));
      expect(wvtr.getPlainSummary('ta'), contains('ஈரப்பதம்'));
      expect(wvtr.getPlainSummary('hi'), contains('नमी'));
    });

    test('supports dynamic registration of custom terms', () {
      const custom = VernacularDefinition(
        key: 'custom_barrier',
        termEn: 'Custom Barrier',
        termTa: 'தனிப்பயன் தடுப்பு',
        termHi: 'कस्टम अवरोध',
        descEn: 'English tech desc',
        descTa: 'Tamil tech desc',
        descHi: 'Hindi tech desc',
        plainSummaryEn: 'English plain',
        plainSummaryTa: 'Tamil plain',
        plainSummaryHi: 'Hindi plain',
      );

      VernacularGlossary.register(custom);
      expect(VernacularGlossary.hasTerm('custom_barrier'), isTrue);
      final retrieved = VernacularGlossary.get('custom_barrier');
      expect(retrieved?.termEn, 'Custom Barrier');
      expect(retrieved?.termTa, 'தனிப்பயன் தடுப்பு');
    });
  });

  group('VernacularTooltip Widget Tests', () {
    late LocaleService localeService;

    setUp(() {
      localeService = LocaleService();
      localeService.initForTesting(languageCode: 'en');
    });

    testWidgets('renders child text and info icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VernacularTooltip(
              termKey: 'aw',
              child: Text('Water Activity Label'),
            ),
          ),
        ),
      );

      expect(find.text('Water Activity Label'), findsOneWidget);
      expect(find.byKey(const ValueKey('vernacular_icon_aw')), findsOneWidget);
      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('factory metric constructor works with child', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VernacularTooltip.metric(
              termKey: 'otr',
              child: const Text('OTR: 15 cc/m²/day'),
            ),
          ),
        ),
      );

      expect(find.text('OTR: 15 cc/m²/day'), findsOneWidget);
      expect(find.byKey(const ValueKey('vernacular_icon_otr')), findsOneWidget);
    });

    testWidgets('tap opens vernacular dialog modal with plain summary and science desc',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: VernacularTooltip(
                termKey: 'wvtr',
                child: Text('WVTR Metric'),
              ),
            ),
          ),
        ),
      );

      // Tap on the vernacular widget
      await tester.tap(find.byKey(const ValueKey('vernacular_tap_wvtr')));
      await tester.pumpAndSettle();

      // Dialog is open: verify elements
      expect(find.byKey(const ValueKey('vernacular_dialog_title')), findsOneWidget);
      expect(find.text('Water Vapor Transmission Rate (WVTR)'), findsOneWidget);
      expect(find.byKey(const ValueKey('vernacular_dialog_plain')), findsOneWidget);
      expect(find.textContaining('stops moisture from entering'), findsOneWidget);
      expect(find.byKey(const ValueKey('vernacular_dialog_scientific')), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.byKey(const ValueKey('vernacular_dialog_close')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('vernacular_dialog_plain')), findsNothing);
    });

    testWidgets('vernacular dialog shows Tamil content when active locale is Tamil',
        (tester) async {
      localeService.changeLocaleForTesting(languageCode: 'ta');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: VernacularTooltip(
                termKey: 'aw',
                child: Text('aw'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('vernacular_tap_aw')));
      await tester.pumpAndSettle();

      // Check for Tamil title & plain summary
      expect(find.text('நீர் செயல்பாடு (aw)'), findsOneWidget);
      expect(find.textContaining('உணவு கெட்டுப்போகாமல் பாதுகாக்க'), findsOneWidget);
      expect(find.text('எளிய விவசாயி / உற்பத்தியாளர் வழிகாட்டி'), findsOneWidget);
    });

    testWidgets('vernacular dialog shows Hindi content when active locale is Hindi',
        (tester) async {
      localeService.changeLocaleForTesting(languageCode: 'hi');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: VernacularTooltip(
                termKey: 'emap',
                child: Text('emap'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('vernacular_tap_emap')));
      await tester.pumpAndSettle();

      // Check for Hindi title & plain summary
      expect(find.text('संतुलित संशोधित वायुमंडलीय पैकेजिंग (EMAP)'), findsOneWidget);
      expect(find.textContaining('सांस लेने योग्य पैकेट'), findsOneWidget);
      expect(find.text('सरल किसान व उत्पादक गाइड'), findsOneWidget);
    });

    testWidgets('handles fallback gracefully when term is not in registry',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: VernacularTooltip(
                termKey: 'unknown_metric_x',
                child: Text('Unknown Metric'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('vernacular_tap_unknown_metric_x')));
      await tester.pumpAndSettle();

      expect(find.text('unknown_metric_x'), findsWidgets);
      expect(find.text('Simplified explanation not available.'), findsOneWidget);
    });
  });
}
