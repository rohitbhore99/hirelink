import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hirelink1/core/di/providers.dart';
import 'package:hirelink1/theme/app_theme.dart';
import 'package:hirelink1/features/jobs/domain/models/job_model.dart';
import 'package:hirelink1/screen/chat_screen.dart';
import 'package:hirelink1/screen/job_details_screen.dart';
import 'package:hirelink1/screen/user_public_profile_screen.dart';
import 'package:hirelink1/core/theme/app_radius.dart';
import 'package:hirelink1/core/theme/app_spacing.dart';

class JobCard extends ConsumerStatefulWidget {
  final JobModel job;
  final bool showBookmark;

  const JobCard({super.key, required this.job, this.showBookmark = false});

  @override
  ConsumerState<JobCard> createState() => _JobCardState();
}

class _JobCardState extends ConsumerState<JobCard> {
  bool _pressed = false;

  static String _companyInitial(String company) {
    final t = company.trim();
    if (t.isEmpty) return '?';
    return t[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final company = widget.job.company.isNotEmpty
        ? widget.job.company
        : 'Company';
    final title = widget.job.title.isNotEmpty ? widget.job.title : 'Job title';
    final scale = _pressed ? 0.985 : 1.0;
    final heroTag = 'job-card-${widget.job.id}';

    int? matchPercentage;
    final userProfileAsync = ref.watch(userProfileStreamProvider(currentUserId));
    final userProfile = userProfileAsync.valueOrNull;
    if (userProfile != null) {
      final jobSkills = widget.job.skills.split(',').map((e) => e.trim().toLowerCase()).where((e) => e.isNotEmpty).toList();
      if (jobSkills.isNotEmpty) {
        final userSkills = userProfile.skills.split(',').map((e) => e.trim().toLowerCase()).where((e) => e.isNotEmpty).toSet();
        final missingSkills = jobSkills.where((js) => !userSkills.contains(js)).toList();
        matchPercentage = ((jobSkills.length - missingSkills.length) / jobSkills.length * 100).round();
      }
    }

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 150),
      child: Hero(
        tag: heroTag,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTapDown: (_) => setState(() => _pressed = true),
            onTapCancel: () => setState(() => _pressed = false),
            onTap: () {
              setState(() => _pressed = false);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => JobDetailsScreen(job: widget.job),
                ),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutQuint,
              padding: const EdgeInsets.all(AppSpacing.md + 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(
                      alpha: theme.brightness == Brightness.dark ? 0.4 : 0.05,
                    ),
                    blurRadius: _pressed ? 8 : 24,
                    offset: _pressed ? const Offset(0, 4) : const Offset(0, 12),
                    spreadRadius: _pressed ? 0 : -4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserPublicProfileScreen(
                              userId: widget.job.postedBy,
                            ),
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: theme.colorScheme.primaryContainer
                              .withValues(alpha: 0.7),
                          child: Text(
                            _companyInitial(company),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (matchPercentage != null && matchPercentage > 0)
                              Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF10B981).withOpacity(0.2),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '$matchPercentage% Match',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: const Color(0xFF10B981), // glowing green
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      JobDetailsScreen(job: widget.job),
                                ),
                              ),
                              child: Text(
                                title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$company · ${widget.job.location}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: HirelinkColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (widget.job.postedBy != currentUserId)
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ChatScreen(otherUserId: widget.job.postedBy),
                            ),
                          ),
                          icon: Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: HirelinkColors.primary,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _MetaChip(label: widget.job.type, theme: theme),
                      _MetaChip(label: widget.job.salary, theme: theme),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FutureBuilder<bool>(
                    future: ref
                        .read(applicationsRepositoryProvider)
                        .hasApplied(
                          userId: currentUserId,
                          jobId: widget.job.id,
                        ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 40,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      final applied = snapshot.data ?? false;
                      if (applied) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: HirelinkColors.success.withValues(
                              alpha: 0.08,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: HirelinkColors.success.withValues(
                                alpha: 0.35,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                color: HirelinkColors.success,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Applied',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: HirelinkColors.success,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () async {
                            await ref
                                .read(applicationsRepositoryProvider)
                                .applyJob(
                                  userId: currentUserId,
                                  jobId: widget.job.id,
                                  recruiterId: widget.job.postedBy,
                                );
                            await ref
                                .read(notificationsRepositoryProvider)
                                .sendNotification(
                                  userId: widget.job.postedBy,
                                  title: 'New Job Application',
                                  body: 'Someone applied to your job',
                                  jobId: widget.job.id,
                                );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Application sent!'),
                                ),
                              );
                            }
                          },
                          child: const Text('Apply'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final ThemeData theme;

  const _MetaChip({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? HirelinkColors.darkBorder.withValues(alpha: 0.5)
            : const Color(0xFFF3F2EF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: HirelinkColors.textMuted,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
