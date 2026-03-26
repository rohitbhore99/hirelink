import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hirelink1/core/di/providers.dart';
import 'package:hirelink1/core/theme/app_spacing.dart';
import 'package:hirelink1/core/widgets/animated_pressable.dart';
import 'package:hirelink1/features/jobs/domain/models/job_model.dart';
import 'package:hirelink1/widgets/custom_app_bar.dart';
import 'package:hirelink1/widgets/empty_state.dart';
import 'package:hirelink1/screen/job_applicants_screen.dart';
import 'package:hirelink1/screen/edit_job_screen.dart';

class ApplicationsScreen extends ConsumerStatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  ConsumerState<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends ConsumerState<ApplicationsScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'My Applications'),
        body: EmptyState(
          title: 'Sign in required',
          subtitle: 'Please sign in to view your job applications.',
          icon: Icons.lock_outline_rounded,
        ),
      );
    }
    final userId = currentUser.uid;
    final applicationsStream = ref
        .watch(applicationsRepositoryProvider)
        .watchUserApplications(userId);
    final postedJobsStream = ref
        .watch(jobsRepositoryProvider)
        .watchMyJobs(userId);
    final jobsRepo = ref.watch(jobsRepositoryProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Jobs'),
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
                  label: Text('Applied Jobs'),
                  icon: Icon(Icons.assignment_turned_in_outlined),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text('Posted Jobs'),
                  icon: Icon(Icons.cases_outlined),
                ),
              ],
              selected: {_tabIndex},
              onSelectionChanged: (s) => setState(() => _tabIndex = s.first),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: _tabIndex == 0
                ? StreamBuilder<QuerySnapshot>(
                    stream: applicationsStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return EmptyState(
                          title: 'Unable to load applications',
                          subtitle: 'Please try again in a moment.',
                          icon: Icons.error_outline_rounded,
                        );
                      }
                      if (!snapshot.hasData)
                        return const Center(child: CircularProgressIndicator());
                      final applications = [...snapshot.data!.docs]
                        ..sort((a, b) {
                          final at =
                              (a.data() as Map<String, dynamic>?)?['appliedAt']
                                  as Timestamp?;
                          final bt =
                              (b.data() as Map<String, dynamic>?)?['appliedAt']
                                  as Timestamp?;
                          return (bt?.toDate() ?? DateTime(0)).compareTo(
                            at?.toDate() ?? DateTime(0),
                          );
                        });
                      if (applications.isEmpty) {
                        return EmptyState(
                          title: 'No applied jobs yet',
                          subtitle: 'Apply to jobs from the Home tab.',
                          icon: Icons.assignment_outlined,
                        );
                      }
                      return ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: applications.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final app = applications[index];
                          final map =
                              app.data() as Map<String, dynamic>? ?? const {};
                          final jobId = map['jobId']?.toString() ?? '';
                          final status = map['status']?.toString() ?? 'applied';
                          return FutureBuilder<JobModel?>(
                            future: jobsRepo.getJob(jobId),
                            builder: (context, jobSnapshot) {
                              if (!jobSnapshot.hasData) {
                                return const SizedBox.shrink();
                              }
                              final job = jobSnapshot.data;
                              if (job == null)
                                return _missingCard(theme, status);
                              return _jobCard(
                                theme,
                                title: job.title,
                                subtitle: job.company,
                                status: status,
                              );
                            },
                          );
                        },
                      );
                    },
                  )
                : StreamBuilder<List<JobModel>>(
                    stream: postedJobsStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return EmptyState(
                          title: 'Unable to load posted jobs',
                          subtitle: 'Please try again in a moment.',
                          icon: Icons.error_outline_rounded,
                        );
                      }
                      if (!snapshot.hasData)
                        return const Center(child: CircularProgressIndicator());
                      final posted = [...snapshot.data!]
                        ..sort(
                          (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
                            a.createdAt ?? DateTime(0),
                          ),
                        );
                      if (posted.isEmpty) {
                        return EmptyState(
                          title: 'No posted jobs yet',
                          subtitle: 'Post a new job from the Post tab.',
                          icon: Icons.work_outline_rounded,
                        );
                      }
                      return ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: posted.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),

                        itemBuilder: (context, index) {
                          final job = posted[index];
                          return _jobCard(
                            theme,
                            title: job.title,
                            subtitle: '${job.company} · ${job.location}',
                            status: 'posted',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditJobScreen(job: job),
                              ),
                            ),
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

Widget _loadingCard(ThemeData theme) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: theme.colorScheme.outlineVariant.withOpacity(0.5),
      ),
    ),
    child: const Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 16),
        Text('Loading...'),
      ],
    ),
  );
}

Widget _missingCard(ThemeData theme, String status) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: theme.colorScheme.outlineVariant.withOpacity(0.5),
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.work_off_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Job not available',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'This posting may have been removed',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _statusColor(status).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (status.toLowerCase() == 'accepted') ...[
                  const Icon(Icons.check_circle_rounded, color: Colors.blue, size: 14),
                  const SizedBox(width: 4),
                ] else if (status.toLowerCase() == 'rejected') ...[
                  const Icon(Icons.cancel_rounded, color: Colors.red, size: 14),
                  const SizedBox(width: 4),
                ],
                Text(
                  _statusLabel(status),
                  style: TextStyle(
                    color: _statusColor(status),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

Widget _jobCard(
  ThemeData theme, {
  required String title,
  required String subtitle,
  required String status,
  VoidCallback? onTap,
}) {
  return AnimatedPressable(
    borderRadius: BorderRadius.circular(16),
    onTap: onTap ?? () {},
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.work_rounded, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _statusColor(status).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (status.toLowerCase() == 'accepted') ...[
                  const Icon(Icons.check_circle_rounded, color: Colors.blue, size: 14),
                  const SizedBox(width: 4),
                ] else if (status.toLowerCase() == 'rejected') ...[
                  const Icon(Icons.cancel_rounded, color: Colors.red, size: 14),
                  const SizedBox(width: 4),
                ],
                Text(
                  _statusLabel(status),
                  style: TextStyle(
                    color: _statusColor(status),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

String _statusLabel(String s) {
  switch (s.toLowerCase()) {
    case 'accepted':
      return 'Accepted';
    case 'rejected':
      return 'Rejected';
    case 'under_review':
      return 'Under review';
    case 'posted':
      return 'Posted';
    default:
      return 'Applied';
  }
}

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'accepted':
      return const Color(0xFF059669);
    case 'rejected':
      return const Color(0xFFDC2626);
    case 'under_review':
      return const Color(0xFFD97706);
    case 'posted':
      return const Color(0xFF7C3AED);
    default:
      return const Color(0xFF2563EB);
  }
}
