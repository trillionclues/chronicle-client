import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/ui/widgets/snackbar_content.dart';
import 'package:flutter/material.dart';

enum ChronicleSnackBarType { info, success, warning, error, game }

class ChronicleSnackBar {
  static OverlayEntry? _currentOverlay;

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

    _currentOverlay?.remove();
    _currentOverlay = OverlayEntry(
      builder: (context) => _TopSnackBarWidget(
        message: message,
        type: type,
        theme: theme,
        duration: duration,
        actionLabel: actionLabel,
        onActionPressed: onActionPressed,
        showCloseButton: showCloseButton,
        onDismiss: () {
          _currentOverlay?.remove();
          _currentOverlay = null;
        },
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);
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
          textColor: AppColors.surface,
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
          textColor: AppColors.surface,
          icon: Icons.warning_outlined,
          actionColor: Colors.white,
          borderColor: const Color(0xFFD97706),
        );
      case ChronicleSnackBarType.game:
        return SnackBarTheme(
          backgroundColor: AppColors.secondary,
          textColor: AppColors.surface,
          icon: Icons.auto_stories_outlined,
          actionColor: AppColors.textColor,
          borderColor: AppColors.secondary,
        );
      case ChronicleSnackBarType.info:
        return SnackBarTheme(
          backgroundColor: const Color(0xFF6B7280),
          textColor: AppColors.surface,
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

class _TopSnackBarWidget extends StatefulWidget {
  final String message;
  final ChronicleSnackBarType type;
  final SnackBarTheme theme;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final bool showCloseButton;
  final VoidCallback onDismiss;

  const _TopSnackBarWidget({
    required this.message,
    required this.type,
    required this.theme,
    required this.duration,
    this.actionLabel,
    this.onActionPressed,
    required this.showCloseButton,
    required this.onDismiss,
  });

  @override
  State<_TopSnackBarWidget> createState() => _TopSnackBarWidgetState();
}

class _TopSnackBarWidgetState extends State<_TopSnackBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1), // Start above screen
      end: Offset.zero, // End at normal position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    // Start animation
    _controller.forward();

    // Auto dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 15,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: widget.theme.backgroundColor,
            child: ChronicleSnackBarContent(
                message: widget.message,
                type: widget.type,
                theme: widget.theme,
                onDismiss: _dismiss),
          ),
        ),
      ),
    );
  }
}
