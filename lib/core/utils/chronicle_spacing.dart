import 'package:flutter/material.dart';

/// Custom SizedBox utility for consistent spacing and sizing in Chronicle game
class ChronicleSpacing {
  ChronicleSpacing._();

  // spacing values based on 8px grid system
  static const double _baseUnit = 8.0;

  static const double xs = _baseUnit * 0.5; // 4px
  static const double sm = _baseUnit * 1; // 8px
  static const double md = _baseUnit * 2; // 16px
  static const double lg = _baseUnit * 3; // 24px
  static const double xl = _baseUnit * 4; // 32px
  static const double xxl = _baseUnit * 5; // 40px
  static const double xxxl = _baseUnit * 6; // 48px

  static const double cardPadding = md; // 16px
  static const double screenPadding = md; // 16px
  static const double buttonSpacing = sm; // 8px
  static const double sectionSpacing = lg; // 24px
  static const double componentSpacing = md; // 16px

  /// Extra small vertical space (4px)
  static const Widget verticalXS = SizedBox(height: xs);

  /// Small vertical space (8px)
  static const Widget verticalSM = SizedBox(height: sm);

  /// Medium vertical space (16px) - Most common
  static const Widget verticalMD = SizedBox(height: md);

  /// Large vertical space (24px)
  static const Widget verticalLG = SizedBox(height: lg);

  /// Extra large vertical space (32px)
  static const Widget verticalXL = SizedBox(height: xl);

  /// Extra extra large vertical space (40px)
  static const Widget verticalXXL = SizedBox(height: xxl);

  /// Extra extra extra large vertical space (48px)
  static const Widget verticalXXXL = SizedBox(height: xxxl);

  /// Extra small horizontal space (4px)
  static const Widget horizontalXS = SizedBox(width: xs);

  /// Small horizontal space (8px)
  static const Widget horizontalSM = SizedBox(width: sm);

  /// Medium horizontal space (16px) - Most common
  static const Widget horizontalMD = SizedBox(width: md);

  /// Large horizontal space (24px)
  static const Widget horizontalLG = SizedBox(width: lg);

  /// Extra large horizontal space (32px)
  static const Widget horizontalXL = SizedBox(width: xl);

  /// Extra extra large horizontal space (40px)
  static const Widget horizontalXXL = SizedBox(width: xxl);

  /// Extra extra extra large horizontal space (48px)
  static const Widget horizontalXXXL = SizedBox(width: xxxl);

  // CUSTOM SIZED BOXES
  /// Custom vertical space
  static Widget vertical(double height) => SizedBox(height: height);

  /// Custom horizontal space
  static Widget horizontal(double width) => SizedBox(width: width);

  /// Custom sized box with both width and height
  static Widget custom({double? width, double? height}) =>
      SizedBox(width: width, height: height);

  /// Square sized box
  static Widget square(double size) => SizedBox(width: size, height: size);

