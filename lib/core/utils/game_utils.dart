import 'package:chronicle/features/auth/domain/model/user_model.dart';
import 'package:chronicle/features/game/domain/model/participant_model.dart';

class GameUtils {
  static bool isCreator(UserModel user, List<ParticipantModel> participants) {
    return user.id ==
        participants.firstWhere((participant) => participant.isCreator).id;
  }

  static String getInitials(String name) {
    List<String> nameParts = name.trim().split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
  }

  static String normalizeGameCode(String code) {
    return code.trim().replaceAll(RegExp(r'\s+'), '').toUpperCase();
  }

  static String? validateGameCode(String code) {
    final normalized = normalizeGameCode(code);
    if (normalized.isEmpty) return 'Game code cannot be empty';
    if (normalized.length < 4) return 'Game code too short (min 4 characters)';
    if (normalized.length > 10) return 'Game code too long (max 10 characters)';
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(normalized)) {
      return 'Only letters and numbers allowed';
    }
    return null;
  }

  static String formatGamePhaseTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
