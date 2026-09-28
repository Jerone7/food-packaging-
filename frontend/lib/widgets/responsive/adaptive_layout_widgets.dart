/// Adaptive Container & Responsive Layout Builder Primitives
/// (Module 20: 📱 Responsive Design)
///
/// Provides reusable adaptive layout widgets including ResponsiveLayout,
/// AdaptiveContainer, AdaptiveRowColumn, and ResponsiveWrapGrid.
library adaptive_layout_widgets;

import 'package:flutter/material.dart';
import '../../theme/responsive_layout.dart';

/// A widget that conditionally builds different layouts based on either screen viewport width
/// or local parent container constraints.
class ResponsiveLayout extends StatelessWidget {
  final Widget Function(BuildContext context)? mobile;
  final Widget Function(BuildContext context)? tablet;
  final Widget Function(BuildContext context)? laptop;
  final Widget Function(BuildContext context) desktop;
  final bool useParentConstraints;

  const ResponsiveLayout({
    super.key,
    this.mobile,
    this.tablet,
    this.laptop,
    required this.desktop,
    this.useParentConstraints = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!useParentConstraints) {
      final width = context.screenWidth;
      if (width >= AppBreakpoints.desktopMin) {
        return desktop(context);
      } else if (width >= AppBreakpoints.laptopMin) {
        return (laptop ?? desktop)(context);
      } else if (width >= AppBreakpoints.tabletMin) {
        return (tablet ?? laptop ?? desktop)(context);
      } else {
        return (mobile ?? tablet ?? laptop ?? desktop)(context);
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width >= AppBreakpoints.desktopMin) {
          return desktop(context);
        } else if (width >= AppBreakpoints.laptopMin) {
          return (laptop ?? desktop)(context);
        } else if (width >= AppBreakpoints.tabletMin) {
          return (tablet ?? laptop ?? desktop)(context);
        } else {
          return (mobile ?? tablet ?? laptop ?? desktop)(context);
        }
      },
    );
  }
}

/// Constrains child content to maximum comfortable reading width on widescreen monitors
/// while applying responsive horizontal gutters.
class AdaptiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  const AdaptiveContainer({
    super.key,
    required this.child,
    this.maxWidth = AppBreakpoints.maxContentWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    final horizontalGutter = ResponsiveSpacing.horizontalGutter(context);

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.symmetric(horizontal: horizontalGutter, vertical: 16.0),
          child: child,
        ),
      ),
    );
  }
}

/// Dynamically renders child widgets horizontally as a [Row] on desktop/laptop
/// and vertically as a [Column] on mobile/tablet viewports to prevent RenderFlex overflow.
class AdaptiveRowColumn extends StatelessWidget {
  final List<Widget> children;
  final bool? forceRow;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;

  const AdaptiveRowColumn({
    super.key,
    required this.children,
    this.forceRow,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.spacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final useRow = forceRow ?? context.isDesktopOrLaptop;

    if (useRow) {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: _buildSpacedChildren(children, isHorizontal: true),
      );
    } else {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: _buildSpacedChildren(children, isHorizontal: false),
      );
    }
  }

  List<Widget> _buildSpacedChildren(List<Widget> original, {required bool isHorizontal}) {
    if (original.isEmpty) return [];
    if (spacing <= 0) return original;

    final List<Widget> result = [];
    for (int i = 0; i < original.length; i++) {
      result.add(original[i]);
      if (i < original.length - 1) {
        result.add(isHorizontal ? SizedBox(width: spacing) : SizedBox(height: spacing));
      }
    }
    return result;
  }
}

/// A responsive wrapping grid that distributes cards evenly across available width
/// without fixed row/column constraints, preventing RenderFlex overflows.
class ResponsiveWrapGrid extends StatelessWidget {
  final List<Widget> children;
  final double itemMinWidth;
  final double spacing;
  final double runSpacing;
  final WrapAlignment alignment;

  const ResponsiveWrapGrid({
    super.key,
    required this.children,
    this.itemMinWidth = 280.0,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.alignment = WrapAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        // Calculate number of columns that can fit
        final int crossAxisCount = (availableWidth / (itemMinWidth + spacing)).floor().clamp(1, 6);
        final double itemWidth = (availableWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          alignment: alignment,
          children: children.map((child) {
            return SizedBox(
              width: itemWidth.clamp(100.0, availableWidth),
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}
