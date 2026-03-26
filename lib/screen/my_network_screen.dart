import 'package:flutter/material.dart';
import 'package:hirelink1/core/widgets/app_page_route.dart';
import 'package:hirelink1/core/theme/app_spacing.dart';
import 'package:hirelink1/screen/chat_list_screen.dart';
import 'package:hirelink1/widgets/custom_app_bar.dart';

class MyNetworkScreen extends StatelessWidget {
  const MyNetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const CustomAppBar(title: 'My Network'),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _NetworkCard(
            title: 'Manage your network',
            subtitle: 'Connections, followers, and pages',
            icon: Icons.group_outlined,
            onTap: () {},
          ),
          const SizedBox(height: AppSpacing.sm),
          _NetworkCard(
            title: 'Invitations',
            subtitle: 'You have 0 pending invitations',
            icon: Icons.mail_outline_rounded,
            onTap: () {},
          ),
          const SizedBox(height: AppSpacing.sm),
          _NetworkCard(
            title: 'Messages',
            subtitle: 'Open your conversations',
            icon: Icons.chat_bubble_outline_rounded,
            onTap: () {
              Navigator.push(context, AppPageRoute(child: const ChatListScreen()));
            },
          ),
        ],
      ),
    );
  }
}

class _NetworkCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _NetworkCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.45)),
          ),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
