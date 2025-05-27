import 'package:flutter/services.dart';
import '../models/clipboard_item.dart';

class ClipboardService {
  static ClipboardService? _instance;
  static ClipboardService get instance => _instance ??= ClipboardService._();
  ClipboardService._();

  String? _lastClipboardContent;

  /// Copy text to system clipboard
  Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    _lastClipboardContent = text;
  }

  /// Get current clipboard content
  Future<String?> getClipboardContent() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      return data?.text;
    } catch (e) {
      return null;
    }
  }

  /// Check if clipboard has new content
  Future<String?> checkForNewContent() async {
    final currentContent = await getClipboardContent();
    
    if (currentContent != null && 
        currentContent.isNotEmpty && 
        currentContent != _lastClipboardContent) {
      _lastClipboardContent = currentContent;
      return currentContent;
    }
    
    return null;
  }

  /// Detect the type of clipboard content
  ClipboardItemType detectContentType(String content) {
    if (content.isEmpty) return ClipboardItemType.text;

    // Email pattern
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (emailRegex.hasMatch(content.trim())) {
      return ClipboardItemType.email;
    }

    // Phone number pattern (basic)
    final phoneRegex = RegExp(r'^[\+]?[\d\s\-\(\)]{10,}$');
    if (phoneRegex.hasMatch(content.trim())) {
      return ClipboardItemType.phone;
    }

    // URL pattern
    final urlRegex = RegExp(
      r'^(https?|ftp)://[^\s/$.?#].[^\s]*$',
      caseSensitive: false,
    );
    if (urlRegex.hasMatch(content.trim())) {
      return ClipboardItemType.url;
    }

    // Check for domain-like patterns without protocol
    final domainRegex = RegExp(
      r'^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}',
      caseSensitive: false,
    );
    if (domainRegex.hasMatch(content.trim())) {
      return ClipboardItemType.url;
    }

    return ClipboardItemType.text;
  }

  /// Create a clipboard item from content
  ClipboardItem createClipboardItem(
    String content, {
    String? title,
    String? category,
  }) {
    final type = detectContentType(content);
    
    return ClipboardItem(
      content: content,
      type: type,
      title: title,
      category: category,
    );
  }

  /// Format content for display based on type
  String formatContent(ClipboardItem item) {
    switch (item.type) {
      case ClipboardItemType.email:
        return item.content;
      case ClipboardItemType.phone:
        return _formatPhoneNumber(item.content);
      case ClipboardItemType.url:
        return _formatUrl(item.content);
      case ClipboardItemType.text:
      case ClipboardItemType.other:
      default:
        return item.content;
    }
  }

  String _formatPhoneNumber(String phone) {
    // Basic phone formatting
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    } else if (digits.length == 11 && digits.startsWith('1')) {
      return '+1 (${digits.substring(1, 4)}) ${digits.substring(4, 7)}-${digits.substring(7)}';
    }
    
    return phone; // Return original if can't format
  }

  String _formatUrl(String url) {
    // Add protocol if missing
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'https://$url';
    }
    return url;
  }
} 