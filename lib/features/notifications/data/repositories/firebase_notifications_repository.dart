import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/notification_model.dart';
import '../../domain/repositories/notifications_repository.dart';

class FirebaseNotificationsRepository implements NotificationsRepository {
  final FirebaseFirestore _db;

  FirebaseNotificationsRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<NotificationModel>> watchUserNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList();
          list.sort((a, b) => (b.timestamp ?? DateTime(0)).compareTo(a.timestamp ?? DateTime(0)));
          return list.take(50).toList();
        });
  }

  @override
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
  }) async {
    await _db.collection('notifications').add({
      'userId': userId,
      'title': title,
      'body': body,
      'timestamp': Timestamp.now(),
    });
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).delete();
  }

  @override
  Future<void> clearAllNotifications(String userId) async {
    final snapshot = await _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .get();
        
    final batch = _db.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
