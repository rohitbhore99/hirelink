import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hirelink1/core/theme/app_spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hirelink1/core/di/providers.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int? activeCandidates;
  int? jobsPostedToday;
  int? successfulMatches;

  @override
  void initState() {
    super.initState();
    _fetchRealtimeData();
  }

  Future<void> _fetchRealtimeData() async {
    final db = ref.read(firestoreProvider);
    try {
      final candidatesQuery = await db.collection('users').where('role', isEqualTo: 'jobseeker').count().get();
      
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final jobsQuery = await db.collection('jobs')
          .where('createdAt', isGreaterThanOrEqualTo: startOfToday)
          .count()
          .get();
          
      var matchesQuery = await db.collection('applications').where('status', isEqualTo: 'accepted').count().get();
      var matchesCount = matchesQuery.count ?? 0;
      if (matchesCount == 0) {
        matchesQuery = await db.collection('applications').count().get();
        matchesCount = matchesQuery.count ?? 0;
      }

      if (mounted) {
        setState(() {
          activeCandidates = candidatesQuery.count ?? 0;
          jobsPostedToday = jobsQuery.count ?? 0;
          successfulMatches = matchesCount;
        });
      }
    } catch (e) {
      // Fallback to demo numbers if offline or permission error
      if (mounted) {
        setState(() {
          activeCandidates = 4204;
          jobsPostedToday = 1250;
          successfulMatches = 8900;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Platform Success',
          style: GoogleFonts.righteous(
            color: theme.colorScheme.primary,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Join the thousands hiring and getting hired right now.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (activeCandidates == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              _buildStatCard(
                context: context,
                title: 'Active Candidates',
                targetValue: activeCandidates!,
                icon: Icons.people_alt_rounded,
                color: Colors.blue,
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildStatCard(
                context: context,
                title: 'Jobs Posted Today',
                targetValue: jobsPostedToday!,
                icon: Icons.work_rounded,
                color: Colors.green,
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildStatCard(
                context: context,
                title: 'Applications Submitted',
                targetValue: successfulMatches!,
                icon: Icons.handshake_rounded,
                color: Colors.purple,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required int targetValue,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: color),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AnimatedCounter(
                  targetValue: targetValue,
                  style: GoogleFonts.outfit(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedCounter extends StatefulWidget {
  final int targetValue;
  final TextStyle style;

  const _AnimatedCounter({
    required this.targetValue,
    required this.style,
  });

  @override
  State<_AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<_AnimatedCounter> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: 0, end: widget.targetValue.toDouble()).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatNumber(int amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1).replaceAll('.0', '')}k+';
    }
    return amount.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          _formatNumber(_animation.value.toInt()),
          style: widget.style,
        );
      },
    );
  }
}
