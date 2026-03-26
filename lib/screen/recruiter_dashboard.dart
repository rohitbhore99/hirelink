import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hirelink1/core/di/providers.dart';
import 'package:hirelink1/features/jobs/domain/models/job_model.dart';
import 'package:hirelink1/features/user/domain/models/user_model.dart';
import 'package:hirelink1/features/applications/domain/repositories/applications_repository.dart';
import 'package:hirelink1/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:hirelink1/features/user/domain/repositories/user_repository.dart';
import 'package:hirelink1/screen/chat_screen.dart';
import 'package:hirelink1/widgets/empty_state.dart';

class RecruiterDashboard extends ConsumerWidget {
  const RecruiterDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final jobsStream = ref.watch(jobsRepositoryProvider).watchMyJobs(userId);
    final applicationsRepo = ref.watch(applicationsRepositoryProvider);
    final notificationsRepo = ref.watch(notificationsRepositoryProvider);
    final userRepo = ref.watch(userRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Posted Jobs')),
      body: StreamBuilder<List<JobModel>>(
        stream: jobsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final jobs = snapshot.data!;
          if (jobs.isEmpty) {
            return EmptyState(title: 'No jobs posted yet', subtitle: 'Post your first job from the Discover tab.', icon: Icons.business_center_rounded);
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatChip(icon: Icons.work_rounded, value: '${jobs.length}', label: 'Jobs posted', theme: theme),
                    FutureBuilder<int>(
                      future: applicationsRepo.countApplicationsForJobIds(jobs.map((j) => j.id).toList()),
                      builder: (context, snap) {
                        final n = snap.data;
                        return _StatChip(
                          icon: Icons.people_rounded,
                          value: n == null ? '…' : '$n',
                          label: 'Total applications',
                          theme: theme,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...jobs.asMap().entries.map((e) => Padding(
                padding: EdgeInsets.only(bottom: e.key < jobs.length - 1 ? 12 : 0),
                child: _buildJobTile(context, ref, theme, e.value, applicationsRepo, notificationsRepo, userRepo),
              )),
            ],
          );
        },
      ),
    );
  }

  Widget _buildJobTile(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    JobModel job,
    ApplicationsRepository applicationsRepo,
    NotificationsRepository notificationsRepo,
    UserRepository userRepo,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(20),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: Text(job.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(job.company, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: applicationsRepo.watchApplicationsForJob(job.id),
            builder: (context, appSnapshot) {
              if (!appSnapshot.hasData) {
                return const Padding(padding: EdgeInsets.all(16), child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))));
              }
              final applications = [...appSnapshot.data!.docs]
                ..sort((a, b) {
                  final at = (a.data() as Map<String, dynamic>?)?['appliedAt'] as Timestamp?;
                  final bt = (b.data() as Map<String, dynamic>?)?['appliedAt'] as Timestamp?;
                  return (bt?.toDate() ?? DateTime(0)).compareTo(at?.toDate() ?? DateTime(0));
                });
              if (applications.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('No applicants yet', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: applications.map((app) {
                  final applicantId = app['applicantId'] as String? ?? app['userId'] as String? ?? '';
                  final status = app['status'] as String? ?? 'applied';
                  final resumeUrl = app['resumeUrl'] as String? ?? '';
                            return FutureBuilder<UserModel?>(
                              future: userRepo.getUser(applicantId),
                              builder: (context, userSnap) {
                                final name = userSnap.data?.name ?? 'Applicant';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                                  Text(_statusLabel(status), style: theme.textTheme.bodySmall?.copyWith(color: _statusColor(status))),
                                ],
                              ),
                            ),
                            if (resumeUrl.isNotEmpty)
                              IconButton(
                                icon: Icon(Icons.description_outlined, color: theme.colorScheme.primary),
                                onPressed: () => _openUrl(resumeUrl),
                              ),
                            IconButton(
                              icon: Icon(Icons.chat_bubble_outline_rounded, color: theme.colorScheme.primary),
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(otherUserId: applicantId))),
                            ),
                            IconButton(
                              icon: Icon(Icons.hourglass_empty_rounded, color: theme.colorScheme.tertiary),
                              onPressed: status == 'applied' ? () async {
                                await applicationsRepo.updateApplicationStatus(app.id, 'under_review');
                                await notificationsRepo.sendNotification(userId: applicantId, title: 'Application Update', body: 'Your application for ${job.title} is under review');
                              } : null,
                            ),
                            IconButton(
                              icon: Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary),
                              onPressed: () async {
                                await applicationsRepo.updateApplicationStatus(app.id, 'accepted');
                                await notificationsRepo.sendNotification(userId: applicantId, title: 'Application Accepted', body: 'Congratulations! You have been accepted for ${job.title}');
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.cancel_rounded, color: theme.colorScheme.error),
                              onPressed: () async {
                                await applicationsRepo.updateApplicationStatus(app.id, 'rejected');
                                await notificationsRepo.sendNotification(userId: applicantId, title: 'Application Update', body: 'Your application for ${job.title} was not successful');
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final ThemeData theme;

  const _StatChip({required this.icon, required this.value, required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

String _statusLabel(String s) {
  switch (s) {
    case 'accepted': return 'Accepted';
    case 'rejected': return 'Rejected';
    case 'under_review': return 'Under review';
    default: return 'Applied';
  }
}

Color _statusColor(String s) {
  switch (s) {
    case 'accepted': return const Color(0xFF059669);
    case 'rejected': return const Color(0xFFDC2626);
    case 'under_review': return const Color(0xFFD97706);
    default: return const Color(0xFF2563EB);
  }
}

Future<void> _openUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri != null && await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
