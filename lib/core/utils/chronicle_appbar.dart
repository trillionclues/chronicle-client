import 'package:chronicle/core/utils/chronicle_spacing.dart';
import 'package:flutter/material.dart';

class ChronicleAppBar {
  static AppBar responsiveAppBar({
    required BuildContext context,
    String? title,
    Widget? titleWidget,
    bool showBackButton = false,
    bool centerTitle = false,
    List<Widget>? actions,
    bool useDefaultSpacing = true,
  }) {

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 375;

    return AppBar(
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.chevron_left,
                  size: isSmallScreen
                      ? ChronicleSizes.iconMedium
                      : ChronicleSizes.iconLarge),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      title: titleWidget ??
          (title != null
              ? Text(
                  title,
                  style: ChronicleTextStyles.bodyLarge(context).copyWith(
                    fontSize: isSmallScreen
                        ? ChronicleTextStyles.md
                        : ChronicleTextStyles.lg,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : null),
      centerTitle: centerTitle,
      actions: actions,
      titleSpacing: useDefaultSpacing ? 0 : null,
      toolbarHeight: ChronicleSizes.responsiveAppBarHeight(context),
    );
  }
}
