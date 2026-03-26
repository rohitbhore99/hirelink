import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hirelink1/core/di/providers.dart';
import 'package:hirelink1/core/theme/app_spacing.dart';
import 'package:hirelink1/widgets/empty_state.dart';
import 'package:hirelink1/widgets/custom_app_bar.dart';
import 'package:hirelink1/screen/user_public_profile_screen.dart';
import 'package:hirelink1/services/firestore_service.dart';
import 'package:url_launcher/url_launcher.dart';

class JobApplicantsScreen extends ConsumerStatefulWidget {
  final String jobId;
  final String jobTitle;

  const JobApplicantsScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  @override
  ConsumerState<JobApplicantsScreen> createState() =>
      _JobApplicantsScreenState();
}

class _JobApplicantsScreenState extends ConsumerState<JobApplicantsScreen> {
  @override
  Widget build(BuildContext context) {
    final firestoreService = ref.read(firestoreServiceProvider);

    return Scaffold(
      appBar: CustomAppBar(title: '${widget.jobTitle} - Applicants'),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getApplicationsForJob(widget.jobId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return EmptyState(
              title: 'Unable to load applicants',
              subtitle: 'Please try again.',
              icon: Icons.error_outline,
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const EmptyState(
              title: 'No applicants yet',
              subtitle: 'Applicants will appear here.',
              icon: Icons.person_off_outlined,
            );
          }

          final applications = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: applications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final app = applications[index];
              final data = app.data() as Map<String, dynamic>;
              final userId = data['userId'] as String? ?? '';
              final resumeUrl = data['resumeUrl'] as String? ?? '';
              final status = data['status'] as String? ?? 'applied';

              return FutureBuilder<DocumentSnapshot>(
                future: firestoreService.getUser(userId),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: const Text('Loading...'),
                      subtitle: Text(status.toUpperCase()),
                      trailing: const Icon(Icons.chevron_right),
                    );
                  }

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
                  final name = userData['name'] as String? ?? 'Unknown User';
                  final skills = userData['skills'] as String? ?? '';

                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                      ),
                    ),
                    title: Text(name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(status.toUpperCase()),
                        if (skills.isNotEmpty) Text('Skills: $skills'),
                        if (resumeUrl.isNotEmpty)
                          const Text('Resume: attached'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (status == 'applied' || status == 'under_review') ...[
                          IconButton(
                            icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                            tooltip: 'Approve',
                            onPressed: () async {
                              final applicationsRepo = ref.read(applicationsRepositoryProvider);
                              await applicationsRepo.updateApplicationStatus(app.id, 'accepted');
                              final notificationsRepo = ref.read(notificationsRepositoryProvider);
                              await notificationsRepo.sendNotification(
                                userId: userId,
                                title: 'Application Accepted',
                                body: 'Congratulations! You have been accepted for ${widget.jobTitle}',
                              );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application approved')));
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                            tooltip: 'Reject',
                            onPressed: () async {
                              final applicationsRepo = ref.read(applicationsRepositoryProvider);
                              await applicationsRepo.updateApplicationStatus(app.id, 'rejected');
                              final notificationsRepo = ref.read(notificationsRepositoryProvider);
                              await notificationsRepo.sendNotification(
                                userId: userId,
                                title: 'Application Update',
                                body: 'Your application for ${widget.jobTitle} was not successful',
                              );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application rejected')));
                              }
                            },
                          ),
                        ],
                        if (resumeUrl.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.picture_as_pdf),
                            tooltip: 'View Resume',
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
                          ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  UserPublicProfileScreen(userId: userId),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
