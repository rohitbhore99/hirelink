import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/chat_preview_model.dart';
import '../../domain/repositories/chat_repository.dart';

class FirebaseChatRepository implements ChatRepository {
  final FirebaseFirestore _db;

  FirebaseChatRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  @override
  Future<String> createOrGetChat({
    required String user1,
    required String user2,
  }) async {
    final result =
        await _db.collection('chats').where('users', arrayContains: user1).get();

    for (final doc in result.docs) {
      final data = doc.data();
      final users = (data['users'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<String>()
          .toList();
      if (users.contains(user2)) return doc.id;
    }

    final user1Doc = await _db.collection('users').doc(user1).get();
    final user2Doc = await _db.collection('users').doc(user2).get();

    final user1Name = (user1Doc.data() ?? const {})['name'] as String? ?? 'User';
    final user2Name = (user2Doc.data() ?? const {})['name'] as String? ?? 'User';

    final chat = await _db.collection('chats').add({
      'users': [user1, user2],
      'userNames': {user1: user1Name, user2: user2Name},
      'lastMessage': '',
      'lastMessageAt': Timestamp.now(),
      'createdAt': Timestamp.now(),
    });

    return chat.id;
  }

  @override
  Stream<List<ChatPreviewModel>> watchUserChats(String userId) {
    return _db
        .collection('chats')
        .where('users', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          final chats = snapshot.docs
              .map((doc) => ChatPreviewModel.fromFirestore(
                    currentUserId: userId,
                    doc: doc,
                  ))
              .toList();
          chats.sort(
            (a, b) => (b.lastMessageAt ?? DateTime(0)).compareTo(a.lastMessageAt ?? DateTime(0)),
          );
          return chats.take(30).toList();
        });
  }

  @override
  Stream<QuerySnapshot> watchMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    await _db.collection('chats').doc(chatId).collection('messages').add({
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.now(),
    });

    await _db.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageAt': Timestamp.now(),
      'lastSenderId': senderId,
    });
  }
}
