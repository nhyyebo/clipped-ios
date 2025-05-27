import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/clipboard_provider.dart';
import '../theme/app_colors.dart';
import '../utils/text_styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoClipboardMonitoring = true;
  bool _hapticFeedback = true;
  bool _showNotifications = false;
  int _maxStorageItems = 100;
  int _autoDeleteDays = 30;
  String _selectedTheme = 'Dark';

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
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildSection(
                      title: 'Appearance',
                      children: [
                        _buildThemeSelector(),
                        _buildSwitchTile(
                          title: 'Haptic Feedback',
                          subtitle: 'Vibration on interactions',
                          value: _hapticFeedback,
                          onChanged: (value) {
                            setState(() => _hapticFeedback = value);
                            if (value) HapticFeedback.lightImpact();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      title: 'Clipboard',
                      children: [
                        _buildSwitchTile(
                          title: 'Auto Monitoring',
                          subtitle: 'Automatically capture clipboard changes',
                          value: _autoClipboardMonitoring,
                          onChanged: (value) {
                            setState(() => _autoClipboardMonitoring = value);
                          },
                        ),
                        _buildSwitchTile(
                          title: 'Show Notifications',
                          subtitle: 'Notify when new clips are captured',
                          value: _showNotifications,
                          onChanged: (value) {
                            setState(() => _showNotifications = value);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      title: 'Storage',
                      children: [
                        _buildStorageInfo(),
                        _buildSliderTile(
                          title: 'Max Items',
                          subtitle: 'Maximum number of clips to store',
                          value: _maxStorageItems.toDouble(),
                          min: 50,
                          max: 500,
                          divisions: 9,
                          onChanged: (value) {
                            setState(() => _maxStorageItems = value.round());
                          },
                        ),
                        _buildSliderTile(
                          title: 'Auto Delete',
                          subtitle: 'Delete clips older than $_autoDeleteDays days',
                          value: _autoDeleteDays.toDouble(),
                          min: 7,
                          max: 365,
                          divisions: 51,
                          onChanged: (value) {
                            setState(() => _autoDeleteDays = value.round());
                          },
                        ),
                        _buildActionTile(
                          title: 'Clear All Clips',
                          subtitle: 'Delete all stored clipboard items',
                          icon: Icons.delete_outline_rounded,
                          isDestructive: true,
                          onTap: _showClearAllConfirmation,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      title: 'Privacy & Security',
                      children: [
                        _buildActionTile(
                          title: 'Export Data',
                          subtitle: 'Export all clips to a file',
                          icon: Icons.download_rounded,
                          onTap: () {
                            // TODO: Implement export functionality
                            _showComingSoonDialog('Export Data');
                          },
                        ),
                        _buildActionTile(
                          title: 'Import Data',
                          subtitle: 'Import clips from a file',
                          icon: Icons.upload_rounded,
                          onTap: () {
                            // TODO: Implement import functionality
                            _showComingSoonDialog('Import Data');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      title: 'About',
                      children: [
                        _buildInfoTile(
                          title: 'Version',
                          subtitle: '2.0.0',
                          icon: Icons.info_outline_rounded,
                        ),
                        _buildActionTile(
                          title: 'Privacy Policy',
                          subtitle: 'View our privacy policy',
                          icon: Icons.privacy_tip_outlined,
                          onTap: () {
                            _showComingSoonDialog('Privacy Policy');
                          },
                        ),
                        _buildActionTile(
                          title: 'Terms of Service',
                          subtitle: 'View terms and conditions',
                          icon: Icons.description_outlined,
                          onTap: () {
                            _showComingSoonDialog('Terms of Service');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
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
              Icons.settings_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Settings',
              style: AppTextStyles.largeTitle.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: AppTextStyles.title3.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.separatorOpaque.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: AppTextStyles.headline.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.callout.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.iosBlue,
        activeTrackColor: AppColors.iosBlue.withValues(alpha: 0.3),
        inactiveThumbColor: AppColors.textQuaternary,
        inactiveTrackColor: AppColors.cardElevated,
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.textSecondary,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTextStyles.headline.copyWith(
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.callout.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textQuaternary,
        size: 20,
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.textSecondary,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTextStyles.headline.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.callout.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildThemeSelector() {
    final themes = ['Dark', 'Light', 'Auto'];
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Theme',
            style: AppTextStyles.headline.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your preferred theme',
            style: AppTextStyles.callout.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: themes.map((theme) {
              final isSelected = _selectedTheme == theme;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedTheme = theme);
                      HapticFeedback.lightImpact();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppColors.iosBlue.withValues(alpha: 0.2)
                            : AppColors.cardElevated.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected 
                              ? AppColors.iosBlue.withValues(alpha: 0.5)
                              : AppColors.separatorOpaque.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        theme,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.callout.copyWith(
                          color: isSelected 
                              ? AppColors.iosBlue 
                              : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.headline.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.callout.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.iosBlue,
              inactiveTrackColor: AppColors.cardElevated,
              thumbColor: AppColors.iosBlue,
              overlayColor: AppColors.iosBlue.withValues(alpha: 0.2),
              valueIndicatorColor: AppColors.iosBlue,
              valueIndicatorTextStyle: AppTextStyles.callout.copyWith(
                color: Colors.white,
              ),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: value.round().toString(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageInfo() {
    return Consumer<ClipboardProvider>(
      builder: (context, provider, child) {
        final stats = provider.getStorageStats();
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Storage Usage',
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Clips',
                    style: AppTextStyles.callout.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  Text(
                    '${stats['itemCount']}',
                    style: AppTextStyles.callout.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Favorites',
                    style: AppTextStyles.callout.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  Text(
                    '${stats['favoriteCount'] ?? 0}',
                    style: AppTextStyles.callout.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showClearAllConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Clear All Clips?',
          style: AppTextStyles.title3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'This action cannot be undone. All clipboard items will be permanently deleted.',
          style: AppTextStyles.callout.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.headline.copyWith(
                color: AppColors.iosBlue,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<ClipboardProvider>().clearAllItems();
              Navigator.pop(context);
              _showSuccessSnackBar('All clips cleared successfully');
            },
            child: Text(
              'Clear All',
              style: AppTextStyles.headline.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Coming Soon',
          style: AppTextStyles.title3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          '$feature will be available in a future update.',
          style: AppTextStyles.callout.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTextStyles.headline.copyWith(
                color: AppColors.iosBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
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
              message,
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
} 