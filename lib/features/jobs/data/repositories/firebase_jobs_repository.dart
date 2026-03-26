import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/job_model.dart';
import '../../domain/repositories/jobs_repository.dart';

class FirebaseJobsRepository implements JobsRepository {
  final FirebaseFirestore _db;

  FirebaseJobsRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<JobModel>> watchJobs() {
    return _db
        .collection('jobs')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(JobModel.fromFirestore).toList());
  }

  @override
  Stream<List<JobModel>> watchMyJobs(String userId) {
    return _db
        .collection('jobs')
        .where('postedBy', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(JobModel.fromFirestore).toList());
  }

  @override
  Future<JobModel?> getJob(String jobId) async {
    final doc = await _db.collection('jobs').doc(jobId).get();
    if (!doc.exists) return null;
    return JobModel.fromFirestore(doc);
  }

  @override
  Future<void> addJob({
    required String title,
    required String company,
    required String postedBy,
    String? companyUrl,
    String description = '',
    String responsibilities = '',
    String dailyActivities = '',
    String location = 'Remote',
    String type = 'Full-time',
    String workMode = 'Remote',
    String skills = '',
    String experienceLevel = 'Fresher',
    String education = '',
    String salary = 'Negotiable',
    bool notDisclosed = false,
    DateTime? applicationDeadline,
    DateTime? joiningDate,
    int openings = 1,
    bool urgentHiring = false,
    bool fresherFriendly = false,
    bool isDraft = false,
  }) async {
    await _db.collection('jobs').add({
      'title': title,
      'company': company,
      'companyUrl': companyUrl,
      'description': description,
      'responsibilities': responsibilities,
      'dailyActivities': dailyActivities,
      'location': location,
      'type': type,
      'workMode': workMode,
      'skills': skills,
      'experienceLevel': experienceLevel,
      'education': education,
      'salary': salary,
      'notDisclosed': notDisclosed,
      'applicationDeadline': applicationDeadline == null
          ? null
          : Timestamp.fromDate(applicationDeadline),
      'joiningDate': joiningDate == null
          ? null
          : Timestamp.fromDate(joiningDate),
      'openings': openings,
      'urgentHiring': urgentHiring,
      'fresherFriendly': fresherFriendly,
      'isDraft': isDraft,
      'postedBy': postedBy,
      'createdAt': Timestamp.now(),
    });
  }
}
