import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hirelink1/core/di/providers.dart';
import 'package:hirelink1/features/jobs/domain/models/job_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hirelink1/screen/chat_screen.dart';
import 'package:hirelink1/core/theme/app_spacing.dart';
import 'package:hirelink1/core/theme/app_radius.dart';

class JobDetailsScreen extends StatefulWidget {
  final JobModel job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  String? _resumeUrl;
  bool _uploadingResume = false;

  Future<void> _pickAndUploadResume() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;
    if (!mounted) return;
    final container = ProviderScope.containerOf(context);
    setState(() => _uploadingResume = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final url = await container
          .read(storageServiceProvider)
          .uploadResume(
            userId: uid,
            jobId: widget.job.id,
            bytes: result.files.single.bytes!,
            fileName: result.files.single.name,
          );
      if (mounted) setState(() => _resumeUrl = url);
    } finally {
      if (mounted) setState(() => _uploadingResume = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final theme = Theme.of(context);
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final postedBy = job.postedBy;
    final container = ProviderScope.containerOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Role Details'),
        actions: [
          if (postedBy != currentUserId)
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(otherUserId: postedBy),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          80,
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'job-card-${job.id}',
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.65,
                      ),
                      theme.colorScheme.surface,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.business_rounded,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title.isNotEmpty ? job.title : 'Untitled Role',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            job.company.isNotEmpty
                                ? job.company
                                : 'Unknown Company',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (job.companyUrl?.isNotEmpty ?? false) ...[
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () async {
                                final rawUrl = job.companyUrl!.trim();
                                if (rawUrl.isEmpty) return;
                                var url = rawUrl;
                                if (!url.startsWith('http://') &&
                                    !url.startsWith('https://')) {
                                  url = 'https://$url';
                                }
                                try {
                                  await launch(url);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Could not open URL'),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                job.companyUrl!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (job.urgentHiring)
                  _Tag(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Urgent',
                    theme: theme,
                  ),
                if (job.fresherFriendly)
                  _Tag(
                    icon: Icons.school,
                    label: 'Fresher friendly',
                    theme: theme,
                  ),
                _Tag(
                  icon: Icons.schedule_rounded,
                  label: job.type,
                  theme: theme,
                ),
                _Tag(
                  icon: Icons.work_outline_rounded,
                  label: job.workMode,
                  theme: theme,
                ),
                _Tag(
                  icon: Icons.location_on_outlined,
                  label: job.location,
                  theme: theme,
                ),
                _Tag(
                  icon: Icons.attach_money_rounded,
                  label: job.notDisclosed ? 'Not disclosed' : job.salary,
                  theme: theme,
                ),
                _Tag(
                  icon: Icons.bar_chart_rounded,
                  label: job.experienceLevel,
                  theme: theme,
                ),

                if (job.applicationDeadline != null)
                  _Tag(
                    icon: Icons.calendar_today,
                    label:
                        'Deadline: ${job.applicationDeadline!.toLocal().toString().split(' ')[0]}',
                    theme: theme,
                  ),
                if (job.joiningDate != null)
                  _Tag(
                    icon: Icons.event,
                    label:
                        'Joining: ${job.joiningDate!.toLocal().toString().split(' ')[0]}',
                    theme: theme,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'About',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              job.description.isNotEmpty
                  ? job.description
                  : 'No description provided yet.',
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (job.responsibilities.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Responsibilities',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                job.responsibilities,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ],
            if (job.dailyActivities.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Daily Activities',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                job.dailyActivities,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Skills',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children:
                  (job.description
                          .split(RegExp(r'\s+'))
                          .where((e) => e.length > 4)
                          .take(6))
                      .map(
                        (s) => Chip(
                          label: Text(s),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: Text(
                'Company',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.35,
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                '${job.company} · ${job.location}',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (postedBy != currentUserId)
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(otherUserId: postedBy),
                  ),
                ),
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                label: const Text('Message Recruiter'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            if (postedBy != currentUserId)
              const SizedBox(height: AppSpacing.sm),
            if (postedBy != currentUserId)
              OutlinedButton.icon(
                onPressed: _uploadingResume ? null : _pickAndUploadResume,
                icon: _uploadingResume
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _resumeUrl != null
                            ? Icons.check_circle_rounded
                            : Icons.attach_file_rounded,
                      ),
                label: Text(
                  _resumeUrl != null
                      ? 'Resume attached'
                      : 'Attach Resume (optional)',
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(AppSpacing.md),
        child: FutureBuilder<bool>(
          future: container
              .read(applicationsRepositoryProvider)
              .hasApplied(userId: currentUserId, jobId: job.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 50,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final applied = snapshot.data ?? false;
            if (applied) {
              return FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text('Already Applied'),
              );
            }
            return FilledButton(
              onPressed: () async {
                await container
                    .read(applicationsRepositoryProvider)
                    .applyJob(
                      userId: currentUserId,
                      jobId: job.id,
                      recruiterId: postedBy,
                      resumeUrl: _resumeUrl,
                    );
                await container
                    .read(notificationsRepositoryProvider)
                    .sendNotification(
                      userId: postedBy,
                      title: 'New Job Application',
                      body: 'Someone applied to your job',
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Application submitted!')),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Apply'),
            );
          },
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;

  const _Tag({required this.icon, required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
