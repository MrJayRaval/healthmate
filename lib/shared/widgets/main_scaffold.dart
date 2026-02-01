import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  void _onItemTapped(int index, BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);
    if (currentIndex == index &&
        GoRouterState.of(context).uri.toString() != '/profile') {
      return;
    }

    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/habits');
        break;
      case 2:
        context.go('/symptoms');
        break;
      case 3:
        context.go('/insights');
        break;
      case 4:
        context.go('/chat');
        break;
    }
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/habits')) return 1;
    if (location.startsWith('/symptoms')) return 2;
    if (location.startsWith('/insights')) return 3;
    if (location.startsWith('/chat')) return 4;
    return 0; // Default to home for /profile or others in shell
  }

  @override
  Widget build(BuildContext context) {
    final canPop = GoRouter.of(context).canPop();
    final isHome = _calculateSelectedIndex(context) == 0;

    return PopScope(
      canPop: isHome || canPop,
      onPopInvoked: (didPop) {
        if (didPop) return;

        if (!isHome && !canPop) {
          context.go('/home');
        }
      },
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: _calculateSelectedIndex(context),
            onDestinationSelected: (index) => _onItemTapped(index, context),
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            indicatorColor: AppColors.primary.withOpacity(0.1),
            height: 65,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(
                  Icons.home_rounded,
                  color: AppColors.primary,
                ),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.track_changes_outlined),
                selectedIcon: Icon(
                  Icons.track_changes_rounded,
                  color: AppColors.primary,
                ),
                label: 'Habits',
              ),
              NavigationDestination(
                icon: Icon(Icons.medical_services_outlined),
                selectedIcon: Icon(
                  Icons.medical_services_rounded,
                  color: AppColors.primary,
                ),
                label: 'Check',
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_outlined),
                selectedIcon: Icon(
                  Icons.insights_rounded,
                  color: AppColors.primary,
                ),
                label: 'Insights',
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(
                  Icons.chat_bubble_rounded,
                  color: AppColors.primary,
                ),
                label: 'Chat',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
