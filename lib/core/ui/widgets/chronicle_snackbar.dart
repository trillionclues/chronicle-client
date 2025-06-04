import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/ui/widgets/snackbar_content.dart';
import 'package:flutter/material.dart';

enum ChronicleSnackBarType { info, success, warning, error, game }

class ChronicleSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    ChronicleSnackBarType type = ChronicleSnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showCloseButton = true,
  }) {
    final theme = _getSnackBarTheme(type);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: ChronicleSnackBarContent(
          message: message,
          type: type,
          theme: theme,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        padding: EdgeInsets.zero,
        // action: actionLabel != null
        //     ? SnackBarAction(
        //         label: actionLabel,
        //         textColor: theme.actionColor,
        //         backgroundColor: Colors.transparent,
        //         onPressed: onActionPressed ?? () {},
        //       )
        //     : showCloseButton
        //         ? SnackBarAction(
        //             label: '✕',
        //             textColor: theme.textColor.withOpacity(0.7),
        //             backgroundColor: Colors.transparent,
        //             onPressed: () {
        //               ScaffoldMessenger.of(context).hideCurrentSnackBar();
        //             },
        //           )
        //         : null,
      ),
    );
  }

  // Quick success message
  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
        context: context,
        message: message,
        type: ChronicleSnackBarType.success,
        duration: duration);
  }

  // Quick error message
  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context: context,
      message: message,
      type: ChronicleSnackBarType.error,
      duration: duration,
    );
  }

  // Quick warning message
  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      type: ChronicleSnackBarType.warning,
      duration: duration,
    );
  }

  // Quick info message
  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      type: ChronicleSnackBarType.info,
      duration: duration,
    );
  }

  // Game-specific messages (like round changes, player actions)
  static void showGameMessage(
      {required BuildContext context,
      required String message,
      Duration duration = const Duration(seconds: 3),
      String? actionLabel,
      VoidCallback? onActionPressed}) {
    show(
      context: context,
      message: message,
      type: ChronicleSnackBarType.game,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  static SnackBarTheme _getSnackBarTheme(ChronicleSnackBarType type) {
    switch (type) {
      case ChronicleSnackBarType.success:
        return SnackBarTheme(
          backgroundColor: AppColors.secondary,
          textColor: AppColors.textColor,
          icon: Icons.check_circle_outline,
          actionColor: AppColors.textColor,
          borderColor: AppColors.secondary,
        );
      case ChronicleSnackBarType.error:
        return SnackBarTheme(
          backgroundColor: AppColors.errorColor,
          textColor: AppColors.surface,
          icon: Icons.error_outline,
          actionColor: AppColors.primary,
          borderColor: AppColors.errorColor,
        );
      case ChronicleSnackBarType.warning:
        return SnackBarTheme(
          backgroundColor: const Color(0xFFF59E0B),
          textColor: Colors.white,
          icon: Icons.warning_outlined,
          actionColor: Colors.white,
          borderColor: const Color(0xFFD97706),
        );
      case ChronicleSnackBarType.game:
        return SnackBarTheme(
          backgroundColor: AppColors.background,
          textColor: AppColors.textColor,
          icon: Icons.auto_stories_outlined,
          actionColor: AppColors.secondary,
          borderColor: AppColors.secondary,
        );
      case ChronicleSnackBarType.info:
        return SnackBarTheme(
          backgroundColor: const Color(0xFF6B7280),
          textColor: Colors.white,
          icon: Icons.info_outline,
          actionColor: Colors.white,
          borderColor: const Color(0xFF4B5563),
        );
    }
  }
}

class SnackBarTheme {
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final Color actionColor;
  final Color borderColor;

  const SnackBarTheme({
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.actionColor,
    required this.borderColor,
  });
}
