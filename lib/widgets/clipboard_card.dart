import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../models/clipboard_item.dart';
import '../providers/clipboard_provider.dart';
import '../services/clipboard_service.dart';
import '../theme/app_colors.dart';
import '../utils/text_styles.dart';
import 'content_type_icon.dart';

class ClipboardCard extends StatefulWidget {
  final ClipboardItem item;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final int index;
  final bool isBlurred;

  const ClipboardCard({
    super.key,
    required this.item,
    this.onTap,
    this.onEdit,
    this.index = 0,
    this.isBlurred = false,
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
    if (mounted) {
      context.read<ClipboardProvider>().updateItem(widget.item);
    }
    
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
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDeleteBottomSheet(),
    );
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

  void _showActionsBottomSheet() {
    HapticFeedback.lightImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildActionsBottomSheet(),
    );
  }

  Widget _buildActionsBottomSheet() {
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
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                ContentTypeIcon(
                  type: widget.item.type,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.item.displayTitle,
                    style: AppTextStyles.headline.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Actions
          Column(
            children: [
              _buildActionTile(
                icon: Icons.content_copy_rounded,
                title: 'Copy',
                subtitle: 'Copy to clipboard',
                onTap: () {
                  Navigator.pop(context);
                  _handleCopy();
                },
              ),
              _buildActionTile(
                icon: Icons.edit_rounded,
                title: 'Edit',
                subtitle: 'Edit this clip',
                onTap: () {
                  Navigator.pop(context);
                  if (widget.onEdit != null) {
                    widget.onEdit!();
                  }
                },
              ),
              _buildActionTile(
                icon: widget.item.isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                title: widget.item.isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                subtitle: widget.item.isFavorite ? 'Remove from favorites' : 'Add to favorites',
                color: widget.item.isFavorite ? AppColors.iosRed : null,
                onTap: () {
                  Navigator.pop(context);
                  _toggleFavorite();
                },
              ),
              _buildActionTile(
                icon: Icons.share_rounded,
                title: 'Share',
                subtitle: 'Share this clip',
                onTap: () {
                  Navigator.pop(context);
                  _shareClip();
                },
              ),
              _buildActionTile(
                icon: Icons.delete_rounded,
                title: 'Delete',
                subtitle: 'Delete this clip',
                color: AppColors.iosRed,
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation();
                },
              ),
            ],
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: color ?? AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.callout.copyWith(
                      color: color ?? AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption1.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleFavorite() {
    HapticFeedback.lightImpact();
    final updatedItem = ClipboardItem(
      id: widget.item.id,
      content: widget.item.content,
      type: widget.item.type,
      title: widget.item.title,
      category: widget.item.category,
      isFavorite: !widget.item.isFavorite,
      createdAt: widget.item.createdAt,
      lastUsed: widget.item.lastUsed,
    );
    
    context.read<ClipboardProvider>().updateItem(updatedItem);
  }

  void _shareClip() {
    // TODO: Implement share functionality
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Share functionality coming soon!',
          style: AppTextStyles.callout.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.cardElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
          onLongPress: _showActionsBottomSheet,
          borderRadius: BorderRadius.circular(20),
          splashColor: AppColors.iosBlue.withValues(alpha: 0.1),
          highlightColor: AppColors.iosBlue.withValues(alpha: 0.05),
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
                      color: AppColors.separatorOpaque.withValues(alpha: 0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
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
                widget.isBlurred
                    ? ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 5.0,
                            sigmaY: 5.0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.item.displayTitle,
                              style: AppTextStyles.headline.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      )
                    : Text(
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
                  widget.isBlurred
                      ? ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 5.0,
                              sigmaY: 5.0,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.item.previewContent,
                                style: AppTextStyles.callout.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        )
                      : Text(
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