import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hirelink1/core/di/providers.dart';
import 'package:hirelink1/core/theme/app_spacing.dart';
import 'package:hirelink1/core/widgets/animated_pressable.dart';
import 'package:hirelink1/features/notifications/domain/models/notification_model.dart';
import 'package:hirelink1/widgets/custom_app_bar.dart';
import 'package:hirelink1/widgets/empty_state.dart';
import 'package:hirelink1/screen/recruiter_applications_screen.dart' as hirelink_recruiter;
import 'package:hirelink1/screen/applications_screen.dart' as hirelink_apps;
import 'package:hirelink1/screen/chat_list_screen.dart' as hirelink_chat_list;
import 'package:hirelink1/features/user/domain/models/user_model.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Notifications'),
        body: EmptyState(
          title: 'Sign in required',
          subtitle: 'Please sign in to view notifications.',
          icon: Icons.lock_outline_rounded,
        ),
      );
    }
    final userId = currentUser.uid;
    final notificationsStream = ref.watch(notificationsRepositoryProvider).watchUserNotifications(userId);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifications',
        actions: [
          IconButton(
            tooltip: 'Clear All Notifications',
            icon: const Icon(Icons.delete_sweep_rounded),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All Notifications'),
                  content: const Text('Are you sure you want to delete all notifications?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                         backgroundColor: theme.colorScheme.error,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.white),
                      label: const Text('Clear All', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await ref.read(notificationsRepositoryProvider).clearAllNotifications(userId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All notifications cleared')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: notificationsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return EmptyState(
              title: 'Unable to load notifications',
              subtitle: 'Please try again in a moment.',
              icon: Icons.error_outline_rounded,
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final notifications = snapshot.data!;
          if (notifications.isEmpty) {
            return EmptyState(
              title: 'No notifications yet',
              subtitle: 'We\'ll notify you when something happens.',
              icon: Icons.notifications_none_rounded,
            );
          }
          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final n = notifications[index];
              return Dismissible(
                key: ValueKey(n.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                ),
                onDismissed: (_) {
                  ref.read(notificationsRepositoryProvider).deleteNotification(n.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification removed')),
                  );
                },
                child: AnimatedPressable(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    final title = n.title.toLowerCase();
                    if (title.contains('application') || title.contains('accepted') || title.contains('successful')) {
                      final role = ref.read(userProfileStreamProvider(userId)).valueOrNull?.role ?? 'jobseeker';
                      Navigator.pop(context); // pop the notification screen
                      if (role == 'recruiter') {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const hirelink_recruiter.RecruiterApplicationsScreen()));
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const hirelink_apps.ApplicationsScreen()));
                      }
                    } else if (title.contains('message')) {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const hirelink_chat_list.ChatListScreen()));
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.notifications_rounded, color: theme.colorScheme.primary, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(n.body, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
