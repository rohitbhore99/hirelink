import '../models/job_model.dart';

abstract class JobsRepository {
  Stream<List<JobModel>> watchJobs();
  Stream<List<JobModel>> watchMyJobs(String userId);
  Future<JobModel?> getJob(String jobId);
  Future<void> addJob({
    required String title,
    required String company,
    required String postedBy,
    String? companyUrl,
    String description,
    String responsibilities,
    String dailyActivities,
    String location,
    String type,
    String workMode,
    String skills,
    String experienceLevel,
    String education,
    String salary,
    bool notDisclosed,
    DateTime? applicationDeadline,
    DateTime? joiningDate,
    int openings,
    bool urgentHiring,
    bool fresherFriendly,
    bool blindHiring,
    bool isDraft,
  });
}
