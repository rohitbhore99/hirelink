import 'package:flutter/material.dart';
import 'package:hirelink1/core/theme/app_radius.dart';
import 'package:hirelink1/core/theme/app_spacing.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? titleWidget;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onNotificationTap;
  final int notificationCount;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.titleWidget,
    this.searchController,
    this.onSearchChanged,
    this.onNotificationTap,
    this.notificationCount = 0,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(116);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSearch = searchController != null;
    return AppBar(
      toolbarHeight: 60,
      titleSpacing: AppSpacing.md,
      title: titleWidget ?? Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
      actions: [
        if (onNotificationTap != null)
          IconButton(
            onPressed: onNotificationTap,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none_rounded),
                if (notificationCount > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text(
                        notificationCount > 9 ? '9+' : '$notificationCount',
                        style: theme.textTheme.labelSmall?.copyWith(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ...?actions,
        const SizedBox(width: AppSpacing.sm),
      ],
      bottom: hasSearch
          ? PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search jobs, companies, skills',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: theme.brightness == Brightness.dark
                        ? theme.colorScheme.surface.withValues(alpha: 0.7)
                        : Colors.white.withValues(alpha: 0.78),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.35), width: 1.2),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
