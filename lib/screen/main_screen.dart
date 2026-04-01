import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:hirelink1/core/widgets/app_page_route.dart";
import "home_screen.dart";
import "applications_screen.dart";
import "recruiter_applications_screen.dart";
import "post_job_screen.dart";
import "profile_screen.dart";
import "discover_screen.dart";

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  // Section index (excluding center "Post" action):
  // 0: Home, 1: Jobs, 2: Applications, 3: Profile
  int _sectionIndex = 0;

  int _navIndexFromSection() {
    // Navigation has a center "Post" item at index 1.
    // Shift section indexes >= 1 by +1.
    return _sectionIndex >= 1 ? _sectionIndex + 1 : _sectionIndex;
  }

  @override
  Widget build(BuildContext context) {
    final screens = const [
      HomeScreen(),
      DiscoverScreen(),
      ApplicationsScreen(),
      RecruiterApplicationsScreen(),
      ProfileScreen(),
    ];

    final theme = Theme.of(context);
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final slideAnim = Tween<Offset>(
            begin: const Offset(0.0, 0.05),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: slideAnim,
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_sectionIndex),
          child: screens[_sectionIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.6),
            ),
          ),
        ),
        child: SafeArea(
          child: NavigationBar(
            height: 64,
            backgroundColor: Colors.transparent,
            elevation: 0,
            shadowColor: Colors.transparent,
            selectedIndex: _navIndexFromSection(),
            onDestinationSelected: (i) {
              if (i == 1) { // Post tab
                Navigator.push(
                  context,
                  AppPageRoute(child: const PostJobScreen()),
                );
                return;
              }
              setState(() {
                _sectionIndex = i > 1 ? i - 1 : i;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                label: "Home",
              ),
              NavigationDestination(
                icon: Icon(Icons.add_box_outlined),
                label: "Post",
              ),
              NavigationDestination(
                icon: Icon(Icons.swipe_rounded),
                label: "Discover",
              ),
              NavigationDestination(
                icon: Icon(Icons.work_outline_rounded),
                label: "Jobs",
              ),
              NavigationDestination(
                icon: Icon(Icons.assignment_outlined),
                label: "Applications",
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
