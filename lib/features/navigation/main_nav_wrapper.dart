import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../feed/ui/home_screen.dart';
import '../community/ui/community_hub_screen.dart';
import '../stats/ui/leaderboard_screen.dart';
import '../tools/ui/resignation_generator_screen.dart';
import '../profile/ui/profile_screen.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CommunityHubScreen(),
    LeaderboardScreen(),
    ResignationGeneratorScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border, width: 1)),
          ),
          child: NavigationBar(
            height: 64,
            selectedIndex: _currentIndex,
            backgroundColor: AppColors.surface,
            elevation: 0,
            indicatorColor: AppColors.borderLight,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(LucideIcons.newspaper, size: 20),
                selectedIcon: Icon(LucideIcons.newspaper, size: 20, color: AppColors.primary),
                label: 'Exit Feed',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.users, size: 20),
                selectedIcon: Icon(LucideIcons.users, size: 20, color: AppColors.primary),
                label: 'Cohorts',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.barChart2, size: 20),
                selectedIcon: Icon(LucideIcons.barChart2, size: 20, color: AppColors.primary),
                label: 'Hall of Shame',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.fileText, size: 20),
                selectedIcon: Icon(LucideIcons.fileText, size: 20, color: AppColors.primary),
                label: 'Exit Toolkit',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.user, size: 20),
                selectedIcon: Icon(LucideIcons.user, size: 20, color: AppColors.primary),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
