import 'package:flutter/material.dart';

/// Reusable Star Rating Indicator Widget (Module 8).
/// Renders golden rating stars with optional numerical score badge and high-contrast support.
class StarRatingWidget extends StatelessWidget {
  final int rating;
  final int maxRating;
  final double size;
  final double spacing;
  final Color starColor;
  final Color emptyColor;
  final bool showLabel;
  final TextStyle? labelStyle;
  final bool compact;

  const StarRatingWidget({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 18.0,
    this.spacing = 2.0,
    this.starColor = const Color(0xFFF59E0B), // Vibrant Amber
    this.emptyColor = const Color(0xFFCBD5E1), // Slate 300
    this.showLabel = true,
    this.labelStyle,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final clampedRating = rating.clamp(0, maxRating);

    final starsRow = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(maxRating, (index) {
        final isFilled = index < clampedRating;
        return Padding(
          padding: EdgeInsets.only(right: index < maxRating - 1 ? spacing : 0),
          child: Icon(
            isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: isFilled ? starColor : emptyColor,
            size: size,
            semanticLabel: isFilled ? 'Filled Star' : 'Empty Star',
          ),
        );
      }),
    );

    if (!showLabel) {
      return Semantics(
        label: 'Rating: $clampedRating out of $maxRating stars',
        child: starsRow,
      );
    }

    final defaultTextStyle = TextStyle(
      fontSize: size * 0.78,
      fontWeight: FontWeight.w700,
      color: starColor,
      letterSpacing: 0.2,
    );

    final effectiveStyle = labelStyle ?? defaultTextStyle;

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: starColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: starColor.withValues(alpha: 0.24)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            starsRow,
            const SizedBox(width: 6),
            Text(
              '$clampedRating/$maxRating',
              style: effectiveStyle,
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        starsRow,
        const SizedBox(width: 6),
        Text(
          '$clampedRating/$maxRating',
          style: effectiveStyle,
        ),
      ],
    );
  }
}

/// Convenience Star Rating Bar for inline headline cards
class StarRatingBar extends StatelessWidget {
  final int rating;
  final String? customLabel;
  final double size;

  const StarRatingBar({
    super.key,
    required this.rating,
    this.customLabel,
    this.size = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return StarRatingWidget(
      rating: rating,
      size: size,
      compact: true,
      labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: Color(0xFFD97706),
      ),
    );
  }
}
