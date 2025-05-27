import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/clipboard_item.dart';
import '../providers/clipboard_provider.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';

class ClipboardCard extends StatefulWidget {
  final ClipboardItem item;

  const ClipboardCard({
    super.key,
    required this.item,
  });

  @override
  State<ClipboardCard> createState() => _ClipboardCardState();
}

class _ClipboardCardState extends State<ClipboardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTap() async {
    final provider = context.read<ClipboardProvider>();
    await provider.copyItem(widget.item);
    
    if (mounted) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Copied to clipboard'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.cardBackground,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Widget _buildTypeIcon() {
    IconData iconData;
    Color iconColor = AppColors.accent;

    switch (widget.item.type) {
      case ClipboardItemType.url:
        iconData = Icons.link_rounded;
        iconColor = AppColors.accent;
        break;
      case ClipboardItemType.email:
        iconData = Icons.email_outlined;
        iconColor = AppColors.success;
        break;
      case ClipboardItemType.phone:
        iconData = Icons.phone_outlined;
        iconColor = AppColors.warning;
        break;
      case ClipboardItemType.text:
      case ClipboardItemType.other:
      default:
        iconData = Icons.text_snippet_outlined;
        iconColor = AppColors.textSecondary;
        break;
    }

    return Icon(
      iconData,
      color: iconColor,
      size: 20,
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: _onTap,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                gradient: _isPressed 
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.cardBackgroundElevated,
                          AppColors.cardBackground,
                        ],
                      )
                    : AppColors.cardGradient,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.border,
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row
                        Row(
                          children: [
                            _buildTypeIcon(),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.item.displayTitle,
                                style: AppTextStyles.headline,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.item.isFavorite)
                                  const Icon(
                                    Icons.favorite,
                                    color: AppColors.error,
                                    size: 16,
                                  ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () {
                                    final provider = context.read<ClipboardProvider>();
                                    provider.toggleFavorite(widget.item);
                                    HapticFeedback.lightImpact();
                                  },
                                  icon: Icon(
                                    widget.item.isFavorite 
                                        ? Icons.favorite 
                                        : Icons.favorite_border,
                                    color: widget.item.isFavorite 
                                        ? AppColors.error 
                                        : AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Content
                        Text(
                          widget.item.previewContent,
                          style: AppTextStyles.bodySecondary,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        
                        // Footer row
                        Row(
                          children: [
                            if (widget.item.category != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.accent.withOpacity(0.3),
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  widget.item.category!,
                                  style: AppTextStyles.caption1.copyWith(
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: Text(
                                _formatTimestamp(widget.item.lastUsed),
                                style: AppTextStyles.caption1,
                              ),
                            ),
                            Icon(
                              Icons.content_copy,
                              color: AppColors.textTertiary,
                              size: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 