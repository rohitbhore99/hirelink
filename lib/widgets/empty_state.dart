import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? ctaText;
  final VoidCallback? onCtaTap;

  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.ctaText,
    this.onCtaTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 22,
                  right: 24,
                  child: Icon(Icons.auto_awesome_rounded, color: theme.colorScheme.primary.withValues(alpha: 0.4), size: 22),
                ),
                Icon(
                  icon,
                  size: 62,
                  color: theme.colorScheme.primary.withValues(alpha: 0.9),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (ctaText != null && onCtaTap != null) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onCtaTap,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(ctaText!),
            ),
          ],
        ],
      ),
    );
  }
}
