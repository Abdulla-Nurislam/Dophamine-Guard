import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.navigationShell,
  });

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => _onTap(context, index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.inactiveNav,
          backgroundColor: Colors.white,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontFamilyFallback: AppTheme.emojiFallback),
          unselectedLabelStyle: const TextStyle(fontFamilyFallback: AppTheme.emojiFallback),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.home),
              label: 'Главная',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.award),
              label: 'Достижения',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.user),
              label: 'Профиль',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.settings),
              label: 'Настройки',
            ),
          ],
        ),
      ),
    );
  }
}
