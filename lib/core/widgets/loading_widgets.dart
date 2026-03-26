import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingWidgets {
  // Circular progress indicator with custom styling
  static Widget circularProgress({double size = 24.0, Color? color}) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? Colors.blue),
      ),
    );
  }

  // Full screen loading overlay
  static Widget fullScreenLoading({
    String? message,
    Color? backgroundColor,
    Color? indicatorColor,
  }) {
    return Container(
      color: backgroundColor ?? Colors.black.withOpacity(0.3),
      child: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                circularProgress(size: 32, color: indicatorColor),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Loading button
  static Widget loadingButton({
    required String text,
    bool isLoading = false,
    VoidCallback? onPressed,
    Color? backgroundColor,
    double? width,
    double? height,
  }) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: isLoading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  circularProgress(size: 20, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text('Loading...'),
                ],
              )
            : Text(text),
      ),
    );
  }

  // Shimmer loading for list items
  static Widget shimmerListItem({double height = 80, int itemCount = 5}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            height: height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          );
        },
      ),
    );
  }

  // Shimmer loading for cards
  static Widget shimmerCard({
    double height = 120,
    double width = double.infinity,
    BorderRadius? borderRadius,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Loading state for text
  static Widget shimmerText({
    double width = 100,
    double height = 16,
    int lines = 1,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          lines,
          (index) => Container(
            margin: EdgeInsets.only(bottom: index < lines - 1 ? 8 : 0),
            height: height,
            width: index == lines - 1 ? width * 0.7 : width,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Pull to refresh loading
  static Widget pullToRefreshLoading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// Extension for easy loading states in widgets
extension LoadingExtension on Widget {
  Widget withLoadingOverlay(bool isLoading, {String? message}) {
    if (!isLoading) return this;

    return Stack(
      children: [
        this,
        LoadingWidgets.fullScreenLoading(message: message),
      ],
    );
  }
}
