import 'package:flutter/material.dart';

/// Single entry point for every transient bottom message in the app.
///
/// Always passes `persist: false`. Flutter defaults `SnackBar.persist` to
/// `action != null`, so any snack bar carrying a [SnackBarAction] would stay on
/// screen forever instead of timing out after its [SnackBar.duration].
abstract final class AppSnackBar {
  static const Duration successDuration = Duration(seconds: 3);
  static const Duration errorDuration = Duration(seconds: 5);

  /// Confirmation of a completed action.
  static void showSuccess(BuildContext context, String message) => _show(
        context,
        message: message,
        duration: successDuration,
      );

  /// Neutral notice, such as a validation hint or a blocked operation.
  static void showInfo(BuildContext context, String message) => _show(
        context,
        message: message,
        duration: successDuration,
      );

  /// Failure notice, optionally with a single recovery action.
  static void showError(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    _show(
      context,
      message: message,
      duration: errorDuration,
      backgroundColor: colorScheme.error,
      foregroundColor: colorScheme.onError,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Duration duration,
    Color? backgroundColor,
    Color? foregroundColor,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: foregroundColor == null
                ? null
                : TextStyle(color: foregroundColor),
          ),
          duration: duration,
          persist: false,
          behavior: SnackBarBehavior.floating,
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          action: actionLabel == null || onAction == null
              ? null
              : SnackBarAction(
                  label: actionLabel,
                  textColor: foregroundColor,
                  onPressed: onAction,
                ),
        ),
      );
  }
}
