import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/main.dart';
import 'package:ai_packaging_recommender/screens/landing/home_page.dart';
import 'package:ai_packaging_recommender/widgets/brand_logo.dart';

void main() {
  testWidgets('SmartPackApp smoke test launches HomePage', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartPackApp());
    await tester.pump();
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(BrandLogo), findsWidgets);
  });
}
