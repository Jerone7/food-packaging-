import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/star_rating_widget.dart';

void main() {
  group('StarRatingWidget Component Tests', () {
    testWidgets('renders 5 stars with 5 filled for 5/5 rating', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: StarRatingWidget(
                rating: 5,
                maxRating: 5,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star_rounded), findsNWidgets(5));
      expect(find.byIcon(Icons.star_outline_rounded), findsNothing);
      expect(find.text('5/5'), findsOneWidget);
    });

    testWidgets('renders 4 filled stars and 1 outline star for 4/5 rating', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: StarRatingWidget(
                rating: 4,
                maxRating: 5,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star_rounded), findsNWidgets(4));
      expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(1));
      expect(find.text('4/5'), findsOneWidget);
    });

    testWidgets('renders 3 filled stars and 2 outline stars for 3/5 rating', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: StarRatingWidget(
                rating: 3,
                maxRating: 5,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
      expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(2));
      expect(find.text('3/5'), findsOneWidget);
    });

    testWidgets('renders compact badge mode with Container styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: StarRatingBar(
                rating: 4,
                size: 16.0,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(StarRatingWidget), findsOneWidget);
      expect(find.text('4/5'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(4));
    });

    testWidgets('clamps out-of-bounds ratings safely', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: StarRatingWidget(
                rating: 10, // out of bounds > 5
                maxRating: 5,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star_rounded), findsNWidgets(5));
      expect(find.text('5/5'), findsOneWidget);
    });
  });
}
