import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/clipboard_item.dart';
import '../providers/clipboard_provider.dart';
import '../widgets/clipboard_card.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showCreateItemDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateItemBottomSheet(),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and settings
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Clipped',
                          style: AppTextStyles.largeTitle,
                        ),
                      ),
                      IconButton(
                        onPressed: _showFilterBottomSheet,
                        icon: const Icon(
                          Icons.tune_rounded,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.border,
                        width: 0.5,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: AppTextStyles.body,
                      decoration: InputDecoration(
                        hintText: 'Search clipboard...',
                        hintStyle: AppTextStyles.bodySecondary,
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.textSecondary,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  context.read<ClipboardProvider>().searchItems('');
                                },
                                icon: const Icon(
                                  Icons.clear_rounded,
                                  color: AppColors.textSecondary,
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        context.read<ClipboardProvider>().searchItems(value);
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Clipboard items list
            Expanded(
              child: Consumer<ClipboardProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                      ),
                    );
                  }
                  
                  if (provider.items.isEmpty) {
                    return _buildEmptyState();
                  }
                  
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: provider.items.length,
                    itemBuilder: (context, index) {
                      final item = provider.items[index];
                      return ClipboardCard(item: item);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateItemDialog,
        child: const Icon(
          Icons.add_rounded,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.content_paste_off_rounded,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No clipboard items',
            style: AppTextStyles.title3,
          ),
          const SizedBox(height: 8),
          Text(
            'Copy something or create a new item',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _showCreateItemDialog,
            child: const Text('Create Item'),
          ),
        ],
      ),
    );
  }
}

class _CreateItemBottomSheet extends StatefulWidget {
  @override
  State<_CreateItemBottomSheet> createState() => _CreateItemBottomSheetState();
}

class _CreateItemBottomSheetState extends State<_CreateItemBottomSheet> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _createItem() async {
    if (_contentController.text.trim().isEmpty) return;

    final provider = context.read<ClipboardProvider>();
    await provider.createManualItem(
      content: _contentController.text.trim(),
      title: _titleController.text.trim().isEmpty 
          ? null 
          : _titleController.text.trim(),
      category: _categoryController.text.trim().isEmpty 
          ? null 
          : _categoryController.text.trim(),
    );

    if (mounted) {
      Navigator.of(context).pop();
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              'Create New Item',
              style: AppTextStyles.title2,
            ),
            const SizedBox(height: 20),
            
            // Content field
            TextField(
              controller: _contentController,
              style: AppTextStyles.body,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Content',
                hintText: 'Enter the content to save...',
              ),
            ),
            const SizedBox(height: 16),
            
            // Title field
            TextField(
              controller: _titleController,
              style: AppTextStyles.body,
              decoration: const InputDecoration(
                labelText: 'Title (Optional)',
                hintText: 'Custom title for this item',
              ),
            ),
            const SizedBox(height: 16),
            
            // Category field
            TextField(
              controller: _categoryController,
              style: AppTextStyles.body,
              decoration: const InputDecoration(
                labelText: 'Category (Optional)',
                hintText: 'Add a category tag',
              ),
            ),
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _createItem,
                    child: const Text('Create'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          Text(
            'Filters',
            style: AppTextStyles.title2,
          ),
          const SizedBox(height: 20),
          
          Consumer<ClipboardProvider>(
            builder: (context, provider, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Favorites toggle
                  ListTile(
                    leading: Icon(
                      provider.showFavoritesOnly 
                          ? Icons.favorite 
                          : Icons.favorite_border,
                      color: AppColors.error,
                    ),
                    title: const Text('Favorites Only'),
                    trailing: Switch(
                      value: provider.showFavoritesOnly,
                      onChanged: (_) => provider.toggleFavoritesFilter(),
                      activeColor: AppColors.accent,
                    ),
                    onTap: () => provider.toggleFavoritesFilter(),
                  ),
                  
                  const Divider(),
                  
                  // Type filters
                  Text(
                    'Content Type',
                    style: AppTextStyles.headline,
                  ),
                  const SizedBox(height: 8),
                  
                  Wrap(
                    spacing: 8,
                    children: ClipboardItemType.values.map((type) {
                      final isSelected = provider.selectedType == type;
                      return FilterChip(
                        label: Text(_getTypeLabel(type)),
                        selected: isSelected,
                        onSelected: (selected) {
                          provider.filterByType(selected ? type : null);
                        },
                        selectedColor: AppColors.accent.withOpacity(0.2),
                        checkmarkColor: AppColors.accent,
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Clear filters button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        provider.clearFilters();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Clear All Filters'),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
  
  String _getTypeLabel(ClipboardItemType type) {
    switch (type) {
      case ClipboardItemType.text:
        return 'Text';
      case ClipboardItemType.url:
        return 'URL';
      case ClipboardItemType.email:
        return 'Email';
      case ClipboardItemType.phone:
        return 'Phone';
      case ClipboardItemType.other:
        return 'Other';
    }
  }
} 