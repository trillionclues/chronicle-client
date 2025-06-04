import 'package:chronicle/core/ui/widgets/chronicle_snackbar.dart';
import 'package:flutter/material.dart';

extension ChronicleSnackBarExtension on BuildContext {
  /// Show success snackbar
  void showSuccessSnackBar(String message) {
    ChronicleSnackBar.showSuccess(context: this, message: message);
  }

  /// Show error snackbar
  void showErrorSnackBar(String message) {
    ChronicleSnackBar.showError(context: this, message: message);
  }

  /// Show warning snackbar
  void showWarningSnackBar(String message) {
    ChronicleSnackBar.showWarning(context: this, message: message);
  }

  /// Show info snackbar
  void showInfoSnackBar(String message) {
    ChronicleSnackBar.showInfo(context: this, message: message);
  }

  /// Show game-specific snackbar
  void showGameSnackBar(String message,
      {String? actionLabel, VoidCallback? onActionPressed}) {
    ChronicleSnackBar.showGameMessage(
      context: this,
      message: message,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }
}

// USAGE EXAMPLES:

// Basic usage with static methods:
/*
ChronicleSnackBar.showSuccess(
  context: context,
  message: "Game created successfully!",
);

ChronicleSnackBar.showError(
  context: context,
  message: "Failed to join game. Please check your code.",
);

ChronicleSnackBar.showGameMessage(
  context: context,
  message: "Round 2 started! Time to write your fragment.",
  actionLabel: "Go",
  onActionPressed: () {
    // Navigate to writing screen
  },
);

*/

// Using extension methods (shorter syntax):
/*
context.showSuccessSnackBar("Fragment submitted successfully!");
context.showErrorSnackBar("Connection lost. Reconnecting...");
context.showWarningSnackBar("Only 30 seconds left to vote!");
context.showGameSnackBar("New player joined the game!");

// Advanced usage with custom duration and actions:
ChronicleSnackBar.show(
  context: context,
  message: "Game will start in 10 seconds",
  type: ChronicleSnackBarType.game,
  duration: Duration(seconds: 10),
  actionLabel: "Cancel",
  onActionPressed: () {
    // Cancel game start
  },
);
*/

// Game-specific examples for different scenarios:

/*
// When creating a game:
context.showSuccessSnackBar("Game 'ABC123' created successfully!");

// When joining a game:
context.showGameSnackBar("Welcome to the waiting room!");

// When a player joins:
context.showInfoSnackBar("Sarah joined the game");

// When game starts:
context.showGameSnackBar(
  "Game started! Round 1 begins now.",
  actionLabel: "Start Writing",
  onActionPressed: () => Navigator.pushNamed(context, '/writing'),
);

// During writing phase:
context.showWarningSnackBar("2 minutes remaining to submit your fragment!");

// During voting phase:
context.showInfoSnackBar("Voting phase started! Choose your favorite fragment.");

// When round ends:
context.showSuccessSnackBar("Round completed! Sarah's fragment won.");

// When game ends:
context.showGameSnackBar(
  "Story completed! Well done everyone!",
  actionLabel: "View Story",
  onActionPressed: () => Navigator.pushNamed(context, '/final-story'),
);

// Error scenarios:
context.showErrorSnackBar("Connection lost. Trying to reconnect...");
context.showErrorSnackBar("Invalid game code. Please try again.");
context.showErrorSnackBar("You were disconnected from the game.");

// Warning scenarios:
context.showWarningSnackBar("Game will be cancelled if no one joins in 2 minutes.");
context.showWarningSnackBar("You'll be kicked for inactivity in 30 seconds.");

*/
