import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ApplicationsRepository {
  Future<void> applyJob({
    required String userId,
    required String jobId,
    required String recruiterId,
    String? resumeUrl,
  });

  Future<bool> hasApplied({required String userId, required String jobId});

  Stream<QuerySnapshot> watchUserApplications(String userId);
  Stream<QuerySnapshot> watchApplicationsForJob(String jobId);
  Future<void> updateApplicationStatus(String applicationId, String status);

  Future<int> countApplicationsForJob(String jobId, {List<String>? statuses});

  /// Sum of application counts for the given job IDs (uses Firestore count aggregation).
  Future<int> countApplicationsForJobIds(List<String> jobIds);
}
