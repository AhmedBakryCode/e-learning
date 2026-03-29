import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminBottomNavigation extends StatelessWidget {
  const AdminBottomNavigation({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.xxl),
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              switch (index) {
                case 0:
                  context.go('/admin');
                case 1:
                  context.go('/admin/courses');
                case 2:
                  context.go('/admin/students');
                case 3:
                  context.go('/admin/notifications/send');
              }
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book_rounded),
                label: 'Courses',
              ),
              NavigationDestination(
                icon: Icon(Icons.groups_outlined),
                selectedIcon: Icon(Icons.groups_rounded),
                label: 'Students',
              ),
              NavigationDestination(
                icon: Icon(Icons.send_outlined),
                selectedIcon: Icon(Icons.send_rounded),
                label: 'Send',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
