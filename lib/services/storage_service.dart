import 'package:hive_flutter/hive_flutter.dart';
import '../models/clipboard_item.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  StorageService._();

  static const String _clipboardBoxName = 'clipboard_items';
  Box<ClipboardItem>? _clipboardBox;

  /// Initialize the storage service
  Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ClipboardItemAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ClipboardItemTypeAdapter());
    }
    
    // Open boxes
    _clipboardBox = await Hive.openBox<ClipboardItem>(_clipboardBoxName);
  }

  /// Get all clipboard items sorted by last used
  List<ClipboardItem> getAllItems() {
    if (_clipboardBox == null) return [];
    
    final items = _clipboardBox!.values.toList();
    items.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
    return items;
  }

  /// Get favorite items
  List<ClipboardItem> getFavoriteItems() {
    return getAllItems().where((item) => item.isFavorite).toList();
  }

  /// Get items by category
  List<ClipboardItem> getItemsByCategory(String category) {
    return getAllItems().where((item) => item.category == category).toList();
  }

  /// Get items by type
  List<ClipboardItem> getItemsByType(ClipboardItemType type) {
    return getAllItems().where((item) => item.type == type).toList();
  }

  /// Add a new clipboard item
  Future<void> addItem(ClipboardItem item) async {
    if (_clipboardBox == null) return;
    
    // Check for duplicates
    final existingItem = _clipboardBox!.values
        .where((existing) => existing.content == item.content)
        .firstOrNull;
    
    if (existingItem != null) {
      // Update existing item's last used time
      existingItem.updateLastUsed();
      return;
    }
    
    await _clipboardBox!.add(item);
    
    // Limit storage to prevent excessive memory usage
    await _enforceStorageLimit();
  }

  /// Update an existing item
  Future<void> updateItem(ClipboardItem item) async {
    await item.save();
  }

  /// Delete an item
  Future<void> deleteItem(ClipboardItem item) async {
    await item.delete();
  }

  /// Delete all items
  Future<void> clearAllItems() async {
    if (_clipboardBox == null) return;
    await _clipboardBox!.clear();
  }

  /// Delete items older than specified days
  Future<void> deleteOldItems(int daysOld) async {
    if (_clipboardBox == null) return;
    
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    final itemsToDelete = _clipboardBox!.values
        .where((item) => item.lastUsed.isBefore(cutoffDate) && !item.isFavorite)
        .toList();
    
    for (final item in itemsToDelete) {
      await item.delete();
    }
  }

  /// Search items by content
  List<ClipboardItem> searchItems(String query) {
    if (query.isEmpty) return getAllItems();
    
    final lowerQuery = query.toLowerCase();
    return getAllItems().where((item) {
      return item.content.toLowerCase().contains(lowerQuery) ||
             (item.title?.toLowerCase().contains(lowerQuery) ?? false) ||
             (item.category?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Get unique categories
  List<String> getCategories() {
    final categories = getAllItems()
        .map((item) => item.category)
        .where((category) => category != null && category.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    
    categories.sort();
    return categories;
  }

  /// Get storage statistics
  Map<String, dynamic> getStorageStats() {
    final items = getAllItems();
    
    return {
      'totalItems': items.length,
      'favoriteItems': items.where((item) => item.isFavorite).length,
      'textItems': items.where((item) => item.type == ClipboardItemType.text).length,
      'urlItems': items.where((item) => item.type == ClipboardItemType.url).length,
      'emailItems': items.where((item) => item.type == ClipboardItemType.email).length,
      'phoneItems': items.where((item) => item.type == ClipboardItemType.phone).length,
      'categories': getCategories().length,
      'oldestItem': items.isNotEmpty 
          ? items.map((item) => item.createdAt).reduce((a, b) => a.isBefore(b) ? a : b)
          : null,
      'newestItem': items.isNotEmpty
          ? items.map((item) => item.createdAt).reduce((a, b) => a.isAfter(b) ? a : b)
          : null,
    };
  }

  /// Enforce storage limit (keep only most recent items)
  Future<void> _enforceStorageLimit({int maxItems = 1000}) async {
    if (_clipboardBox == null) return;
    
    final items = getAllItems();
    if (items.length <= maxItems) return;
    
    // Sort by last used and keep favorites
    final sortedItems = items.where((item) => !item.isFavorite).toList();
    sortedItems.sort((a, b) => a.lastUsed.compareTo(b.lastUsed));
    
    final itemsToDelete = sortedItems.take(items.length - maxItems);
    for (final item in itemsToDelete) {
      await item.delete();
    }
  }

  /// Close storage
  Future<void> close() async {
    await _clipboardBox?.close();
  }
} 