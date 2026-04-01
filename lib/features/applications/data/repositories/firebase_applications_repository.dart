import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repositories/applications_repository.dart';

class FirebaseApplicationsRepository implements ApplicationsRepository {
  final FirebaseFirestore _db;

  FirebaseApplicationsRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> applyJob({
    required String userId,
    required String jobId,
    required String recruiterId,
    String? resumeUrl,
    String? coverLetter,
  }) async {
    await _db.collection('applications').add({
      'userId': userId,
      'applicantId': userId,
      'jobId': jobId,
      'recruiterId': recruiterId,
      'status': 'applied',
      'appliedAt': Timestamp.now(),
      'timestamp': Timestamp.now(),
      if (resumeUrl != null && resumeUrl.isNotEmpty) 'resumeUrl': resumeUrl,
      if (coverLetter != null && coverLetter.isNotEmpty) 'coverLetter': coverLetter,
    });
  }

  @override
  Future<bool> hasApplied({
    required String userId,
    required String jobId,
  }) async {
    final result = await _db
        .collection('applications')
        .where('userId', isEqualTo: userId)
        .where('jobId', isEqualTo: jobId)
        .limit(1)
        .get();
    return result.docs.isNotEmpty;
  }

  @override
  Stream<QuerySnapshot> watchUserApplications(String userId) {
    return _db
        .collection('applications')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  @override
  Stream<QuerySnapshot> watchApplicationsForJob(String jobId) {
    return _db
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .snapshots();
  }

  @override
  Future<void> updateApplicationStatus(
    String applicationId,
    String status,
  ) async {
    await _db.collection('applications').doc(applicationId).update({
      'status': status,
    });
  }

  @override
  Future<int> countApplicationsForJob(
    String jobId, {
    List<String>? statuses,
  }) async {
    Query query = _db
        .collection('applications')
        .where('jobId', isEqualTo: jobId);
    if (statuses != null && statuses.isNotEmpty) {
      query = query.where('status', whereIn: statuses);
    }
    final snap = await query.count().get();
    return snap.count ?? 0;
  }

  @override
  Future<int> countApplicationsForJobIds(List<String> jobIds) async {
    if (jobIds.isEmpty) return 0;
    var sum = 0;
    for (final jobId in jobIds) {
      final snap = await _db
          .collection('applications')
          .where('jobId', isEqualTo: jobId)
          .count()
          .get();
      sum += snap.count ?? 0;
    }
    return sum;
  }
}