  // RESPONSIVE SPACING (based on screen size)
  /// Get responsive vertical spacing based on screen height
  static Widget responsiveVertical(
    BuildContext context, {
    double smallFactor = 0.02,
    double mediumFactor = 0.03,
    double largeFactor = 0.04,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    double spacing;

    if (screenHeight < 600) {
      spacing = screenHeight * smallFactor;
    } else if (screenHeight < 900) {
      spacing = screenHeight * mediumFactor;
    } else {
      spacing = screenHeight * largeFactor;
    }

    return SizedBox(height: spacing);
  }

  /// Get responsive horizontal spacing based on screen width
  static Widget responsiveHorizontal(
    BuildContext context, {
    double smallFactor = 0.04,
    double mediumFactor = 0.05,
    double largeFactor = 0.06,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    double spacing;

    if (screenWidth < 400) {
      spacing = screenWidth * smallFactor;
    } else if (screenWidth < 600) {
      spacing = screenWidth * mediumFactor;
    } else {
      spacing = screenWidth * largeFactor;
    }

    return SizedBox(width: spacing);
  }
}

/// Extension methods for easier access to spacing
extension SpacingExtension on num {
  Widget get verticalSpace => SizedBox(height: toDouble());

  Widget get horizontalSpace => SizedBox(width: toDouble());

  Widget get squareSpace => SizedBox(width: toDouble(), height: toDouble());
}

/// Utility class for common sizing patterns
class ChronicleSizes {
  ChronicleSizes._();

  // Common dimensions
  static const double buttonHeight = 48.0;
  static const double inputHeight = 56.0;
  static const double appBarHeight = 56.0;
  static const double cardElevation = 4.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;

  // Avatar sizes
  static const double avatarSmall = 32.0;
  static const double avatarMedium = 48.0;
  static const double avatarLarge = 64.0;
  static const double avatarXLarge = 80.0;

  // Icon sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // Game-specific sizes
  static const double gameCodeHeight = 80.0;
  static const double timerSize = 120.0;
  static const double participantCardHeight = 72.0;
  static const double fragmentCardMinHeight = 100.0;

  // SIZED BOXES FOR COMMON UI ELEMENTS
  /// Standard button height sized box
  static const Widget buttonHeightBox = SizedBox(height: buttonHeight);

  /// Standard input height sized box
  static const Widget inputHeightBox = SizedBox(height: inputHeight);

  /// Game code display height sized box
  static const Widget gameCodeHeightBox = SizedBox(height: gameCodeHeight);

  /// Timer circle size
  static const Widget timerSizeBox = SizedBox(
    width: timerSize,
    height: timerSize,
  );

  /// Participant card height
  static const Widget participantHeightBox =
      SizedBox(height: participantCardHeight);

  // AVATAR SIZED BOXES
  static const Widget avatarSmallBox = SizedBox(
    width: avatarSmall,
    height: avatarSmall,
  );

  static const Widget avatarMediumBox = SizedBox(
    width: avatarMedium,
    height: avatarMedium,
  );

  static const Widget avatarLargeBox = SizedBox(
    width: avatarLarge,
    height: avatarLarge,
  );

  static const Widget avatarXLargeBox = SizedBox(
    width: avatarXLarge,
    height: avatarXLarge,
  );

  // RESPONSIVE METHODS
  /// Get responsive button height based on screen size
  static double responsiveButtonHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight < 600) return 44.0;
    if (screenHeight < 900) return 48.0;
    return 52.0;
  }

  /// Get responsive avatar size
  static double responsiveAvatarSize(
    BuildContext context, {
    double baseSize = avatarMedium,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final factor = screenWidth < 400
        ? 0.8
        : screenWidth > 600
            ? 1.2
            : 1.0;
    return baseSize * factor;
  }

  /// Create responsive sized box
  static Widget responsive(
    BuildContext context, {
    required double width,
    required double height,
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final responsiveWidth =
        (width / 375) * screenSize.width; // Based on iPhone width
    final responsiveHeight =
        (height / 812) * screenSize.height; // Based on iPhone height

    return SizedBox(
      width: responsiveWidth.clamp(minWidth ?? 0, maxWidth ?? double.infinity),
      height:
          responsiveHeight.clamp(minHeight ?? 0, maxHeight ?? double.infinity),
    );
  }
}

/// Predefined spacing combinations for common layouts
class ChronicleLayouts {
  ChronicleLayouts._();

  /// Standard screen padding (all sides)
  static const EdgeInsets screenPadding =
      EdgeInsets.all(ChronicleSpacing.screenPadding);

  /// Horizontal screen padding only
  static const EdgeInsets horizontalScreenPadding = EdgeInsets.symmetric(
    horizontal: ChronicleSpacing.screenPadding,
  );

  /// Card padding
  static const EdgeInsets cardPadding =
      EdgeInsets.all(ChronicleSpacing.cardPadding);

  /// Button padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: ChronicleSpacing.lg,
    vertical: ChronicleSpacing.sm,
  );

  /// List item padding
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: ChronicleSpacing.md,
    vertical: ChronicleSpacing.sm,
  );

  /// Section spacing (between major UI sections)
  static const EdgeInsets sectionMargin = EdgeInsets.only(
    bottom: ChronicleSpacing.sectionSpacing,
  );

  /// Component spacing (between related UI elements)
  static const EdgeInsets componentMargin = EdgeInsets.only(
    bottom: ChronicleSpacing.componentSpacing,
  );
}

