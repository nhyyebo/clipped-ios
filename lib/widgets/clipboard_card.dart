import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/clipboard_item.dart';
import '../providers/clipboard_provider.dart';
import '../services/clipboard_service.dart';
import '../theme/app_colors.dart';
import '../utils/text_styles.dart';
import 'content_type_icon.dart';
import 'loading_animations.dart';

class ClipboardCard extends StatefulWidget {
  final ClipboardItem item;
  final VoidCallback? onTap;
  final int index;

  const ClipboardCard({
    super.key,
    required this.item,
    this.onTap,
    this.index = 0,
  });

  @override
  State<ClipboardCard> createState() => _ClipboardCardState();
}

class _ClipboardCardState extends State<ClipboardCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isPressed = false;
  bool _isDeleting = false;
  bool _showDeleteOptions = false;

  @override
  void initState() {
    super.initState();
    
    // Scale animation for press effect
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // Fade animation for entrance
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 300 + (widget.index * 50)),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    // Slide animation for deletion
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInCubic,
    ));

    // Start entrance animation
    _fadeController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleCopy() async {
    setState(() => _isPressed = true);
    
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    // Copy to clipboard
    await ClipboardService.instance.copyToClipboard(widget.item.content);
    
    // Update last used
    widget.item.updateLastUsed();
    context.read<ClipboardProvider>().notifyListeners();
    
    // Show success feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Copied to clipboard',
                style: AppTextStyles.callout.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.cardElevated,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      setState(() => _isPressed = false);
    }
  }

  Future<void> _handleDelete() async {
    setState(() => _isDeleting = true);
    
    // Haptic feedback
    HapticFeedback.mediumImpact();
    
    // Start slide animation
    await _slideController.forward();
    
    // Delete the item
    if (mounted) {
      context.read<ClipboardProvider>().deleteItem(widget.item);
    }
  }

  void _showDeleteConfirmation() {
    HapticFeedback.lightImpact();
    setState(() => _showDeleteOptions = true);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDeleteBottomSheet(),
    ).then((_) {
      if (mounted) {
        setState(() => _showDeleteOptions = false);
      }
    });
  }

  Widget _buildDeleteBottomSheet() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.velvetGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.separatorOpaque,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.delete_rounded,
                  color: AppColors.error,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Delete Clipboard Item',
                  style: AppTextStyles.title3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This action cannot be undone',
                  style: AppTextStyles.callout.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: AppColors.separatorOpaque,
            height: 1,
          ),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.headline.copyWith(
                      color: AppColors.iosBlue,
                    ),
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: AppColors.separatorOpaque,
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleDelete();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Delete',
                    style: AppTextStyles.headline.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_fadeAnimation, _slideAnimation]),
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.scale(
              scale: _fadeAnimation.value * 0.95 + 0.05,
              child: _buildCard(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleCopy,
          onLongPress: _showDeleteConfirmation,
          borderRadius: BorderRadius.circular(20),
          splashColor: AppColors.iosBlue.withOpacity(0.1),
          highlightColor: AppColors.iosBlue.withOpacity(0.05),
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isPressed ? 0.95 : _scaleAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.cardGradient,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.separatorOpaque.withOpacity(0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: _buildCardContent(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Content type icon
          ContentTypeIcon(
            type: widget.item.type,
            size: 24,
          ),
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title/Preview
                Text(
                  widget.item.displayTitle,
                  style: AppTextStyles.headline.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                
                // Content preview
                if (widget.item.content != widget.item.displayTitle)
                  Text(
                    widget.item.previewContent,
                    style: AppTextStyles.callout.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                
                const SizedBox(height: 8),
                
                // Metadata row
                Row(
                  children: [
                    ContentTypeBadge(
                      type: widget.item.type,
                      isCompact: true,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimestamp(widget.item.lastUsed),
                      style: AppTextStyles.caption1.copyWith(
                        color: AppColors.textQuaternary,
                      ),
                    ),
                    const Spacer(),
                    if (widget.item.isFavorite)
                      Icon(
                        Icons.favorite_rounded,
                        color: AppColors.iosRed,
                        size: 16,
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          // Action indicators
          const SizedBox(width: 12),
          Column(
            children: [
              Icon(
                Icons.content_copy_rounded,
                color: AppColors.textQuaternary,
                size: 18,
              ),
              const SizedBox(height: 4),
              Icon(
                Icons.more_horiz_rounded,
                color: AppColors.textQuaternary,
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
} 