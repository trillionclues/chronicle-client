import 'package:chronicle/core/ui/widgets/chronicle_snackbar.dart';
import 'package:flutter/material.dart';

class ChronicleSnackBarContent extends StatelessWidget {
  final String message;
  final ChronicleSnackBarType type;
  final SnackBarTheme theme;
  final VoidCallback? onDismiss;

  const ChronicleSnackBarContent({
    super.key,
    required this.message,
    required this.type,
    required this.theme,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.borderColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                theme.icon,
                color: theme.textColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                onDismiss?.call();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.close,
                  color: theme.textColor,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
