import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/clipboard_item.dart';
import '../services/clipboard_service.dart';
import '../services/storage_service.dart';

class ClipboardProvider extends ChangeNotifier {
  final ClipboardService _clipboardService = ClipboardService.instance;
  final StorageService _storageService = StorageService.instance;

  List<ClipboardItem> _items = [];
  List<ClipboardItem> _filteredItems = [];
  String _searchQuery = '';
  ClipboardItemType? _selectedType;
  String? _selectedCategory;
  bool _showFavoritesOnly = false;
  bool _isLoading = false;
  Timer? _clipboardMonitor;

  // Getters
  List<ClipboardItem> get items => _filteredItems;
  List<ClipboardItem> get allItems => _items;
  String get searchQuery => _searchQuery;
  ClipboardItemType? get selectedType => _selectedType;
  String? get selectedCategory => _selectedCategory;
  bool get showFavoritesOnly => _showFavoritesOnly;
  bool get isLoading => _isLoading;
  List<String> get categories => _storageService.getCategories();

  /// Initialize the provider
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      await _storageService.initialize();
      await loadItems();
      _startClipboardMonitoring();
    } catch (e) {
      debugPrint('Error initializing clipboard provider: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load items from storage
  Future<void> loadItems() async {
    _items = _storageService.getAllItems();
    _applyFilters();
    notifyListeners();
  }

  /// Add a new clipboard item
  Future<void> addItem(ClipboardItem item) async {
    try {
      await _storageService.addItem(item);
      await loadItems();
    } catch (e) {
      debugPrint('Error adding item: $e');
    }
  }

  /// Update an existing item
  Future<void> updateItem(ClipboardItem item) async {
    try {
      await _storageService.updateItem(item);
      await loadItems();
    } catch (e) {
      debugPrint('Error updating item: $e');
    }
  }

  /// Delete an item
  Future<void> deleteItem(ClipboardItem item) async {
    try {
      await _storageService.deleteItem(item);
      await loadItems();
    } catch (e) {
      debugPrint('Error deleting item: $e');
    }
  }

  /// Copy item to clipboard and update last used
  Future<void> copyItem(ClipboardItem item) async {
    try {
      await _clipboardService.copyToClipboard(item.content);
      item.updateLastUsed();
      await loadItems();
    } catch (e) {
      debugPrint('Error copying item: $e');
    }
  }

  /// Toggle item favorite status
  Future<void> toggleFavorite(ClipboardItem item) async {
    try {
      item.toggleFavorite();
      await loadItems();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  /// Create new item manually
  Future<void> createManualItem({
    required String content,
    String? title,
    String? category,
  }) async {
    if (content.trim().isEmpty) return;

    final item = _clipboardService.createClipboardItem(
      content.trim(),
      title: title?.trim(),
      category: category?.trim(),
    );

    await addItem(item);
  }

  /// Search items
  void searchItems(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Filter by type
  void filterByType(ClipboardItemType? type) {
    _selectedType = type;
    _applyFilters();
    notifyListeners();
  }

  /// Filter by category
  void filterByCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  /// Toggle favorites filter
  void toggleFavoritesFilter() {
    _showFavoritesOnly = !_showFavoritesOnly;
    _applyFilters();
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedType = null;
    _selectedCategory = null;
    _showFavoritesOnly = false;
    _applyFilters();
    notifyListeners();
  }

  /// Clear all items
  Future<void> clearAllItems() async {
    try {
      await _storageService.clearAllItems();
      await loadItems();
    } catch (e) {
      debugPrint('Error clearing all items: $e');
    }
  }

  /// Delete old items
  Future<void> deleteOldItems(int daysOld) async {
    try {
      await _storageService.deleteOldItems(daysOld);
      await loadItems();
    } catch (e) {
      debugPrint('Error deleting old items: $e');
    }
  }

  /// Get storage statistics
  Map<String, dynamic> getStorageStats() {
    return _storageService.getStorageStats();
  }

  /// Start monitoring clipboard for new content
  void _startClipboardMonitoring() {
    _clipboardMonitor = Timer.periodic(
      const Duration(seconds: 2),
      (timer) async {
        final newContent = await _clipboardService.checkForNewContent();
        if (newContent != null) {
          final item = _clipboardService.createClipboardItem(newContent);
          await addItem(item);
        }
      },
    );
  }

  /// Stop clipboard monitoring
  void _stopClipboardMonitoring() {
    _clipboardMonitor?.cancel();
    _clipboardMonitor = null;
  }

  /// Apply current filters to items
  void _applyFilters() {
    var filtered = List<ClipboardItem>.from(_items);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = _storageService.searchItems(_searchQuery);
    }

    // Apply type filter
    if (_selectedType != null) {
      filtered = filtered.where((item) => item.type == _selectedType).toList();
    }

    // Apply category filter
    if (_selectedCategory != null) {
      filtered = filtered.where((item) => item.category == _selectedCategory).toList();
    }

    // Apply favorites filter
    if (_showFavoritesOnly) {
      filtered = filtered.where((item) => item.isFavorite).toList();
    }

    _filteredItems = filtered;
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopClipboardMonitoring();
    super.dispose();
  }
} 