import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hirelink1/core/di/providers.dart';
import 'package:hirelink1/features/user/domain/models/user_model.dart';
import 'package:hirelink1/core/widgets/app_filter_chips.dart';
import 'package:hirelink1/core/widgets/skeleton_loader.dart';
import 'package:hirelink1/features/jobs/domain/models/job_model.dart';
import 'package:hirelink1/features/jobs/presentation/providers/jobs_providers.dart';
import 'package:hirelink1/widgets/empty_state.dart';
import 'package:hirelink1/widgets/job_card.dart';
import 'package:hirelink1/widgets/custom_app_bar.dart';
import 'package:hirelink1/screen/chat_list_screen.dart';
import 'package:hirelink1/screen/profile_screen.dart';
import 'package:hirelink1/screen/notification_screen.dart';
import 'package:hirelink1/theme/app_theme.dart';
import 'package:hirelink1/core/theme/app_spacing.dart';
import 'package:hirelink1/core/widgets/app_page_route.dart';
import 'package:hirelink1/features/notifications/domain/models/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _notificationsSeenAtKey = 'notifications_seen_at_ms';
  static const _messagesSeenAtKey = 'messages_seen_at_ms';
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _searchQuery = '';
  String _selectedType = 'All';
  String _sortBy = 'Newest';
  DateTime? _lastSeenNotificationsAt;
  DateTime? _lastSeenMessagesAt;
  static const _jobTypes = [
    'All',
    'Full-time',
    'Part-time',
    'Internship',
    'Contract',
  ];
  static const _sortOptions = [
    'Newest',
    'Salary (high)',
    'Salary (low)',
    'Location A-Z',
  ];

  @override
  void initState() {
    super.initState();
    _loadLastSeenNotificationsAt();
    _loadLastSeenMessagesAt();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(jobsStreamProvider);
    await Future<void>.delayed(const Duration(milliseconds: 450));
  }

  Future<void> _loadLastSeenNotificationsAt() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_notificationsSeenAtKey);
    if (!mounted) return;
    setState(() {
      _lastSeenNotificationsAt = ms == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(ms);
    });
  }

  Future<void> _loadLastSeenMessagesAt() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_messagesSeenAtKey);
    if (!mounted) return;
    setState(() {
      _lastSeenMessagesAt = ms == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(ms);
    });
  }

  Future<void> _markNotificationsAsSeenNow() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_notificationsSeenAtKey, now.millisecondsSinceEpoch);
    if (!mounted) return;
    setState(() => _lastSeenNotificationsAt = now);
  }

  Future<void> _markMessagesAsSeenNow() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_messagesSeenAtKey, now.millisecondsSinceEpoch);
    if (!mounted) return;
    setState(() => _lastSeenMessagesAt = now);
  }

  List<JobModel> _filterAndSortJobs(List<JobModel> jobs) {
    final query = _searchQuery.toLowerCase().trim();
    final filtered = jobs.where((job) {
      final matchesSearch =
          query.isEmpty ||
          job.title.toLowerCase().contains(query) ||
          job.company.toLowerCase().contains(query) ||
          job.description.toLowerCase().contains(query) ||
          job.location.toLowerCase().contains(query);
      final matchesType = _selectedType == 'All' || job.type == _selectedType;
      return matchesSearch && matchesType;
    }).toList();
    switch (_sortBy) {
      case 'Salary (high)':
        filtered.sort(
          (a, b) => _parseSalary(b.salary).compareTo(_parseSalary(a.salary)),
        );
        break;
      case 'Salary (low)':
        filtered.sort(
          (a, b) => _parseSalary(a.salary).compareTo(_parseSalary(b.salary)),
        );
        break;
      case 'Location A-Z':
        filtered.sort((a, b) => a.location.compareTo(b.location));
        break;
      default:
        filtered.sort(
          (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
            a.createdAt ?? DateTime(0),
          ),
        );
    }
    return filtered;
  }

  int _parseSalary(String s) {
    final nums = RegExp(
      r'\d+',
    ).allMatches(s).map((m) => int.tryParse(m.group(0) ?? '0') ?? 0).toList();
    return nums.isEmpty ? 0 : nums.reduce((a, b) => a > b ? a : b);
  }

  List<JobModel> _recommendedJobs(List<JobModel> jobs, UserModel? user) {
    final skills = (user?.skills ?? '')
        .split(',')
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.length > 1)
        .toList();
    if (skills.isEmpty) return [];
    return jobs.where((job) {
      final text = '${job.title} ${job.description} ${job.company}'
          .toLowerCase();
      return skills.any((skill) => text.contains(skill));
    }).toList();
  }

  int _unseenNotificationCount(List<NotificationModel> notifications) {
    final seenAt = _lastSeenNotificationsAt;
    if (seenAt == null) return notifications.length;
    return notifications
        .where((n) => (n.timestamp ?? DateTime(0)).isAfter(seenAt) && !n.title.toLowerCase().contains('message'))
        .length;
  }

  int _unseenMessageCount(List<NotificationModel> notifications) {
    final seenAt = _lastSeenMessagesAt;
    final messages = notifications.where((n) => n.title.toLowerCase().contains('message'));
    if (seenAt == null) return messages.length;
    return messages
        .where((n) => (n.timestamp ?? DateTime(0)).isAfter(seenAt))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final notificationStream = user == null
        ? Stream<List<NotificationModel>>.value(const <NotificationModel>[])
        : ref
              .watch(notificationsRepositoryProvider)
              .watchUserNotifications(user.uid);
    return StreamBuilder<List<NotificationModel>>(
      stream: notificationStream,
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? const <NotificationModel>[];
        final notifCount = _unseenNotificationCount(notifications);
        final msgCount = _unseenMessageCount(notifications);
        
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: CustomAppBar(
            title: 'HireLink',
            titleWidget: Image.asset(
              'assets/images/logo.png',
              height: 32,
              errorBuilder: (_, __, ___) => const Text('HireLink'),
            ),
            searchController: _searchController,
            onSearchChanged: (v) => setState(() => _searchQuery = v),
            onNotificationTap: () async {
              await Navigator.push(
                context,
                AppPageRoute(child: const NotificationScreen()),
              );
              await _markNotificationsAsSeenNow();
            },
            notificationCount: notifCount,
            actions: [
              IconButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    AppPageRoute(child: const ChatListScreen()),
                  );
                  await _markMessagesAsSeenNow();
                },
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.chat_bubble_outline_rounded),
                    if (msgCount > 0)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            msgCount > 9 ? '9+' : '$msgCount',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, ${user?.displayName?.split(' ').first ?? 'there'}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Discover premium opportunities curated for you.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: AppFilterChips(
                    selected: _selectedType,
                    options: _jobTypes,
                    onSelected: (v) => setState(() => _selectedType = v),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      4,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Sort by',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: HirelinkColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _sortBy,
                              isExpanded: true,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: HirelinkColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              items: _sortOptions
                                  .map(
                                    (o) => DropdownMenuItem(
                                      value: o,
                                      child: Text(o),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _sortBy = v ?? 'Newest'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ref
                    .watch(jobsStreamProvider)
                    .when(
                      data: (jobs) {
                        final profile = ref
                            .watch(
                              userProfileStreamProvider(
                                FirebaseAuth.instance.currentUser!.uid,
                              ),
                            )
                            .valueOrNull;
                        final recommended = _recommendedJobs(jobs, profile);
                        final filtered = _filterAndSortJobs(jobs);
                        if (filtered.isEmpty && recommended.isEmpty) {
                          return SliverFillRemaining(
                            child: EmptyState(
                              title: 'No matching jobs',
                              subtitle: 'Try adjusting your search or filters.',
                              icon: Icons.work_off_rounded,
                              ctaText: 'Reset Filters',
                              onCtaTap: () => setState(() {
                                _selectedType = 'All';
                                _searchQuery = '';
                                _searchController.clear();
                              }),
                            ),
                          );
                        }
                        return SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            0,
                            AppSpacing.md,
                            80,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              if (recommended.isNotEmpty) ...[
                                Text(
                                  'Featured jobs',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  clipBehavior: Clip.none,
                                  child: IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        for (int i = 0; i < recommended.take(6).length; i++) ...[
                                          SizedBox(
                                            width: 290,
                                            child: JobCard(job: recommended[i]),
                                          ),
                                          if (i < recommended.take(6).length - 1)
                                            const SizedBox(width: AppSpacing.md),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Text(
                                  'All jobs',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                              ],
                              ...filtered.map(
                                (job) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOut,
                                  margin: const EdgeInsets.only(
                                    bottom: AppSpacing.md,
                                  ),
                                  child: JobCard(job: job),
                                ),
                              ),
                            ]),
                          ),
                        );
                      },
                      loading: () =>
                          const SliverFillRemaining(child: SkeletonLoader()),
                      error: (_, __) => SliverFillRemaining(
                        child: EmptyState(
                          title: 'Something went wrong',
                          subtitle: 'Pull down to retry.',
                          icon: Icons.error_outline_rounded,
                          ctaText: 'Retry',
                          onCtaTap: () => ref.invalidate(jobsStreamProvider),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}
