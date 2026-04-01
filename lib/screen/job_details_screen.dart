import 'dart:async';
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
                  job.skills.isEmpty 
                    ? const [Text('No specific skills listed')]
                    : job.skills
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
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
            if (postedBy != currentUserId && job.skills.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Skill Gap Analyzer 📊',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Consumer(
                builder: (context, ref, child) {
                  return ref.watch(userProfileStreamProvider(currentUserId)).when(
                    data: (user) {
                      if (user == null) return const SizedBox.shrink();
                      
                      final jobSkills = job.skills.split(',').map((e) => e.trim().toLowerCase()).where((e) => e.isNotEmpty).toList();
                      if (jobSkills.isEmpty) return const SizedBox.shrink();
                      
                      final userSkills = user.skills.split(',').map((e) => e.trim().toLowerCase()).where((e) => e.isNotEmpty).toSet();
                      
                      final missingSkills = jobSkills.where((js) => !userSkills.contains(js)).toList();
                      final matchPercentage = ((jobSkills.length - missingSkills.length) / jobSkills.length * 100).round();
                      
                      return Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: matchPercentage >= 70 ? Colors.green.withValues(alpha: 0.1) : (matchPercentage >= 40 ? Colors.orange.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1)),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: matchPercentage >= 70 ? Colors.green.withValues(alpha: 0.3) : (matchPercentage >= 40 ? Colors.orange.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3)),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Profile Match: $matchPercentage%',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: matchPercentage >= 70 ? Colors.green.shade800 : (matchPercentage >= 40 ? Colors.orange.shade800 : Colors.red.shade800),
                                  ),
                                ),
                                Icon(
                                  matchPercentage >= 70 ? Icons.check_circle_rounded : (matchPercentage >= 40 ? Icons.warning_rounded : Icons.error_rounded),
                                  color: matchPercentage >= 70 ? Colors.green : (matchPercentage >= 40 ? Colors.orange : Colors.red),
                                ),
                              ],
                            ),
                            if (missingSkills.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Missing Skills:',
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: missingSkills.map((s) => Chip(
                                  label: Text(s, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                  backgroundColor: Colors.red.shade400,
                                  visualDensity: VisualDensity.compact,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide.none),
                                )).toList(),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Consider adding these skills to your profile or learning them to improve your chances!',
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ] else ...[
                               const SizedBox(height: 8),
                               Text('Great job! You have all the required skills.', style: theme.textTheme.bodySmall?.copyWith(color: Colors.green.shade700)),
                            ],
                          ],
                        ),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox.shrink(),
                  );
                },
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Company',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
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
            Consumer(
              builder: (context, ref, child) {
                return ref.watch(responsivenessScoreProvider(postedBy)).when(
                  data: (score) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: AppSpacing.sm),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: score >= 80 ? Colors.green.withValues(alpha: 0.1) : (score >= 50 ? Colors.orange.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1)),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.bolt_rounded, color: score >= 80 ? Colors.green : (score >= 50 ? Colors.orange : Colors.red)),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Recruiter Responsiveness: $score%',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: score >= 80 ? Colors.green : (score >= 50 ? Colors.orange : Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
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
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: theme.colorScheme.surface,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (context) => _ApplyOptionsBottomSheet(
                    job: job,
                    currentUserId: currentUserId,
                    postedBy: postedBy,
                    resumeUrl: _resumeUrl,
                  ),
                );
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

class _ApplyOptionsBottomSheet extends ConsumerWidget {
  final JobModel job;
  final String currentUserId;
  final String postedBy;
  final String? resumeUrl;

