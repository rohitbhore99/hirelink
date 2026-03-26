import 'package:flutter/foundation.dart';
import 'package:hirelink1/core/state/ui_state.dart';
import 'package:hirelink1/features/jobs/domain/models/job_model.dart';
import 'package:hirelink1/features/jobs/domain/repositories/jobs_repository.dart';

class JobsController extends ChangeNotifier {
  final JobsRepository _jobsRepository;

  JobsController(this._jobsRepository);

  UiState<List<JobModel>> state = const UiState(isLoading: true, data: []);

  void bindJobs() {
    state = state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    _jobsRepository.watchJobs().listen(
      (jobs) {
        state = UiState(isLoading: false, data: jobs);
        notifyListeners();
      },
      onError: (error) {
        state = UiState(
          isLoading: false,
          data: state.data,
          errorMessage: 'Unable to load jobs right now.',
        );
        notifyListeners();
      },
    );
  }
}
