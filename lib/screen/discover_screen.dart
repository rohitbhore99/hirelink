import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hirelink1/core/di/providers.dart';
import 'package:hirelink1/features/jobs/domain/models/job_model.dart';
import 'package:hirelink1/widgets/empty_state.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  List<JobModel>? _jobs;
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    final jobsRepo = ref.read(jobsRepositoryProvider);
    final appsRepo = ref.read(applicationsRepositoryProvider);
    final userId = FirebaseAuth.instance.currentUser?.uid;
    
    if (userId == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    // We fetch some recent jobs and filter out the ones already applied to or posted by the user
    jobsRepo.watchJobs().listen((allJobs) async {
      final filteredJobs = <JobModel>[];
      for (final job in allJobs) {
        if (job.postedBy == userId) continue;
        final hasApplied = await appsRepo.hasApplied(userId: userId, jobId: job.id);
        if (!hasApplied) {
          filteredJobs.add(job);
        }
      }
      if (mounted) {
        setState(() {
          _jobs = filteredJobs;
          _isLoading = false;
        });
      }
    });
  }

  void _onSwipe(bool isRight) async {
    final job = _jobs?[_currentIndex];
    if (job == null) return;
    
    if (isRight) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final appsRepo = ref.read(applicationsRepositoryProvider);
        await appsRepo.applyJob(
          userId: userId,
          jobId: job.id,
          recruiterId: job.postedBy,
        );
        ref.read(notificationsRepositoryProvider).sendNotification(
          userId: job.postedBy,
          title: 'New Applicant',
          body: 'Someone just swiped right on your job!',
          jobId: job.id,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Applied successfully!')),
          );
        }
      }
    }
    
    setState(() {
      _currentIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_jobs == null || _currentIndex >= _jobs!.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('Discover Jobs')),
        body: const EmptyState(
          title: 'You\'ve caught up!',
          subtitle: 'No more jobs to discover right now.',
          icon: Icons.check_circle_outline,
        ),
      );
    }

    final currentJob = _jobs![_currentIndex];
    final theme = Theme.of(context);

    // Pre-calculate next job to stack behind
    final hasNext = _currentIndex + 1 < _jobs!.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Swipe to Apply 👉')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (hasNext)
                _buildJobCard(_jobs![_currentIndex + 1], isBackground: true),
              Dismissible(
                key: ValueKey(currentJob.id),
                onDismissed: (direction) {
                  if (direction == DismissDirection.endToStart) {
                    _onSwipe(false); // Swipe left = skip
                  } else {
                    _onSwipe(true); // Swipe right = apply
                  }
                },
                background: _buildActionBackground(
                  color: Colors.green,
                  icon: Icons.check_circle,
                  alignment: Alignment.centerLeft,
                ),
                secondaryBackground: _buildActionBackground(
                  color: Colors.red,
                  icon: Icons.cancel,
                  alignment: Alignment.centerRight,
                ),
                child: _buildJobCard(currentJob),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                heroTag: 'skip_btn',
                onPressed: () => _onSwipe(false),
                backgroundColor: Colors.red.shade100,
                elevation: 2,
                child: const Icon(Icons.close, color: Colors.red, size: 32),
              ),
              FloatingActionButton(
                heroTag: 'apply_btn',
                onPressed: () => _onSwipe(true),
                backgroundColor: Colors.green.shade100,
                elevation: 2,
                child: const Icon(Icons.favorite, color: Colors.green, size: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionBackground({
    required Color color,
    required IconData icon,
    required Alignment alignment,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Icon(icon, color: Colors.white, size: 64),
    );
  }

  Widget _buildJobCard(JobModel job, {bool isBackground = false}) {
    final theme = Theme.of(context);
    return Transform.scale(
      scale: isBackground ? 0.95 : 1.0,
      child: Transform.translate(
        offset: Offset(0, isBackground ? 20 : 0),
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.business_center, size: 32, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    job.title,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${job.company} · ${job.location}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(job.type),
                      _buildChip(job.workMode),
                      _buildChip(job.experienceLevel),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Requirements',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(job.skills.isNotEmpty ? job.skills : 'Not specified'),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job.description,
                    maxLines: 8,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
