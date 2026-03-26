import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPreviewModel {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String lastMessage;
  final DateTime? lastMessageAt;

  const ChatPreviewModel({
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    required this.lastMessage,
    this.lastMessageAt,
  });

  factory ChatPreviewModel.fromFirestore({
    required String currentUserId,
    required QueryDocumentSnapshot doc,
  }) {
    final map = doc.data() as Map<String, dynamic>;
    final users = (map['users'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<String>()
        .toList();
    final userNames = Map<String, dynamic>.from(map['userNames'] ?? const {});
    final otherId = users.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    return ChatPreviewModel(
      chatId: doc.id,
      otherUserId: otherId,
      otherUserName: userNames[otherId]?.toString() ?? 'User',
      lastMessage: map['lastMessage']?.toString() ?? '',
      lastMessageAt: (map['lastMessageAt'] as Timestamp?)?.toDate(),
    );
  }
}
