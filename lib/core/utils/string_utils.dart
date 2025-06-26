import 'package:chronicle/core/utils/app_mode.dart';
import 'package:flutter/material.dart';

class StringUtils {
  static String getCreateButtonText(AppMode mode) {
    switch (mode) {
      case AppMode.positionVoting:
        return 'Create New Debate';
      case AppMode.articleCreation:
        return 'Start New Article';
      case AppMode.decisionMaking:
        return 'Create Decision Session';
      default:
        return 'Create New Story';
    }
  }

  static String getStartButtonText(AppMode mode) {
    switch (mode) {
      case AppMode.positionVoting:
        return 'Start Debate';
      case AppMode.articleCreation:
        return 'Start Article';
      case AppMode.decisionMaking:
        return 'Start Session';
      default:
        return 'Start Story';
    }
  }

  static String getJoinButtonText(AppMode mode) {
    switch (mode) {
      case AppMode.positionVoting:
        return 'Enter Debate Code';
      case AppMode.articleCreation:
        return 'Join Article Session';
      case AppMode.decisionMaking:
        return 'Join Decision Session';
      default:
        return 'Enter Story Code';
    }
  }

  static String getSubmitButtonText(AppMode mode) {
    switch (mode) {
      case AppMode.positionVoting:
        return 'Submit Position';
      case AppMode.articleCreation:
        return 'Add Session';
      case AppMode.decisionMaking:
        return 'Propose Option';
      default:
        return 'Submit Fragment';
    }
  }

  static String getHomeTitle(AppMode mode) {
    switch (mode) {
      case AppMode.positionVoting:
        return 'Debate Hub';
      case AppMode.articleCreation:
        return 'Article Studio';
      case AppMode.decisionMaking:
        return 'Decision Center';
      default:
        return 'Story Studio';
    }
  }

  static String getEmptyStateMessage(AppMode mode) {
    switch (mode) {
      case AppMode.positionVoting:
        return 'No debates yet. Start a new debate or join an existing one!';
      case AppMode.articleCreation:
        return 'No articles yet. Create your first collaborative article!';
      case AppMode.decisionMaking:
        return 'No decisions pending. Start a new decision session!';
      default:
        return 'No stories yet. Begin your first collaborative story!';
    }
  }

  static IconData getModeIcon(AppMode mode) {
    switch (mode) {
      case AppMode.positionVoting:
        return Icons.gavel;
      case AppMode.articleCreation:
        return Icons.article;
      case AppMode.decisionMaking:
        return Icons.check_circle;
      default:
        return Icons.book;
    }
  }
}