// USAGE EXAMPLES AND DOCUMENTATION:
/*

// BASIC SPACING USAGE:

Column(
  children: [
    Text('Welcome to Chronicle'),
    ChronicleSpacing.verticalMD, // 16px vertical space
    ElevatedButton(onPressed: () {}, child: Text('Start Game')),
    ChronicleSpacing.verticalLG, // 24px vertical space
    Text('Game Instructions'),
  ],
);

Row(
  children: [
    Icon(Icons.person),
    ChronicleSpacing.horizontalSM, // 8px horizontal space
    Text('Player Name'),
    ChronicleSpacing.horizontalMD, // 16px horizontal space
    Icon(Icons.more_vert),
  ],
);

// EXTENSION METHODS USAGE:

Column(
  children: [
    Text('Title'),
    16.verticalSpace, // Same as ChronicleSpacing.verticalMD
    Text('Subtitle'),
    8.verticalSpace,  // Same as ChronicleSpacing.verticalSM
    ElevatedButton(onPressed: () {}, child: Text('Button')),
  ],
);

// CUSTOM SPACING:

ChronicleSpacing.vertical(20), // Custom 20px vertical space
ChronicleSpacing.horizontal(12), // Custom 12px horizontal space
ChronicleSpacing.square(50), // 50x50 square space

// RESPONSIVE SPACING:

Column(
  children: [
    Text('Header'),
    ChronicleSpacing.responsiveVertical(context), // Adapts to screen size
    Text('Content'),
  ],
);

// GAME-SPECIFIC EXAMPLES:

// Waiting room player list
Column(
  children: [
    Text('Players'),
    ChronicleSpacing.verticalMD,
    ...players.map((player) => Column(
      children: [
        PlayerCard(player: player),
        ChronicleSpacing.verticalSM, // Space between player cards
      ],
    )),
  ],
);

// Writing phase screen
Padding(
  padding: ChronicleLayouts.screenPadding,
  child: Column(
    children: [
      TimerWidget(),
      ChronicleSpacing.verticalLG, // Prominent spacing after timer
      StoryDisplay(),
      ChronicleSpacing.verticalMD, // Standard spacing
      WriteFragmentInput(),
      ChronicleSpacing.verticalXL, // Extra spacing before submit
      SubmitButton(),
    ],
  ),
);

// Voting phase with fragments
Column(
  children: [
    VotingHeader(),
    ChronicleSpacing.verticalLG,
    ...fragments.map((fragment) => Column(
      children: [
        FragmentCard(fragment: fragment),
        ChronicleSpacing.verticalMD, // Consistent spacing between fragments
      ],
    )),
  ],
);

// Game results screen
Container(
  padding: ChronicleLayouts.cardPadding,
  child: Column(
    children: [
      WinnerAnnouncement(),
      ChronicleSpacing.verticalXL, // Emphasis spacing
      VoteResults(),
      ChronicleSpacing.verticalLG,
      NextRoundButton(),
    ],
  ),
);

// Using sizes for specific components:

// Avatar in participant list
Container(
  width: ChronicleSizes.avatarMedium,
  height: ChronicleSizes.avatarMedium,
  child: CircleAvatar(...),
);

// Game code display
Container(
  height: ChronicleSizes.gameCodeHeight,
  child: GameCodeWidget(),
);

// Responsive button
Container(
  height: ChronicleSizes.responsiveButtonHeight(context),
  child: ElevatedButton(...),
);

// LAYOUT COMBINATIONS:

// Screen with consistent padding
Scaffold(
  body: Padding(
    padding: ChronicleLayouts.screenPadding,
    child: Column(
      children: [
        HeaderSection(),
        ChronicleSpacing.verticalXL,
        ContentSection(),
        ChronicleSpacing.verticalLG,
        FooterSection(),
      ],
    ),
  ),
);

// Card with proper internal spacing
Card(
  child: Padding(
    padding: ChronicleLayouts.cardPadding,
    child: Column(
      children: [
        CardTitle(),
        ChronicleSpacing.verticalMD,
        CardContent(),
      ],
    ),
  ),
);

*/
