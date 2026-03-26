import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hirelink1/core/di/providers.dart';
import 'package:hirelink1/core/widgets/app_page_route.dart';
import 'package:hirelink1/features/chat/domain/models/chat_preview_model.dart';
import 'package:hirelink1/screen/chat_screen.dart';
import 'package:hirelink1/widgets/custom_app_bar.dart';
import 'package:hirelink1/widgets/empty_state.dart';
import 'package:hirelink1/core/theme/app_spacing.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Messages'),
        body: EmptyState(
          title: 'Sign in required',
          subtitle: 'Please sign in to view your conversations.',
          icon: Icons.lock_outline_rounded,
        ),
      );
    }
    final currentUserId = currentUser.uid;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Messages'),
      body: StreamBuilder<List<ChatPreviewModel>>(
        stream: ref.watch(chatRepositoryProvider).watchUserChats(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return EmptyState(
              title: 'Unable to load messages',
              subtitle: 'Please try again in a moment.',
              icon: Icons.error_outline_rounded,
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final chats = snapshot.data ?? const <ChatPreviewModel>[];
          if (chats.isEmpty) {
            return EmptyState(
              title: 'No messages yet',
              subtitle: 'Start a chat from a job listing.',
              icon: Icons.chat_bubble_outline_rounded,
            );
          }
          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
            itemCount: chats.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final chat = chats[index];
              final initial = chat.otherUserName.isNotEmpty ? chat.otherUserName[0].toUpperCase() : '?';
              return Material(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    if (chat.otherUserId.isEmpty) return;
                    Navigator.push(context, AppPageRoute(child: ChatScreen(otherUserId: chat.otherUserId)));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text(
                            initial,
                            style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(chat.otherUserName, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(
                                chat.lastMessage.isEmpty ? 'Start conversation' : chat.lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded),
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
