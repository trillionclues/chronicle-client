# Chronicle

Chronicle - Collaborative Content Creation Platform

## Overview

Chronicle is a versatile collaborative platform that enables groups to:
- Create stories together (original mode)
- Debate positions and vote on arguments
- Co-author articles section by section
- Make team decisions through structured proposals

## Key Features

- **Multiple Modes**: Switch between storytelling, debating, article writing, and decision-making
- **Flexible Voting**: Adaptable voting systems for each use case
- **Real-time Collaboration**: Instant updates across all devices
- **User Profiles**: Manage identity and view contributions
- **Cross-platform**: Works on iOS and Android

## Getting Started

### Prerequisites

- Flutter SDK: [Install Flutter](https://docs.flutter.dev/get-started/install)
- Firebase Project: [Set up a Firebase project](https://firebase.google.com/docs/flutter/setup)
- Dart: [Install Dart](https://dart.dev/get-dart)

### Installation

1. **Clone the repository**:
    ```sh
    git clone https://github.com/trillionclues/chronicle.git
    cd chronicle
    ```

2. **Install dependencies**:
    ```sh
    flutter pub get
    ```

3. **Set up Firebase**:
    - Add your `google-services.json` for Android in `android/app`.
    - Add your `GoogleService-Info.plist` for iOS in `ios/Runner`.

4. **Environment Variables**:
    - Create a `.env` file in the root directory and add your Firebase configuration:
    ```dotenv
    FIREBASE_API_KEY=your_api_key
    FIREBASE_APP_ID=your_app_id
    FIREBASE_MESSAGING_SENDER_ID=your_messaging_sender_id
    FIREBASE_PROJECT_ID=your_project_id
    FIREBASE_STORAGE_BUCKET=your_storage_bucket
    FIREBASE_IOS_BUNDLE_ID=your_ios_bundle_id
    ```

### Running the App

- **Android**:
    ```sh
    flutter run -d emulator-<device_id>
    ```

- **iOS**:
    ```sh
    flutter run -d ios
    ```

## Using Different Modes

### 1. Story Mode (Default)
- Create branching narratives with friends
- Vote on the best story directions
- Combine winning fragments into complete tales

### 2. Debate Mode
- Submit positions on any topic
- Vote for the most compelling arguments
- See ranked results of the discussion

### 3. Article Mode
- Collaboratively write long-form content
- Contribute sections or paragraphs
- Vote on the best versions of each part

### 4. Decision Mode
- Propose options for team decisions
- Structured voting process
- Clear audit trail of all suggestions

## UI Customization

The app automatically adapts its interface based on the current mode:
- Button labels change to match context
- Submission forms adjust requirements
- Voting interfaces optimize for each use case

## Roadmap
- Add custom voting systems
- Enable multimedia fragments
- Implement threaded discussions
- Export final content in multiple formats

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [Flutter](https://flutter.dev/)
- [Firebase](https://firebase.google.com/)

## Contact

For any inquiries, please contact us at [support@chronicle.com](mailto:exceln646@gmail.com).













