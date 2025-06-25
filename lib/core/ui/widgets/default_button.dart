import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {
  final String? text;
  final Color? backgroundColor;
  final Color? textColor;
  final bool loading;
  final VoidCallback? onPressed;
  final EdgeInsets? padding;
  final bool fullWidth;

  const DefaultButton({
    super.key,
    this.backgroundColor,
    this.text,
    this.loading = false,
    this.onPressed,
    this.textColor,
    this.padding,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = ElevatedButton(
      onPressed: onPressed,
      style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
            backgroundColor: WidgetStateProperty.resolveWith((state) {
              if (state.contains(WidgetState.disabled)) {
                return backgroundColor?.withOpacity(0.5);
              } else {
                return backgroundColor;
              }
            }),
            foregroundColor: WidgetStateProperty.resolveWith((state) {
              if (state.contains(WidgetState.disabled)) {
                return textColor?.withOpacity(0.5);
              } else {
                return textColor;
              }
            }),
            padding: WidgetStatePropertyAll(padding),
          ),
      child: loading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              text ?? "",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textColor,
                  ),
            ),
    );

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}
