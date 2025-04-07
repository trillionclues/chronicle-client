# Chronicle

Chronicle - Create stories together

## Overview

Chronicle is a collaborative storytelling application that allows users to create and share stories together. The app leverages Firebase for authentication and backend services, and it is built using Flutter for a seamless cross-platform experience.

## Features

- **User Authentication**: Secure user authentication using Firebase.
- **Google Sign-In**: Easy login with Google accounts.
- **Profile Management**: Users can manage their profiles and view other users' profiles.
- **Story Creation**: Create and edit stories collaboratively.
- **Real-time Updates**: Real-time updates and notifications for story changes.
- **Responsive UI**: A responsive and intuitive user interface.

## Getting Started

### Prerequisites

- Flutter SDK: [Install Flutter](https://docs.flutter.dev/get-started/install)
- Firebase Project: [Set up a Firebase project](https://firebase.google.com/docs/flutter/setup)
- Dart: [Install Dart](https://dart.dev/get-dart)

### Installation

1. **Clone the repository**:
    ```sh
    git clone https://github.com/your-username/chronicle.git
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
    flutter run
    ```

- **iOS**:
    ```sh
    flutter run
    ```

## Project Structure

- `lib/core`: Core functionalities and utilities.
- `lib/features/auth`: Authentication-related features.
- `lib/features/home`: Home page and related features.
- `lib/core/di`: Dependency injection setup.
- `lib/core/router`: App routing configuration.
- `lib/core/theme`: Theme and styling.

## Contributing

We welcome contributions! Please read our [Contributing Guidelines](CONTRIBUTING.md) for more details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [Flutter](https://flutter.dev/)
- [Firebase](https://firebase.google.com/)
- [Dio](https://pub.dev/packages/dio)

## Contact

For any inquiries, please contact us at [support@chronicle.com](mailto:exceln646@gmail.com).