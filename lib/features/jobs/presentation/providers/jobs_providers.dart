import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hirelink1/core/di/providers.dart';
import 'package:hirelink1/features/jobs/domain/models/job_model.dart';

final jobsStreamProvider = StreamProvider<List<JobModel>>((ref) {
  final repository = ref.watch(jobsRepositoryProvider);
  return repository.watchJobs();
});
