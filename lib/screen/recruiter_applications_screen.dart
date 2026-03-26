import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hirelink1/core/di/providers.dart';
import 'package:hirelink1/core/theme/app_spacing.dart';
import 'package:hirelink1/widgets/custom_app_bar.dart';
import 'package:hirelink1/widgets/empty_state.dart';
import 'package:hirelink1/core/widgets/animated_pressable.dart';
import 'package:hirelink1/features/jobs/domain/models/job_model.dart';
import 'package:hirelink1/screen/job_applicants_screen.dart';

class RecruiterApplicationsScreen extends ConsumerStatefulWidget {
  const RecruiterApplicationsScreen({super.key});

  @override
  ConsumerState<RecruiterApplicationsScreen> createState() =>
      _RecruiterApplicationsScreenState();
}

class _RecruiterApplicationsScreenState
    extends ConsumerState<RecruiterApplicationsScreen> {
  int _tabIndex = 0; // 0: Received, 1: Approved/Rejected

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Applications'),
        body: EmptyState(
          title: 'Sign in required',
          subtitle: 'Please sign in to view applications.',
          icon: Icons.lock_outline_rounded,
        ),
      );
    }
    final userId = currentUser.uid;
    final postedJobsStream = ref
        .watch(jobsRepositoryProvider)
        .watchMyJobs(userId);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Applications'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: SegmentedButton<int>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: 0,
                  label: Text('Received'),
                  icon: Icon(Icons.inbox_outlined),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text('Approved/Rejected'),
                  icon: Icon(Icons.check_circle_outline),
                ),
              ],
              selected: {_tabIndex},
              onSelectionChanged: (s) => setState(() => _tabIndex = s.first),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: StreamBuilder<List<JobModel>>(
              stream: postedJobsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return EmptyState(
                    title: 'Unable to load jobs',
                    subtitle: 'Please try again.',
                    icon: Icons.error_outline_rounded,
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final jobs = snapshot.data!;
                if (jobs.isEmpty) {
                  return EmptyState(
                    title: 'No jobs posted yet',
                    subtitle: 'Post a job to receive applications.',
                    icon: Icons.work_outline_rounded,
                    ctaText: 'Post Job',
                  );
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: jobs.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return _JobWithAppsCard(
                      job: job,
                      theme: theme,
                      filterStatus: _tabIndex == 0
                          ? null
                          : ['approved', 'rejected'],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _JobWithAppsCard extends StatelessWidget {
  final JobModel job;
  final ThemeData theme;
  final List<String>? filterStatus;

  const _JobWithAppsCard({
    super.key,
    required this.job,
    required this.theme,
    this.filterStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return FutureBuilder<int>(
          future: ref
              .read(applicationsRepositoryProvider)
              .countApplicationsForJob(job.id, statuses: filterStatus),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final count = snapshot.data ?? 0;
            return AnimatedPressable(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      JobApplicantsScreen(jobId: job.id, jobTitle: job.title),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outline),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.work_rounded,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${job.company} · ${job.location}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$count Applications',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
