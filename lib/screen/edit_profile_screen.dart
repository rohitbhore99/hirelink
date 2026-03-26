import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hirelink1/core/di/providers.dart';
import 'package:hirelink1/core/theme/app_spacing.dart';
import 'package:hirelink1/core/theme/app_radius.dart';
import 'package:url_launcher/url_launcher.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final nameController = TextEditingController();
  final headlineController = TextEditingController();
  final skillsController = TextEditingController();
  final bioController = TextEditingController();
  final locationController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final desiredRoleController = TextEditingController();
  final experienceLevelController = TextEditingController();
  final languagesKnownController = TextEditingController();
  final githubController = TextEditingController();
  final linkedinController = TextEditingController();
  final websiteController = TextEditingController();
  final educationDegreeController = TextEditingController();
  final educationCollegeController = TextEditingController();
  final educationYearController = TextEditingController();
  final educationScoreController = TextEditingController();
  final projectTitleController = TextEditingController();
  final projectDescriptionController = TextEditingController();
  final projectTechnologiesController = TextEditingController();
  final projectLinkController = TextEditingController();
  final certificationsController = TextEditingController();
  final awardsController = TextEditingController();
  final hackathonsController = TextEditingController();

  bool isLoading = true;
  String profileImageUrl = "";
  String resumeUrl = "";

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    headlineController.dispose();
    skillsController.dispose();
    bioController.dispose();
    locationController.dispose();
    emailController.dispose();
    phoneController.dispose();
    desiredRoleController.dispose();
    experienceLevelController.dispose();
    languagesKnownController.dispose();
    githubController.dispose();
    linkedinController.dispose();
    websiteController.dispose();
    educationDegreeController.dispose();
    educationCollegeController.dispose();
    educationYearController.dispose();
    educationScoreController.dispose();
    projectTitleController.dispose();
    projectDescriptionController.dispose();
    projectTechnologiesController.dispose();
    projectLinkController.dispose();
    certificationsController.dispose();
    awardsController.dispose();
    hackathonsController.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final user = await ref.read(userRepositoryProvider).getUser(uid);
    if (!mounted) return;
    if (user != null) {
      nameController.text = user.name;
      headlineController.text = user.headline ?? '';
      skillsController.text = user.skills;
      bioController.text = user.bio;
      locationController.text = user.location ?? '';
      emailController.text = user.email;
      phoneController.text = user.phone;
      desiredRoleController.text = user.desiredRole ?? '';
      experienceLevelController.text = user.experienceLevel ?? '';
      languagesKnownController.text = user.languagesKnown ?? '';
      githubController.text = user.portfolioGithub ?? '';
      linkedinController.text = user.portfolioLinkedin ?? '';
      websiteController.text = user.portfolioWebsite ?? '';
      educationDegreeController.text = user.educationDegree ?? '';
      educationCollegeController.text = user.educationCollege ?? '';
      educationYearController.text = user.educationYear ?? '';
      educationScoreController.text = user.educationScore ?? '';
      projectTitleController.text = user.projectTitle ?? '';
      projectDescriptionController.text = user.projectDescription ?? '';
      projectTechnologiesController.text = user.projectTechnologies ?? '';
      projectLinkController.text = user.projectLink ?? '';
      certificationsController.text = user.certifications ?? '';
      awardsController.text = user.awards ?? '';
      hackathonsController.text = user.hackathons ?? '';
      profileImageUrl = user.profileImageUrl;
      resumeUrl = user.resumeUrl;
    }
    setState(() => isLoading = false);
  }

  Future<void> saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await ref.read(userRepositoryProvider).updateUser(uid, {
      "name": nameController.text.trim(),
      "headline": headlineController.text.trim(),
      "skills": skillsController.text.trim(),
      "bio": bioController.text.trim(),
      "location": locationController.text.trim(),
      "email": emailController.text.trim(),
      "phone": phoneController.text.trim(),
      "desiredRole": desiredRoleController.text.trim(),
      "experienceLevel": experienceLevelController.text.trim(),
      "languagesKnown": languagesKnownController.text.trim(),
      "portfolioGithub": githubController.text.trim(),
      "portfolioLinkedin": linkedinController.text.trim(),
      "portfolioWebsite": websiteController.text.trim(),
      "educationDegree": educationDegreeController.text.trim(),
      "educationCollege": educationCollegeController.text.trim(),
      "educationYear": educationYearController.text.trim(),
      "educationScore": educationScoreController.text.trim(),
      "projectTitle": projectTitleController.text.trim(),
      "projectDescription": projectDescriptionController.text.trim(),
      "projectTechnologies": projectTechnologiesController.text.trim(),
      "projectLink": projectLinkController.text.trim(),
      "certifications": certificationsController.text.trim(),
      "awards": awardsController.text.trim(),
      "hackathons": hackathonsController.text.trim(),
      "profileImageUrl": profileImageUrl,
      "resumeUrl": resumeUrl,
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated")));
    Navigator.pop(context);
  }

  Future<void> pickAndUploadImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result == null || result.files.single.bytes == null) return;
    setState(() => isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final url = await ref.read(storageServiceProvider).uploadProfileImage(uid: uid, bytes: result.files.single.bytes!);
      if (mounted) setState(() => profileImageUrl = url);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> pickAndUploadResume() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;
    setState(() => isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final url = await ref.read(storageServiceProvider).uploadResume(
            userId: uid,
            jobId: 'profile',
            bytes: result.files.single.bytes!,
            fileName: result.files.single.name,
          );
      if (mounted) setState(() => resumeUrl = url);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> openResume() async {
    if (resumeUrl.isEmpty) return;
    final uri = Uri.tryParse(resumeUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isLoading) {
      return Scaffold(appBar: AppBar(title: const Text('Edit Profile')), body: const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.45)),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: pickAndUploadImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 52,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          backgroundImage: profileImageUrl.isNotEmpty ? NetworkImage(profileImageUrl) : null,
                          child: profileImageUrl.isEmpty ? Icon(Icons.person_rounded, size: 52, color: theme.colorScheme.onPrimaryContainer) : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle, border: Border.all(color: theme.colorScheme.surface, width: 2)),
                          child: Icon(Icons.camera_alt_rounded, size: 20, color: theme.colorScheme.onPrimary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Tap to change photo', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline_rounded)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: headlineController,
                    decoration: const InputDecoration(labelText: 'Headline', prefixIcon: Icon(Icons.badge_outlined)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: bioController,
                    decoration: const InputDecoration(labelText: 'Bio / About Me', prefixIcon: Icon(Icons.info_outline_rounded)),
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(labelText: 'Location', prefixIcon: Icon(Icons.location_on_outlined)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _SectionCard(
              theme: theme,
              title: 'Career Info',
              child: Column(
                children: [
                  TextField(
                    controller: desiredRoleController,
                    decoration: const InputDecoration(labelText: 'Desired Role', prefixIcon: Icon(Icons.work_outline_rounded)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: experienceLevelController,
                    decoration: const InputDecoration(labelText: 'Experience Level', prefixIcon: Icon(Icons.timeline_rounded)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: skillsController,
                    decoration: const InputDecoration(labelText: 'Skills (comma-separated)', prefixIcon: Icon(Icons.code_rounded)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: languagesKnownController,
                    decoration: const InputDecoration(labelText: 'Languages Known', prefixIcon: Icon(Icons.language_rounded)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _SectionCard(
              theme: theme,
              title: 'Resume & Portfolio',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: pickAndUploadResume,
                          icon: const Icon(Icons.upload_file_rounded),
                          label: Text(resumeUrl.isEmpty ? 'Upload Resume (PDF)' : 'Replace Resume'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (resumeUrl.isNotEmpty)
                        OutlinedButton.icon(
                          onPressed: openResume,
                          icon: const Icon(Icons.open_in_new_rounded),
                          label: const Text('View'),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: githubController,
                    decoration: const InputDecoration(labelText: 'GitHub URL', prefixIcon: Icon(Icons.code_rounded)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: linkedinController,
                    decoration: const InputDecoration(labelText: 'LinkedIn URL', prefixIcon: Icon(Icons.business_center_outlined)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: websiteController,
                    decoration: const InputDecoration(labelText: 'Personal Website', prefixIcon: Icon(Icons.public_rounded)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _SectionCard(
              theme: theme,
              title: 'Education',
              child: Column(
                children: [
                  TextField(
                    controller: educationDegreeController,
                    decoration: const InputDecoration(labelText: 'Degree', prefixIcon: Icon(Icons.school_outlined)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: educationCollegeController,
                    decoration: const InputDecoration(labelText: 'College Name', prefixIcon: Icon(Icons.account_balance_outlined)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: educationYearController,
                    decoration: const InputDecoration(labelText: 'Year of Passing', prefixIcon: Icon(Icons.calendar_today_outlined)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: educationScoreController,
                    decoration: const InputDecoration(labelText: 'CGPA / Percentage', prefixIcon: Icon(Icons.percent_rounded)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _SectionCard(
              theme: theme,
              title: 'Projects / Experience',
              child: Column(
                children: [
                  TextField(
                    controller: projectTitleController,
                    decoration: const InputDecoration(labelText: 'Project Title', prefixIcon: Icon(Icons.lightbulb_outline_rounded)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: projectDescriptionController,
                    decoration: const InputDecoration(labelText: 'Project Description', prefixIcon: Icon(Icons.notes_rounded)),
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: projectTechnologiesController,
                    decoration: const InputDecoration(labelText: 'Technologies Used', prefixIcon: Icon(Icons.integration_instructions_outlined)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: projectLinkController,
                    decoration: const InputDecoration(labelText: 'Project Link', prefixIcon: Icon(Icons.link_rounded)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _SectionCard(
              theme: theme,
              title: 'Achievements',
              child: Column(
                children: [
                  TextField(
                    controller: certificationsController,
                    decoration: const InputDecoration(labelText: 'Certifications', prefixIcon: Icon(Icons.verified_outlined)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: awardsController,
                    decoration: const InputDecoration(labelText: 'Awards', prefixIcon: Icon(Icons.emoji_events_outlined)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: hackathonsController,
                    decoration: const InputDecoration(labelText: 'Hackathons', prefixIcon: Icon(Icons.groups_outlined)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: saveProfile,
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md))),
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final ThemeData theme;
  final String title;
  final Widget child;

  const _SectionCard({required this.theme, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}
