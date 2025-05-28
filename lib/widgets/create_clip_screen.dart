import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/clipboard_provider.dart';
import '../theme/app_colors.dart';
import '../utils/text_styles.dart';

class CreateClipScreen extends StatefulWidget {
  const CreateClipScreen({super.key});

  @override
  State<CreateClipScreen> createState() => _CreateClipScreenState();
}

class _CreateClipScreenState extends State<CreateClipScreen> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _contentFocusNode = FocusNode();
  final FocusNode _titleFocusNode = FocusNode();
  
  bool get _isContentEmpty => _contentController.text.trim().isEmpty;

  @override
  void initState() {
    super.initState();
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
      context.read<ClipboardProvider>().createManualItem(
        content: _contentController.text.trim(),
        title: _titleController.text.trim().isNotEmpty 
            ? _titleController.text.trim() 
            : null,
      );
      Navigator.pop(context);
    }
  }

  void _handleCancel() {
    HapticFeedback.lightImpact();
    // Show confirmation if user has entered content
    if (!_isContentEmpty) {
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
              Navigator.pop(context); // Close create screen
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
                        'New Clip',
                        style: AppTextStyles.headline.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Save Button
                      TextButton(
                        onPressed: _isContentEmpty ? null : _handleSave,
                        style: TextButton.styleFrom(
                          minimumSize: const Size(60, 44),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'Save',
                          style: AppTextStyles.callout.copyWith(
                            color: _isContentEmpty 
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
                            child: Text(
                              '${_contentController.text.length} characters',
                              style: AppTextStyles.caption2.copyWith(
                                color: AppColors.textTertiary,
                              ),
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