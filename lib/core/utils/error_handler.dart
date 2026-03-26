import 'package:flutter/material.dart';

/// Utility class for handling errors and showing user-friendly messages
class ErrorHandler {
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static String getErrorMessage(dynamic error) {
    if (error is String) return error;

    // Firebase Auth errors
    if (error.toString().contains('weak-password')) {
      return 'Password is too weak. Please choose a stronger password.';
    }
    if (error.toString().contains('email-already-in-use')) {
      return 'An account with this email already exists.';
    }
    if (error.toString().contains('user-not-found')) {
      return 'No account found with this email.';
    }
    if (error.toString().contains('wrong-password')) {
      return 'Incorrect password.';
    }
    if (error.toString().contains('invalid-email')) {
      return 'Please enter a valid email address.';
    }

    // Firestore errors
    if (error.toString().contains('permission-denied')) {
      return 'You don\'t have permission to perform this action.';
    }
    if (error.toString().contains('not-found')) {
      return 'The requested data was not found.';
    }

    // Network errors
    if (error.toString().contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    }

    // Generic fallback
    return 'An unexpected error occurred. Please try again.';
  }

  static Future<T> handleFirebaseOperation<T>(
    Future<T> Function() operation,
    BuildContext context, {
    String? successMessage,
    String? customErrorMessage,
  }) async {
    try {
      final result = await operation();
      if (successMessage != null) {
        showSuccessSnackBar(context, successMessage);
      }
      return result;
    } catch (e) {
      final message = customErrorMessage ?? getErrorMessage(e);
      showErrorSnackBar(context, message);
      rethrow;
    }
  }
}