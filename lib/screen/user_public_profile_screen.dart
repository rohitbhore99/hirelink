import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hirelink1/core/di/providers.dart';
import 'package:hirelink1/features/user/domain/models/user_model.dart';
import 'package:hirelink1/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

double _profileCompleteness(UserModel? user) {
  if (user == null) return 0;
  bool has(String? v) => (v ?? '').trim().isNotEmpty;
  final checks = <bool>[
    user.name.trim().isNotEmpty,
    user.profileImageUrl.trim().isNotEmpty,
    has(user.headline),
    user.bio.trim().isNotEmpty,
    has(user.location),
    user.email.trim().isNotEmpty,
    user.phone.trim().isNotEmpty,
    has(user.desiredRole),
    has(user.experienceLevel),
    user.skills.trim().isNotEmpty,
    has(user.languagesKnown),
    user.resumeUrl.trim().isNotEmpty,
    has(user.educationDegree),
    has(user.educationCollege),
    has(user.projectTitle),
    has(user.certifications) || has(user.awards) || has(user.hackathons),
  ];
  final filled = checks.where((e) => e).length;
  return checks.isEmpty ? 0 : (filled / checks.length);
}

class UserPublicProfileScreen extends ConsumerWidget {
  final String userId;
  final bool blindMode;

  const UserPublicProfileScreen({super.key, required this.userId, this.blindMode = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ref
          .watch(userProfileStreamProvider(userId))
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(
              child: Text(
                'Failed to load profile',
                style: theme.textTheme.bodyLarge,
              ),
            ),
            data: (user) {
              if (user == null) {
                return Center(
                  child: Text(
                    'Profile not found',
                    style: theme.textTheme.bodyLarge,
                  ),
                );
              }
              return _PublicProfileBody(user: user, theme: theme, blindMode: blindMode);
            },
          ),
    );
  }
}

class _PublicProfileBody extends ConsumerWidget {
  final UserModel user;
  final ThemeData theme;
  final bool blindMode;

  const _PublicProfileBody({required this.user, required this.theme, this.blindMode = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = blindMode ? 'Candidate (Blind Hiring Mode)' : (user.name.isEmpty ? 'Unknown User' : user.name);
    final bio = user.bio.isEmpty ? 'No bio added' : user.bio;
    final imageUrl = blindMode ? '' : user.profileImageUrl;
    final resumeUrl = user.resumeUrl;
    final completeness = _profileCompleteness(user);
    final completionPercent = (completeness * 100).round();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 110,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: HirelinkColors.primaryGradient,
                ),
              ),
              Positioned(
                left: 20,
                bottom: -42,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.surface,
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: HirelinkColors.primaryContainerLight,
                      backgroundImage: imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl)
                          : null,
                      child: imageUrl.isEmpty
                          ? Icon(
                              Icons.person_rounded,
                              size: 48,
                              color: HirelinkColors.primary,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: HirelinkColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  (user.headline ?? '').trim().isEmpty
                      ? 'No headline added'
                      : (user.headline ?? ''),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: HirelinkColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  bio,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: HirelinkColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _ProfileSectionCard(
            title: 'Basic Info',
            children: [
              _kv('Full Name', name, 'Not added'),
              _kv(
                'Profile Picture',
                imageUrl.isNotEmpty ? 'Uploaded' : (blindMode ? 'Hidden in blind mode' : ''),
                'Not uploaded',
              ),
              _kv('Headline', user.headline, 'Not added'),
              _kv('Bio / About Me', user.bio, 'Not added'),
              _kv('Location', blindMode ? 'Hidden' : user.location, 'Not added'),
              _kv('Email', blindMode ? 'Hidden' : user.email, 'Not added'),
              _kv('Phone Number', blindMode ? 'Hidden' : user.phone, 'Not added'),
              if (user.role == 'recruiter' || user.role == 'employer')
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ref.watch(responsivenessScoreProvider(user.uid)).when(
                    data: (score) => _kv('Responsiveness Score 👻', '$score%', 'N/A'),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileSectionCard(
            title: 'Career Info',
            children: [
              _kv('Job Role (Desired Role)', user.desiredRole, 'Not added'),
              _kv('Experience Level', user.experienceLevel, 'Not added'),
              _kv('Skills', user.skills, 'Not added'),
              _kv('Languages Known', user.languagesKnown, 'Not added'),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileSectionCard(
            title: 'Resume Section',
            children: [
              _kv(
                'Resume Upload',
                resumeUrl.isEmpty ? '' : 'Resume uploaded',
                'Not uploaded',
              ),
              _LinkRow(
                label: 'Resume URL',
                url: resumeUrl,
                emptyText: 'Not added',
              ),
              _LinkRow(
                label: 'GitHub',
                url: blindMode ? '' : (user.portfolioGithub ?? ''),
                emptyText: blindMode ? 'Hidden in blind mode' : 'Not added',
              ),
              _LinkRow(
                label: 'LinkedIn',
                url: blindMode ? '' : (user.portfolioLinkedin ?? ''),
                emptyText: blindMode ? 'Hidden in blind mode' : 'Not added',
              ),
              _LinkRow(
                label: 'Personal Website',
                url: blindMode ? '' : (user.portfolioWebsite ?? ''),
                emptyText: blindMode ? 'Hidden in blind mode' : 'Not added',
              ),
              if (resumeUrl.isNotEmpty && !blindMode)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      if (resumeUrl.isEmpty) return;
                      final uri = Uri.tryParse(resumeUrl);
                      if (uri != null) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('View Resume'),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileSectionCard(
            title: 'Education',
            children: [
              _kv('Degree', user.educationDegree, 'Not added'),
              _kv('College Name', user.educationCollege, 'Not added'),
              _kv('Year of Passing', user.educationYear, 'Not added'),
              _kv('CGPA / Percentage', user.educationScore, 'Not added'),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileSectionCard(
            title: 'Projects / Experience',
            children: [
              _kv('Project Title', user.projectTitle, 'Not added'),
              _kv('Description', user.projectDescription, 'Not added'),
              _kv('Technologies Used', user.projectTechnologies, 'Not added'),
              _LinkRow(
                label: 'Project Link',
                url: user.projectLink ?? '',
                emptyText: 'Not added',
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileSectionCard(
            title: 'Achievements',
            children: [
              _kv('Certifications', user.certifications, 'Not added'),
              _kv('Awards', user.awards, 'Not added'),
              _kv('Hackathons', user.hackathons, 'Not added'),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

Widget _kv(String label, String? value, String fallback) {
  final v = (value ?? '').trim();
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(color: HirelinkColors.textPrimary, height: 1.45),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: v.isEmpty ? fallback : v,
            style: TextStyle(
              color: v.isEmpty
                  ? HirelinkColors.textSecondary
                  : HirelinkColors.textPrimary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    ),
  );
}

class _LinkRow extends StatelessWidget {
  final String label;
  final String url;
  final String emptyText;

  const _LinkRow({
    required this.label,
    required this.url,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    final clean = url.trim();
    if (clean.isEmpty) return _kv(label, '', emptyText);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: _kv(label, clean, emptyText)),
          TextButton.icon(
            onPressed: () async {
              final uri = Uri.tryParse(clean);
              if (uri != null) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: const Text('Open'),
          ),
        ],
      ),
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileSectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: HirelinkColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}
