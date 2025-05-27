import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'clipboard_item.g.dart';

@HiveType(typeId: 0)
class ClipboardItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String content;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  DateTime lastUsed;

  @HiveField(4)
  ClipboardItemType type;

  @HiveField(5)
  String? category;

  @HiveField(6)
  bool isFavorite;

  @HiveField(7)
  String? title;

  ClipboardItem({
    String? id,
    required this.content,
    DateTime? createdAt,
    DateTime? lastUsed,
    this.type = ClipboardItemType.text,
    this.category,
    this.isFavorite = false,
    this.title,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        lastUsed = lastUsed ?? DateTime.now();

  void updateLastUsed() {
    lastUsed = DateTime.now();
    save();
  }

  void toggleFavorite() {
    isFavorite = !isFavorite;
    save();
  }

  void updateContent(String newContent) {
    content = newContent;
    lastUsed = DateTime.now();
    save();
  }

  String get displayTitle {
    if (title != null && title!.isNotEmpty) {
      return title!;
    }
    
    // Auto-generate title from content
    if (content.length <= 30) {
      return content;
    }
    return '${content.substring(0, 30)}...';
  }

  String get previewContent {
    if (content.length <= 100) {
      return content;
    }
    return '${content.substring(0, 100)}...';
  }

  @override
  String toString() {
    return 'ClipboardItem(id: $id, content: $content, type: $type)';
  }
}

@HiveType(typeId: 1)
enum ClipboardItemType {
  @HiveField(0)
  text,
  
  @HiveField(1)
  url,
  
  @HiveField(2)
  email,
  
  @HiveField(3)
  phone,
  
  @HiveField(4)
  other,
} 