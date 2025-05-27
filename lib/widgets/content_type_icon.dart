import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/clipboard_item.dart';

class ContentTypeIcon extends StatefulWidget {
  final ClipboardItemType type;
  final double size;
  final bool isAnimated;

  const ContentTypeIcon({
    super.key,
    required this.type,
    this.size = 24,
    this.isAnimated = true,
  });

  @override
  State<ContentTypeIcon> createState() => _ContentTypeIconState();
}

class _ContentTypeIconState extends State<ContentTypeIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    if (widget.isAnimated) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconData = _getIconData(widget.type);
    final color = _getIconColor(widget.type);
    final gradient = _getIconGradient(widget.type);

    Widget iconWidget = Container(
      width: widget.size + 16,
      height: widget.size + 16,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular((widget.size + 16) / 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        iconData,
        size: widget.size,
        color: Colors.white,
      ),
    );

    if (!widget.isAnimated) return iconWidget;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: iconWidget,
          ),
        );
      },
    );
  }

  IconData _getIconData(ClipboardItemType type) {
    switch (type) {
      case ClipboardItemType.text:
        return Icons.text_fields_rounded;
      case ClipboardItemType.url:
        return Icons.link_rounded;
      case ClipboardItemType.email:
        return Icons.email_rounded;
      case ClipboardItemType.phone:
        return Icons.phone_rounded;
      case ClipboardItemType.other:
        return Icons.content_paste_rounded;
    }
  }

  Color _getIconColor(ClipboardItemType type) {
    switch (type) {
      case ClipboardItemType.text:
        return AppColors.typeText;
      case ClipboardItemType.url:
        return AppColors.typeUrl;
      case ClipboardItemType.email:
        return AppColors.typeEmail;
      case ClipboardItemType.phone:
        return AppColors.typePhone;
      case ClipboardItemType.other:
        return AppColors.textTertiary;
    }
  }

  LinearGradient _getIconGradient(ClipboardItemType type) {
    final color = _getIconColor(type);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        color.withOpacity(0.8),
        color.withOpacity(0.6),
        color.withOpacity(0.4),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }
}

// Animated type badge
class ContentTypeBadge extends StatelessWidget {
  final ClipboardItemType type;
  final bool isCompact;

  const ContentTypeBadge({
    super.key,
    required this.type,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final label = _getTypeLabel(type);
    final color = _getTypeColor(type);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 6 : 8,
        vertical: isCompact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getTypeIcon(type),
            size: isCompact ? 12 : 14,
            color: color,
          ),
          if (!isCompact) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: isCompact ? 10 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getTypeLabel(ClipboardItemType type) {
    switch (type) {
      case ClipboardItemType.text:
        return 'Text';
      case ClipboardItemType.url:
        return 'Link';
      case ClipboardItemType.email:
        return 'Email';
      case ClipboardItemType.phone:
        return 'Phone';
      case ClipboardItemType.other:
        return 'Other';
    }
  }

  IconData _getTypeIcon(ClipboardItemType type) {
    switch (type) {
      case ClipboardItemType.text:
        return Icons.text_fields;
      case ClipboardItemType.url:
        return Icons.link;
      case ClipboardItemType.email:
        return Icons.email;
      case ClipboardItemType.phone:
        return Icons.phone;
      case ClipboardItemType.other:
        return Icons.content_paste;
    }
  }

  Color _getTypeColor(ClipboardItemType type) {
    switch (type) {
      case ClipboardItemType.text:
        return AppColors.typeText;
      case ClipboardItemType.url:
        return AppColors.typeUrl;
      case ClipboardItemType.email:
        return AppColors.typeEmail;
      case ClipboardItemType.phone:
        return AppColors.typePhone;
      case ClipboardItemType.other:
        return AppColors.textTertiary;
    }
  }
} 