import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Bright Luxury Ivory & Warm Golden Atmospheric Mesh Background
class MeshScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool extendBody;

  const MeshScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.extendBody = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: extendBody,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          // Ambient Warm Golden Radial Glow 1 (Top Hero)
          Positioned(
            top: -120,
            left: size.width * 0.05,
            right: size.width * 0.05,
            height: 380,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryLight.withValues(alpha: 0.14),
                      AppColors.primaryGlow.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Ambient Champagne Glow 2 (Bottom Right)
          Positioned(
            bottom: -80,
            right: -60,
            width: 320,
            height: 320,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryLight.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.85],
                  ),
                ),
              ),
            ),
          ),

          // Foreground Content
          SafeArea(
            bottom: !extendBody,
            child: body,
          ),
        ],
      ),
    );
  }
}