  const _ApplyOptionsBottomSheet({
    required this.job,
    required this.currentUserId,
    required this.postedBy,
    required this.resumeUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Choose Application Method',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          OutlinedButton.icon(
            onPressed: () {
               Navigator.pop(context);
               showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: theme.colorScheme.surface,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (context) => _AICoverLetterBottomSheet(
                    job: job,
                    currentUserId: currentUserId,
                    postedBy: postedBy,
                    resumeUrl: resumeUrl,
                  ),
                );
            },
            icon: const Icon(Icons.auto_awesome_rounded, color: Colors.purple),
            label: const Text('Generate Cover Letter with AI ✨'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: BorderSide(color: Colors.purple.withOpacity(0.5), width: 1.5),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: () async {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Applying...')),
                );
                await ref
                    .read(applicationsRepositoryProvider)
                    .applyJob(
                      userId: currentUserId,
                      jobId: job.id,
                      recruiterId: postedBy,
                      resumeUrl: resumeUrl,
                    );
                await ref
                    .read(notificationsRepositoryProvider)
                    .sendNotification(
                      userId: postedBy,
                      title: 'New Job Application',
                      body: 'Someone applied to your job',
                      jobId: job.id,
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Application submitted!')),
                  );
                  Navigator.pop(context);
                }
            },
            icon: const Icon(Icons.flash_on_rounded),
            label: const Text('Quick Apply'),
            style: FilledButton.styleFrom(
               minimumSize: const Size(double.infinity, 56),
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _AICoverLetterBottomSheet extends ConsumerStatefulWidget {
  final JobModel job;
  final String currentUserId;
  final String postedBy;
  final String? resumeUrl;

  const _AICoverLetterBottomSheet({
    required this.job,
    required this.currentUserId,
    required this.postedBy,
    required this.resumeUrl,
  });

  @override
  ConsumerState<_AICoverLetterBottomSheet> createState() => _AICoverLetterBottomSheetState();
}

class _AICoverLetterBottomSheetState extends ConsumerState<_AICoverLetterBottomSheet> {
  String _typedText = "";
  String _fullText = "";
  Timer? _timer;
  bool _isFinished = false;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _generateText();
  }

  Future<void> _generateText() async {
    final user = await ref.read(userProfileStreamProvider(widget.currentUserId).future);
    final userName = user?.name ?? 'Applicant';
    final userSkills = user?.skills.split(',').firstOrNull ?? 'my skills';
    final companyName = widget.job.company.isNotEmpty ? widget.job.company : 'your company';
    final jobTitle = widget.job.title.isNotEmpty ? widget.job.title : 'this role';
    
    _fullText = "Dear Hiring Manager at $companyName,\n\nI am writing to express my strong interest in the $jobTitle position. With my background in $userSkills, I am confident in my ability to contribute effectively to your team. I am particularly drawn to this opportunity because of the innovative work you are doing in the industry.\n\nThank you for considering my application. I look forward to the possibility of discussing how my experience aligns with your needs.\n\nBest regards,\n$userName\n\n[ AI Generated Cover Letter ] ✨";

    int currentIndex = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 25), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (currentIndex < _fullText.length) {
        setState(() {
          _typedText += _fullText[currentIndex];
        });
        _textController.text = _typedText;
        currentIndex++;
      } else {
        timer.cancel();
        setState(() {
          _isFinished = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: Colors.purple),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'AI Cover Letter Maker',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (!_isFinished) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
               color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
               borderRadius: BorderRadius.circular(16),
               border: Border.all(color: Colors.purple.withOpacity(0.3)),
            ),
            child: TextField(
              controller: _textController,
              maxLines: null,
              readOnly: !_isFinished,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5, fontStyle: FontStyle.italic),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
               Expanded(
                 child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                 ),
               ),
               const SizedBox(width: AppSpacing.md),
               Expanded(
                 child: FilledButton(
                    onPressed: _isFinished ? () async {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Applying with AI Cover Letter...')),
                      );
                      await ref.read(applicationsRepositoryProvider).applyJob(
                        userId: widget.currentUserId,
                        jobId: widget.job.id,
                        recruiterId: widget.postedBy,
                        resumeUrl: widget.resumeUrl,
                        coverLetter: _textController.text.trim(),
                      );
                      await ref.read(notificationsRepositoryProvider).sendNotification(
                        userId: widget.postedBy,
                        title: 'New Job Application (AI Cover Letter)',
                        body: 'Someone applied to your job with an AI Cover Letter',
                        jobId: widget.job.id,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Application submitted!')),
                        );
                        // Also pop job details screen to go back
                        if (Navigator.canPop(context)) Navigator.pop(context);
                      }
                    } : null,
                    child: const Text('Submit Application'),
                 ),
               ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
