import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/clipboard_item.dart';
import '../providers/clipboard_provider.dart';
import '../services/clipboard_service.dart';
import '../theme/app_colors.dart';
import '../utils/text_styles.dart';
import '../widgets/clipboard_card.dart';
import '../widgets/loading_animations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _fabController;
  late Animation<double> _fabScaleAnimation;
  bool _isSearchFocused = false;
  bool _isBlurEnabled = false;

  @override
  void initState() {
    super.initState();
    
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _fabScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.velvetGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildFilterChips(),
              Expanded(
                child: _buildClipboardList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // App icon with glow effect
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.iosBlue.withValues(alpha: 0.8),
                  AppColors.iosBlue.withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.iosBlue.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.content_paste_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Clipped',
                  style: AppTextStyles.largeTitle.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Consumer<ClipboardProvider>(
                  builder: (context, provider, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${provider.items.length} clips',
                          style: AppTextStyles.callout.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        if (_isBlurEnabled)
                          Text(
                            'Blur mode active',
                            style: AppTextStyles.caption1.copyWith(
                              color: AppColors.iosOrange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Blur toggle button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.cardElevated.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.separatorOpaque.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() => _isBlurEnabled = !_isBlurEnabled);
              },
              icon: Icon(
                _isBlurEnabled ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: _isBlurEnabled ? AppColors.iosOrange : AppColors.textSecondary,
                size: 20,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isSearchFocused 
              ? AppColors.iosBlue.withValues(alpha: 0.5)
              : AppColors.separatorOpaque.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          context.read<ClipboardProvider>().searchItems(value);
        },
        onTap: () => setState(() => _isSearchFocused = true),
        onEditingComplete: () => setState(() => _isSearchFocused = false),
        style: AppTextStyles.callout.copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search clips...',
          hintStyle: AppTextStyles.callout.copyWith(
            color: AppColors.textQuaternary,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _isSearchFocused 
                ? AppColors.iosBlue 
                : AppColors.textQuaternary,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    context.read<ClipboardProvider>().searchItems('');
                  },
                  icon: Icon(
                    Icons.clear_rounded,
                    color: AppColors.textQuaternary,
                    size: 18,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Consumer<ClipboardProvider>(
      builder: (context, provider, child) {
        return Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildFilterChip(
                label: 'All',
                isSelected: provider.selectedType == null && !provider.showFavoritesOnly,
                onTap: () {
                  provider.clearFilters();
                },
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Favorites',
                isSelected: provider.showFavoritesOnly,
                icon: Icons.favorite_rounded,
                onTap: () {
                  provider.toggleFavoritesFilter();
                },
              ),
              const SizedBox(width: 8),
              ...ClipboardItemType.values.map((type) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterChip(
                    label: _getTypeLabel(type),
                    isSelected: provider.selectedType == type,
                    icon: _getTypeIcon(type),
                    onTap: () {
                      provider.filterByType(
                        provider.selectedType == type ? null : type,
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected 
              ? LinearGradient(
                  colors: [
                    AppColors.iosBlue.withValues(alpha: 0.8),
                    AppColors.iosBlue.withValues(alpha: 0.6),
                  ],
                )
              : null,
          color: isSelected ? null : AppColors.cardElevated.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? AppColors.iosBlue.withValues(alpha: 0.5)
                : AppColors.separatorOpaque.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.iosBlue.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected 
                    ? Colors.white 
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.callout.copyWith(
                color: isSelected 
                    ? Colors.white 
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClipboardList() {
    return Consumer<ClipboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildLoadingList();
        }

        if (provider.items.isEmpty && provider.searchQuery.isEmpty) {
          return _buildEmptyState();
        }

        if (provider.items.isEmpty && provider.searchQuery.isNotEmpty) {
          return _buildNoSearchResults();
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: provider.items.length,
          itemBuilder: (context, index) {
            final item = provider.items[index];
            return ClipboardCard(
              item: item,
              index: index,
              isBlurred: _isBlurEnabled,
              onEdit: () => _showEditBottomSheet(item),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: 5,
      itemBuilder: (context, index) {
        return LoadingAnimations.shimmerCard();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.textQuaternary.withValues(alpha: 0.1),
                  AppColors.textQuaternary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.content_paste_rounded,
              size: 60,
              color: AppColors.textQuaternary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No clips yet',
            style: AppTextStyles.title2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Copy something to get started',
            style: AppTextStyles.callout.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 60,
            color: AppColors.textQuaternary,
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: AppTextStyles.title3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: AppTextStyles.callout.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _fabScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabScaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.iosBlue,
                  AppColors.iosBlue.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.iosBlue.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _fabController.forward().then((_) {
                  _fabController.reverse();
                });
                _showCreateBottomSheet();
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCreateBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCreateBottomSheet(),
    );
  }

  Widget _buildCreateBottomSheet() {
    final TextEditingController contentController = TextEditingController();
    final TextEditingController titleController = TextEditingController();
    
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
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
                  Text(
                    'Create Clip',
                    style: AppTextStyles.title3.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
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
            
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Title field
                  TextField(
                    controller: titleController,
                    style: AppTextStyles.callout.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Title (optional)',
                      hintStyle: AppTextStyles.callout.copyWith(
                        color: AppColors.textQuaternary,
                      ),
                      filled: true,
                      fillColor: AppColors.cardElevated.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Content field
                  TextField(
                    controller: contentController,
                    maxLines: 4,
                    style: AppTextStyles.callout.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter content...',
                      hintStyle: AppTextStyles.callout.copyWith(
                        color: AppColors.textQuaternary,
                      ),
                      filled: true,
                      fillColor: AppColors.cardElevated.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
            
            // Actions
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.cardElevated.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.headline.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (contentController.text.isNotEmpty) {
                          context.read<ClipboardProvider>().createManualItem(
                            content: contentController.text,
                            title: titleController.text.isNotEmpty 
                                ? titleController.text 
                                : null,
                          );
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.iosBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Create',
                        style: AppTextStyles.headline.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  void _showEditBottomSheet(ClipboardItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEditBottomSheet(item),
    );
  }

  Widget _buildEditBottomSheet(ClipboardItem item) {
    final TextEditingController contentController = TextEditingController(text: item.content);
    final TextEditingController titleController = TextEditingController(text: item.title ?? '');
    
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
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
                  Text(
                    'Edit Clip',
                    style: AppTextStyles.title3.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
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
            
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Title field
                  TextField(
                    controller: titleController,
                    style: AppTextStyles.callout.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Title (optional)',
                      hintStyle: AppTextStyles.callout.copyWith(
                        color: AppColors.textQuaternary,
                      ),
                      filled: true,
                      fillColor: AppColors.cardElevated.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Content field
                  TextField(
                    controller: contentController,
                    maxLines: 4,
                    style: AppTextStyles.callout.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter content...',
                      hintStyle: AppTextStyles.callout.copyWith(
                        color: AppColors.textQuaternary,
                      ),
                      filled: true,
                      fillColor: AppColors.cardElevated.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
            
            // Actions
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.cardElevated.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.headline.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (contentController.text.isNotEmpty) {
                          // Update the existing item
                          final updatedItem = ClipboardItem(
                            id: item.id,
                            content: contentController.text.trim(),
                            type: ClipboardService.instance.detectContentType(contentController.text.trim()),
                            title: titleController.text.isNotEmpty ? titleController.text.trim() : null,
                            category: item.category,
                            isFavorite: item.isFavorite,
                            createdAt: item.createdAt,
                            lastUsed: item.lastUsed,
                          );
                          
                          context.read<ClipboardProvider>().updateItem(updatedItem);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.iosBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Save',
                        style: AppTextStyles.headline.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  String _getTypeLabel(ClipboardItemType type) {
    switch (type) {
      case ClipboardItemType.text:
        return 'Text';
      case ClipboardItemType.url:
        return 'Links';
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
        return Icons.more_horiz;
    }
  }
} 