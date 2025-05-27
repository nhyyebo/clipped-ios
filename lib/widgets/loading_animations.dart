import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LoadingAnimations {
  // Shimmer loading effect for cards
  static Widget shimmerCard() {
    return Container(
      width: double.infinity,
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: AppColors.cardGradient,
      ),
      child: const ShimmerEffect(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerLine(width: 120, height: 16),
                  SizedBox(height: 8),
                  ShimmerLine(width: 200, height: 14),
                  SizedBox(height: 4),
                  ShimmerLine(width: 160, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Floating loading dots
  static Widget loadingDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: AlwaysStoppedAnimation(0),
          builder: (context, child) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 800 + (index * 200)),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.iosBlue.withValues(alpha: 0.3 + (value * 0.7)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }

  // Pulse loading for buttons
  static Widget pulseLoading({
    required Widget child,
    bool isLoading = false,
  }) {
    if (!isLoading) return child;
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: 0.3 + (value * 0.7),
            child: child,
          ),
        );
      },
    );
  }
}

// Shimmer effect widget
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  const ShimmerEffect({super.key, required this.child});

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Colors.transparent,
                Colors.white24,
                Colors.transparent,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

// Shimmer line for skeleton loading
class ShimmerLine extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLine({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cardElevated,
        borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
      ),
    );
  }
}

// Smooth fade transition
class SmoothFadeTransition extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final bool show;

  const SmoothFadeTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.show = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: show ? 1.0 : 0.0,
      duration: duration,
      curve: Curves.easeInOut,
      child: AnimatedScale(
        scale: show ? 1.0 : 0.95,
        duration: duration,
        curve: Curves.easeOutCubic,
        child: child,
      ),
    );
  }
} 