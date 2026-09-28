import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ModernCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final bool enableHover;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const ModernCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 16,
    this.backgroundColor = AppTheme.surfaceWhite,
    this.borderColor = AppTheme.borderSubtle,
    this.borderWidth = 1.0,
    this.enableHover = false,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  State<ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<ModernCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = widget.enableHover && _isHovered
        ? AppTheme.primaryTeal.withValues(alpha: 0.5)
        : widget.borderColor;

    return MouseRegion(
      onEnter: (_) {
        if (widget.enableHover) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (widget.enableHover) setState(() => _isHovered = false);
      },
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: widget.width,
        height: widget.height,
        transform: Matrix4.translationValues(
          0,
          widget.enableHover && _isHovered ? -4 : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: effectiveBorderColor,
            width: widget.borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: widget.enableHover && _isHovered ? 0.08 : 0.03),
              blurRadius: widget.enableHover && _isHovered ? 16 : 8,
              offset: Offset(0, widget.enableHover && _isHovered ? 6 : 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            splashColor: AppTheme.primaryTeal.withValues(alpha: 0.05),
            highlightColor: Colors.transparent,
            child: Padding(
              padding: widget.padding,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
