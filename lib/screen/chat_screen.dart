import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hirelink1/core/di/providers.dart';
import 'package:hirelink1/screen/user_public_profile_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String otherUserId;

  const ChatScreen({super.key, required this.otherUserId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  String? chatId;
  String otherUserName = 'Chat';
  final messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    initChat();
  }

  @override
  void dispose() {
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatTime(Timestamp? ts) {
    if (ts == null) return '';
    final d = ts.toDate();
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  Future<void> initChat() async {
    final currentUserObj = FirebaseAuth.instance.currentUser;
    if (currentUserObj == null) return;
    final currentUser = currentUserObj.uid;
    final id = await ref
        .read(chatRepositoryProvider)
        .createOrGetChat(user1: currentUser, user2: widget.otherUserId);
    if (!mounted) return;
    setState(() => chatId = id);
    final user = await ref
        .read(userRepositoryProvider)
        .getUser(widget.otherUserId);
    if (!mounted) return;
    setState(() => otherUserName = user?.name ?? 'Chat');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserObj = FirebaseAuth.instance.currentUser;
    if (currentUserObj == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: Center(
          child: Text(
            'Please sign in to open chat',
            style: theme.textTheme.bodyLarge,
          ),
        ),
      );
    }
    if (chatId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentUser = currentUserObj.uid;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : '?',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(otherUserName),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'view_profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        UserPublicProfileScreen(userId: widget.otherUserId),
                  ),
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'view_profile',
                child: Text('View Profile'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ref.watch(chatRepositoryProvider).watchMessages(chatId!),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load messages',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data?.docs ?? const [];
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['senderId'] == currentUser;
                    final senderId = msg['senderId'] as String?;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isMe) ...[
                            GestureDetector(
                              onTap: senderId != null
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              UserPublicProfileScreen(
                                                userId: senderId,
                                              ),
                                        ),
                                      );
                                    }
                                  : null,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                                child: Text(
                                  otherUserName.isNotEmpty
                                      ? otherUserName[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: isMe
                                        ? LinearGradient(
                                            colors: [
                                              theme.colorScheme.primary,
                                              theme.colorScheme.primary
                                                  .withValues(alpha: 0.8),
                                            ],
                                          )
                                        : null,
                                    color: isMe
                                        ? null
                                        : theme
                                              .colorScheme
                                              .surfaceContainerHighest,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16),
                                      topRight: const Radius.circular(16),
                                      bottomLeft: Radius.circular(
                                        isMe ? 16 : 2,
                                      ),
                                      bottomRight: Radius.circular(
                                        isMe ? 2 : 16,
                                      ),
                                    ),
                                  ),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                          0.65,
                                    ),
                                    child: Text(
                                      msg['text'] ?? '',
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            color: isMe
                                                ? theme.colorScheme.onPrimary
                                                : theme.colorScheme.onSurface,
                                          ),
                                      softWrap: true,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    left: 8,
                                    right: 8,
                                  ),
                                  child: Text(
                                    _formatTime(msg['timestamp'] as Timestamp?),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isMe) const SizedBox(width: 8),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _isTyping
                ? Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 6,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '$otherUserName is typing...',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (v) =>
                          setState(() => _isTyping = v.trim().isNotEmpty),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(currentUser),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Material(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      onTap: () => _send(currentUser),
                      borderRadius: BorderRadius.circular(24),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _send(String currentUser) async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    messageController.clear();
    if (mounted) setState(() => _isTyping = false);
    await ref
        .read(chatRepositoryProvider)
        .sendMessage(chatId: chatId!, senderId: currentUser, text: text);
    final from = FirebaseAuth.instance.currentUser?.displayName;
    final title = (from != null && from.isNotEmpty)
        ? 'Message from $from'
        : 'New message';
    await ref
        .read(notificationsRepositoryProvider)
        .sendNotification(
          userId: widget.otherUserId,
          title: title,
          body: text.length > 80 ? '${text.substring(0, 80)}…' : text,
        );
  }
}
