import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String? jobId;
  final DateTime? timestamp;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.jobId,
    this.timestamp,
  });

  factory NotificationModel.fromFirestore(QueryDocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: map['userId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      body: map['body']?.toString() ?? '',
      jobId: map['jobId']?.toString(),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
    );
  }
}
