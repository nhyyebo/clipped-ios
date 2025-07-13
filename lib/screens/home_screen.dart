import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/clipboard_item.dart';
import '../providers/clipboard_provider.dart';
import '../theme/app_colors.dart';
import '../utils/text_styles.dart';
import '../widgets/clipboard_card.dart';
import '../widgets/loading_animations.dart';
import '../widgets/create_clip_screen.dart';
import '../widgets/edit_clip_screen.dart';
import '../widgets/home_header.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/filter_chips_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/floating_action_button_widget.dart';

/// Main home screen displaying clipboard items with search and filter functionality
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
    _initializeAnimations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  /// Initialize animation controllers and animations
  void _initializeAnimations() {
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
              HomeHeader(
                isBlurEnabled: _isBlurEnabled,
                onBlurToggle: _toggleBlurMode,
              ),
              SearchBarWidget(
                controller: _searchController,
                isSearchFocused: _isSearchFocused,
                onFocusChanged: _onSearchFocusChanged,
                onSearchChanged: _onSearchChanged,
                onClear: _onSearchClear,
              ),
              FilterChipsWidget(),
              Expanded(
                child: _buildClipboardList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButtonWidget(
        fabController: _fabController,
        fabScaleAnimation: _fabScaleAnimation,
        onPressed: _onFabPressed,
      ),
    );
  }

  /// Toggle blur mode for sensitive content
  void _toggleBlurMode() {
    HapticFeedback.lightImpact();
    setState(() => _isBlurEnabled = !_isBlurEnabled);
  }

  /// Handle search focus changes
  void _onSearchFocusChanged(bool isFocused) {
    setState(() => _isSearchFocused = isFocused);
  }

  /// Handle search query changes
  void _onSearchChanged(String value) {
    context.read<ClipboardProvider>().searchItems(value);
  }

  /// Clear search query
  void _onSearchClear() {
    _searchController.clear();
    context.read<ClipboardProvider>().searchItems('');
  }

  /// Handle FAB press with animation
  void _onFabPressed() {
    HapticFeedback.mediumImpact();
    _fabController.forward().then((_) {
      _fabController.reverse();
    });
    _showCreateBottomSheet();
  }

  /// Build the main clipboard items list with loading and empty states
  Widget _buildClipboardList() {
    return Consumer<ClipboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildLoadingList();
        }

        if (provider.items.isEmpty && provider.searchQuery.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.content_paste_rounded,
            title: 'No clips yet',
            subtitle: 'Copy something to get started',
          );
        }

        if (provider.items.isEmpty && provider.searchQuery.isNotEmpty) {
          return const EmptyStateWidget(
            icon: Icons.search_off_rounded,
            title: 'No results found',
            subtitle: 'Try a different search term',
          );
        }

        return _buildItemsList(provider.items);
      },
    );
  }

  /// Build loading state with shimmer cards
  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: 5,
      itemBuilder: (context, index) {
        return LoadingAnimations.shimmerCard();
      },
    );
  }

  /// Build the list of clipboard items
  Widget _buildItemsList(List<ClipboardItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ClipboardCard(
          item: item,
          index: index,
          isBlurred: _isBlurEnabled,
          onEdit: () => _showEditBottomSheet(item),
        );
      },
    );
  }

  /// Show create clip bottom sheet with slide animation
  void _showCreateBottomSheet() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            const CreateClipScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return _buildSlideTransition(animation, child);
        },
        transitionDuration: const Duration(milliseconds: 300),
        fullscreenDialog: true,
      ),
    );
  }

  /// Show edit clip bottom sheet with slide animation
  void _showEditBottomSheet(ClipboardItem item) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            EditClipScreen(item: item),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return _buildSlideTransition(animation, child);
        },
        transitionDuration: const Duration(milliseconds: 300),
        fullscreenDialog: true,
      ),
    );
  }

  /// Build slide transition for bottom sheets
  Widget _buildSlideTransition(Animation<double> animation, Widget child) {
    const begin = Offset(0.0, 1.0);
    const end = Offset.zero;
    const curve = Curves.easeInOut;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }
}
