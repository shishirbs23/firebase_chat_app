# Firebase Chat App

This Flutter project is a simple chat application featuring user authentication (login with email and password), user session management, room joining, real-time chat functionality, and push notifications. We utilized various packages including `go_router` for navigation, `flutter_riverpod` for state management, and `flutter_hooks` for reactive programming.

## Other Packages Used

- `firebase_auth`: For user authentication.
- `firebase_messaging`: For handling push notifications.
- `fluttertoast`: For displaying toast messages.
- `cloud_firestore`: For real-time database and chat functionality.
- `flutter_local_notifications`: For local notifications.
- `dio`: For making HTTP requests.

## Getting Started

This project serves as a great starting point for developing a Flutter chat application with Firebase integration.

To get started:

1. Clone this repository to your local machine.
2. Ensure you have Flutter installed. If not, follow the [Flutter installation guide](https://flutter.dev/docs/get-started/install). We used **Flutter version 3.19.6** in this project.
3. Set up your Firebase project and add the necessary configuration files (`google-services.json` for Android or `GoogleService-Info.plist` for iOS) to the `android/app` or `ios/Runner` directory respectively.
4. Install the required Flutter packages by running `flutter pub get`.
5. Launch the app on an emulator or physical device using `flutter run`.

For more information on Flutter development:

- Check out the [Flutter documentation](https://docs.flutter.dev/) for tutorials, samples, and a full API reference.
- Explore the [Flutter cookbook](https://docs.flutter.dev/cookbook) for useful code snippets and examples.
