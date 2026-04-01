import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:hirelink1/core/di/providers.dart";
import "package:hirelink1/features/user/domain/models/user_model.dart";
import "package:hirelink1/theme/app_theme.dart";
import "package:url_launcher/url_launcher.dart";
import "edit_profile_screen.dart";
import "login_screen.dart";

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

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EditProfileScreen(),
              ),
            ),
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit Profile',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ref
          .watch(userProfileStreamProvider(uid))
          .when(
            data: (user) => _ProfileBody(user: user, theme: theme),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(
              child: Text(
                "Failed to load profile",
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final UserModel? user;
  final ThemeData theme;

  const _ProfileBody({required this.user, required this.theme});

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? "Your Name";
    final bio = user?.bio ?? "Add a bio";
    final imageUrl = user?.profileImageUrl ?? "";
    final resumeUrl = user?.resumeUrl ?? "";
    final completeness = _profileCompleteness(user);
    final completionPercent = (completeness * 100).round();
    final remaining = (16 - (completeness * 16).round()).clamp(0, 16);

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
                child: Stack(
                  children: [
                    Container(
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
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.surface,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
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
                  (user?.headline ?? "").trim().isEmpty
                      ? "Add your professional headline"
                      : (user?.headline ?? ""),
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
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: HirelinkColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: theme.brightness == Brightness.dark ? 0.18 : 0.05,
                    ),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Profile strength",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: HirelinkColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          "$completionPercent%",
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: HirelinkColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: completeness,
                      minHeight: 10,
                      backgroundColor: HirelinkColors.background,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        HirelinkColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    remaining == 0
                        ? "Great work. Your profile is complete."
                        : "Add $remaining more detail${remaining == 1 ? '' : 's'} to reach 100%.",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: HirelinkColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.auto_fix_high_rounded),
                      label: const Text("Improve Profile"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _ProfileSectionCard(
            title: "Basic Info",
            children: [
              _kv("Full Name", user?.name, "Not added"),
              _kv(
                "Profile Picture",
                imageUrl.isNotEmpty ? "Uploaded" : "",
                "Not uploaded",
              ),
              _kv("Headline", user?.headline, "Not added"),
              _kv("Bio / About Me", user?.bio, "Not added"),
              _kv("Location", user?.location, "Not added"),
              _kv("Email", user?.email, "Not added"),
              _kv("Phone Number", user?.phone, "Not added"),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileSectionCard(
            title: "Career Info",
            children: [
              _kv("Job Role (Desired Role)", user?.desiredRole, "Not added"),
              _kv("Experience Level", user?.experienceLevel, "Not added"),
              _kv("Skills", user?.skills, "Not added"),
              _kv("Languages Known", user?.languagesKnown, "Not added"),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileSectionCard(
            title: "Resume Section",
            children: [
              _kv(
                "Resume Upload",
                resumeUrl.isEmpty ? "" : "Resume uploaded",
                "Not uploaded",
              ),
              _LinkRow(
                label: "Resume URL",
                url: resumeUrl,
                emptyText: "Not added",
              ),
              _LinkRow(
                label: "GitHub",
                url: user?.portfolioGithub ?? "",
                emptyText: "Not added",
              ),
              _LinkRow(
                label: "LinkedIn",
                url: user?.portfolioLinkedin ?? "",
                emptyText: "Not added",
              ),
              _LinkRow(
                label: "Personal Website",
                url: user?.portfolioWebsite ?? "",
                emptyText: "Not added",
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.upload_file_rounded),
                    label: Text(
                      resumeUrl.isEmpty ? "Upload Resume" : "Replace Resume",
                    ),
                  ),
                  if (resumeUrl.isNotEmpty) const SizedBox(width: 8),
                  if (resumeUrl.isNotEmpty)
                    OutlinedButton.icon(
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
                      label: const Text("View"),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileSectionCard(
            title: "Education",
            children: [
              _kv("Degree", user?.educationDegree, "Not added"),
              _kv("College Name", user?.educationCollege, "Not added"),
              _kv("Year of Passing", user?.educationYear, "Not added"),
              _kv("CGPA / Percentage", user?.educationScore, "Not added"),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileSectionCard(
            title: "Projects / Experience",
            children: [
              _kv("Project Title", user?.projectTitle, "Not added"),
              _kv("Description", user?.projectDescription, "Not added"),
              _kv("Technologies Used", user?.projectTechnologies, "Not added"),
              _LinkRow(
                label: "Project Link",
                url: user?.projectLink ?? "",
                emptyText: "Not added",
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileSectionCard(
            title: "Achievements",
            children: [
              _kv("Certifications", user?.certifications, "Not added"),
              _kv("Awards", user?.awards, "Not added"),
              _kv("Hackathons", user?.hackathons, "Not added"),
            ],
          ),
          const SizedBox.shrink(),

          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Log out'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      FilledButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          await FirebaseAuth.instance.signOut();
                          if (!context.mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (_) => false,
                          );
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Log out'),
                      ),
                    ],
                  ),
                ),

                icon: const Icon(Icons.logout_rounded),
                label: const Text("Log Out"),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

Widget _kv(String label, String? value, String fallback) {
  final v = (value ?? "").trim();
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(color: HirelinkColors.textPrimary, height: 1.45),
        children: [
          TextSpan(
            text: "$label: ",
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
    if (clean.isEmpty) return _kv(label, "", emptyText);
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
            label: const Text("Open"),
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
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}
