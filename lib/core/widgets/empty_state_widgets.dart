import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptyStateWidgets {
  // Generic empty state with icon and message
  static Widget generic({
    required String title,
    required String message,
    IconData? icon,
    String? lottieAsset,
    VoidCallback? onActionPressed,
    String? actionText,
    Color? iconColor,
    double? iconSize,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (lottieAsset != null)
              Lottie.asset(
                lottieAsset,
                height: 120,
                width: 120,
                fit: BoxFit.contain,
              )
            else if (icon != null)
              Icon(
                icon,
                size: iconSize ?? 64,
                color: iconColor ?? Colors.grey[400],
              ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (onActionPressed != null && actionText != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.add),
                label: Text(actionText),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Empty state for no jobs found
  static Widget noJobs({
    VoidCallback? onSearchPressed,
    VoidCallback? onPostJobPressed,
  }) {
    return generic(
      title: "No Jobs Found",
      message:
          "There are no job postings available at the moment. Try adjusting your search criteria or check back later.",
      icon: Icons.work_off_rounded,
      iconColor: Colors.blue[300],
      actionText: onPostJobPressed != null ? "Post a Job" : null,
      onActionPressed: onPostJobPressed,
    );
  }

  // Empty state for no applications
  static Widget noApplications({bool isRecruiter = false}) {
    return generic(
      title: isRecruiter ? "No Applications Yet" : "No Applications",
      message: isRecruiter
          ? "You haven't received any applications for your job postings yet. Keep posting great jobs!"
          : "You haven't applied to any jobs yet. Start exploring opportunities!",
      icon: Icons.description_outlined,
      iconColor: Colors.green[300],
    );
  }

  // Empty state for no messages
  static Widget noMessages({VoidCallback? onStartChatPressed}) {
    return generic(
      title: "No Messages",
      message:
          "Your inbox is empty. Start a conversation with someone to get connected!",
      icon: Icons.chat_bubble_outline_rounded,
      iconColor: Colors.purple[300],
      actionText: "Start Chatting",
      onActionPressed: onStartChatPressed,
    );
  }

  // Empty state for no notifications
  static Widget noNotifications() {
    return generic(
      title: "No Notifications",
      message: "You're all caught up! New notifications will appear here.",
      icon: Icons.notifications_none_rounded,
      iconColor: Colors.orange[300],
    );
  }

  // Empty state for no search results
  static Widget noSearchResults({
    required String searchQuery,
    VoidCallback? onClearSearchPressed,
  }) {
    return generic(
      title: "No Results Found",
      message:
          "We couldn't find any results for \"$searchQuery\". Try different keywords or check your spelling.",
      icon: Icons.search_off_rounded,
      iconColor: Colors.grey[400],
      actionText: "Clear Search",
      onActionPressed: onClearSearchPressed,
    );
  }

  // Empty state for network error
  static Widget networkError({VoidCallback? onRetryPressed}) {
    return generic(
      title: "Connection Error",
      message:
          "Unable to connect to the internet. Please check your connection and try again.",
      icon: Icons.wifi_off_rounded,
      iconColor: Colors.red[300],
      actionText: "Retry",
      onActionPressed: onRetryPressed,
    );
  }

  // Empty state for coming soon features
  static Widget comingSoon({required String feature}) {
    return generic(
      title: "$feature Coming Soon",
      message:
          "We're working hard to bring you this feature. Stay tuned for updates!",
      icon: Icons.rocket_launch_rounded,
      iconColor: Colors.amber[400],
    );
  }
}

// Extension for easy empty states in lists
extension EmptyStateExtension on AsyncSnapshot {
  Widget? whenEmpty(Widget emptyWidget) {
    if (connectionState == ConnectionState.waiting) {
      return null; // Let the loading state handle this
    }

    if (hasError || (hasData && (data is List && (data as List).isEmpty))) {
      return emptyWidget;
    }

    return null;
  }
}
