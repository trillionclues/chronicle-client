import 'dart:ui';

class AppColors {
  static const Color primary = Color(0xFFFF763C);
  static const Color secondary = Color(0xFF00FA9A);
  static const Color background = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF1E1E1E);
  static const Color surface = Color(0xFFFFFFFF);
static const Color diverColor = Color(0xFFBDBDBD);
  static const Color errorColor = Color(0xFFFF4B4B);
}

Color getAvatarColor(String name) {
  final colors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Violet
    Color(0xFFEC4899), // Pink
    Color(0xFF06B6D4), // Cyan
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
    Color(0xFF84CC16), // Lime
  ];
  return colors[name.hashCode % colors.length];
}