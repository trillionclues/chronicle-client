enum AppMode {
  collaborativeWriting('Story', 'Create collaborative stories'),
  positionVoting('Debate', 'Vote on positions/arguments'),
  articleCreation('Article', 'Build articles together'),
  decisionMaking('Decision', 'Make team decisions');

  final String displayName;
  final String description;

  const AppMode(this.displayName, this.description);

  static AppMode? fromString(String? value) {
    if (value == null) return null;

    try {
      return AppMode.values.firstWhere(
        (e) => e.toString() == value || e.name == value,
      );
    } catch (_) {
      return null;
    }
  }
}
