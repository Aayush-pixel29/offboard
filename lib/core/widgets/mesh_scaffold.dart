import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// ThreeUI & Bento Atmospheric Mesh Background Scaffold
/// Implements deep obsidian canvas with multi-layered radial ambient glow
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
          // Ambient Radial Mesh Glow 1: Top Hero Indigo Glow
          Positioned(
            top: -100,
            left: size.width * 0.1,
            right: size.width * 0.1,
            height: 380,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryGlow.withValues(alpha: 0.18),
                      AppColors.purpleGlow.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Ambient Radial Mesh Glow 2: Bottom Cyan/Emerald Accent
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
                      AppColors.cyanGlow.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.9],
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

