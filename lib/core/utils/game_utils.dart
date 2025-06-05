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
}
