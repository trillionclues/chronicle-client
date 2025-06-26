import 'package:chronicle/features/auth/domain/model/user_model.dart';
import 'package:chronicle/features/game/domain/model/participant_model.dart';
import 'package:chronicle/features/game/domain/model/story_fragment_model.dart';
import 'package:chronicle/features/game/presentation/bloc/game_state.dart';

class GameUtils {
  static bool isCreator(UserModel user, List<ParticipantModel> participants) {
    final participant = participants.where((p) => p.id == user.id).firstOrNull;
    return participant?.isCreator ?? false;
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
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds remaining';
  }

  static List<StoryFragmentModel> extractWinningFragments(GameState state) {
    final winningFragments = <StoryFragmentModel>[];

    // group fragments by round
    final rounds = state.history.fold<Map<int, List<StoryFragmentModel>>>({},
        (map, fragment) {
      map.putIfAbsent(fragment.round, () => []).add(fragment);
      return map;
    });

    // For each round, find the winning fragment
    for (var round in rounds.keys.toList()..sort()) {
      final winner = rounds[round]
          ?.firstWhere((f) => f.isWinner, orElse: () => rounds[round]!.first);

      if (winner != null) {
        winningFragments.add(winner);
      }
    }

    return winningFragments;
  }
}
