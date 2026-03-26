import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_preview_model.dart';

abstract class ChatRepository {
  Future<String> createOrGetChat({
    required String user1,
    required String user2,
  });

  Stream<List<ChatPreviewModel>> watchUserChats(String userId);
  Stream<QuerySnapshot> watchMessages(String chatId);

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  });
}
