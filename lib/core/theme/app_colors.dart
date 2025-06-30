import 'dart:ui';

class AppColors {
  static const Color primary = Color(0xFF7B4DFF);
  static const Color secondary = Color(0xFF00C9A7);
  static const Color background = Color(0xFFF9F9F9);
  static const Color textColor = Color(0xFF1A1A2E);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFD3D3E5);
  static const Color errorColor = Color(0xFFFF3860);
}

Color getAvatarColor(String name) {
  final colors = [
  AppColors.primary,
  AppColors.secondary,
  Color(0xFF6C5CE7), // Purple
  Color(0xFF00B894), // Teal
  Color(0xFFFD79A8), // Pink
  Color(0xFFFDCB6E), // Yellow
  Color(0xFFE17055), // Coral
  Color(0xFF0984E3),
  ];
  return colors[name.hashCode % colors.length];
}

