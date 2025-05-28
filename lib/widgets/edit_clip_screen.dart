import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/clipboard_item.dart';
import '../providers/clipboard_provider.dart';
import '../services/clipboard_service.dart';
import '../theme/app_colors.dart';
import '../utils/text_styles.dart';

class EditClipScreen extends StatefulWidget {
  final ClipboardItem item;
  
  const EditClipScreen({
    super.key,
    required this.item,
  });

  @override
  State<EditClipScreen> createState() => _EditClipScreenState();
}

class _EditClipScreenState extends State<EditClipScreen> {
  late final TextEditingController _contentController;
  late final TextEditingController _titleController;
  final FocusNode _contentFocusNode = FocusNode();
  final FocusNode _titleFocusNode = FocusNode();
  
  late String _originalContent;
  late String _originalTitle;
  
  bool get _hasChanges {
    return _contentController.text.trim() != _originalContent ||
           _titleController.text.trim() != _originalTitle;
  }
  
  bool get _isContentEmpty => _contentController.text.trim().isEmpty;

  @override
  void initState() {
    super.initState();
    _originalContent = widget.item.content;
    _originalTitle = widget.item.title ?? '';
    
    _contentController = TextEditingController(text: _originalContent);
    _titleController = TextEditingController(text: _originalTitle);
    
    // Automatically focus on content field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _contentFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    _contentFocusNode.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_isContentEmpty) {
      HapticFeedback.lightImpact();
      
      final updatedItem = ClipboardItem(
        id: widget.item.id,
        content: _contentController.text.trim(),
        type: ClipboardService.instance.detectContentType(_contentController.text.trim()),
        title: _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : null,
        category: widget.item.category,
        isFavorite: widget.item.isFavorite,
        createdAt: widget.item.createdAt,
        lastUsed: widget.item.lastUsed,
      );
      
      context.read<ClipboardProvider>().updateItem(updatedItem);
      Navigator.pop(context);
    }
  }

  void _handleCancel() {
    HapticFeedback.lightImpact();
    // Show confirmation if user has made changes
    if (_hasChanges) {
      _showDiscardDialog();
    } else {
      Navigator.pop(context);
    }
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        title: Text(
          'Discard Changes?',
          style: AppTextStyles.title3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'You have unsaved changes. Are you sure you want to discard them?',
          style: AppTextStyles.callout.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Keep Editing',
              style: AppTextStyles.callout.copyWith(
                color: AppColors.iosBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close edit screen
            },
            child: Text(
              'Discard',
              style: AppTextStyles.callout.copyWith(
                color: AppColors.iosRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.velvetGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Navigation Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.separatorOpaque,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Cancel Button
                      TextButton(
                        onPressed: _handleCancel,
                        style: TextButton.styleFrom(
                          minimumSize: const Size(60, 44),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.callout.copyWith(
                            color: AppColors.iosBlue,
                          ),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Title
                      Text(
                        'Edit Clip',
                        style: AppTextStyles.headline.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Save Button
                      TextButton(
                        onPressed: (_isContentEmpty || !_hasChanges) ? null : _handleSave,
                        style: TextButton.styleFrom(
                          minimumSize: const Size(60, 44),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'Save',
                          style: AppTextStyles.callout.copyWith(
                            color: (_isContentEmpty || !_hasChanges)
                                ? AppColors.textQuaternary 
                                : AppColors.iosBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Section
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.cardElevated.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.separatorOpaque,
                              width: 0.5,
                            ),
                          ),
                          child: TextField(
                            controller: _titleController,
                            focusNode: _titleFocusNode,
                            style: AppTextStyles.callout.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) {
                              _contentFocusNode.requestFocus();
                            },
                            onChanged: (_) {
                              setState(() {}); // Update save button state
                            },
                            decoration: InputDecoration(
                              hintText: 'Title (optional)',
                              hintStyle: AppTextStyles.callout.copyWith(
                                color: AppColors.textQuaternary,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Content Section
                        Text(
                          'Content',
                          style: AppTextStyles.footnote.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.cardElevated.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.separatorOpaque,
                                width: 0.5,
                              ),
                            ),
                            child: TextField(
                              controller: _contentController,
                              focusNode: _contentFocusNode,
                              maxLines: null,
                              expands: true,
                              style: AppTextStyles.callout.copyWith(
                                color: AppColors.textPrimary,
                                height: 1.4,
                              ),
                              textInputAction: TextInputAction.newline,
                              textCapitalization: TextCapitalization.sentences,
                              onChanged: (_) {
                                setState(() {}); // Update save button state
                              },
                              decoration: InputDecoration(
                                hintText: 'Enter or paste your content here...',
                                hintStyle: AppTextStyles.callout.copyWith(
                                  color: AppColors.textQuaternary,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        ),
                        
                        // Character count (optional feedback)
                        if (_contentController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Text(
                                  '${_contentController.text.length} characters',
                                  style: AppTextStyles.caption2.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                                if (_hasChanges) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.iosBlue.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Modified',
                                      style: AppTextStyles.caption2.copyWith(
                                        color: AppColors.iosBlue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                // Bottom padding for keyboard
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 