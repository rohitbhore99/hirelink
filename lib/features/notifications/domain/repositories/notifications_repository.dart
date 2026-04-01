import '../models/notification_model.dart';

abstract class NotificationsRepository {
  Stream<List<NotificationModel>> watchUserNotifications(String userId);
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    String? jobId,
  });
  Future<void> deleteNotification(String notificationId);
  Future<void> clearAllNotifications(String userId);
}
