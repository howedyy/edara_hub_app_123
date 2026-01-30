# Firebase Setup Instructions

This document provides instructions for configuring Firebase in the Edara Hub application.

## Prerequisites

1. A Firebase project created in the [Firebase Console](https://console.firebase.google.com/)
2. Flutter SDK installed
3. FlutterFire CLI installed (optional but recommended)

## Setup Steps

### Option 1: Using FlutterFire CLI (Recommended)

1. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Configure Firebase for your project:
   ```bash
   flutterfire configure
   ```

3. Follow the prompts to:
   - Select your Firebase project
   - Choose the platforms you want to support (Android, iOS, Web)
   - The CLI will automatically generate the `firebase_options.dart` file with your credentials

### Option 2: Manual Configuration

If you prefer to configure manually, update the `lib/firebase_options.dart` file with your Firebase project credentials:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to Project Settings (gear icon)
4. Scroll down to "Your apps" section
5. For each platform (Android, iOS, Web), copy the configuration values

#### Android Configuration

1. In Firebase Console, select your Android app
2. Download `google-services.json`
3. Place it in `android/app/` directory
4. Update the `android` section in `firebase_options.dart` with values from the JSON file

#### iOS Configuration

1. In Firebase Console, select your iOS app
2. Download `GoogleService-Info.plist`
3. Place it in `ios/Runner/` directory
4. Update the `ios` section in `firebase_options.dart` with values from the plist file

#### Web Configuration

1. In Firebase Console, select your Web app
2. Copy the configuration object
3. Update the `web` section in `firebase_options.dart`

### Required Firebase Services

Enable the following services in your Firebase Console:

1. **Authentication**
   - Go to Authentication > Sign-in method
   - Enable "Email/Password" provider

2. **Firestore Database**
   - Go to Firestore Database
   - Create database in production mode (or test mode for development)
   - Set up security rules (see below)

3. **Storage**
   - Go to Storage
   - Get started with default settings
   - Set up security rules (see below)

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Events collection
    match /events/{eventId} {
      allow read: if request.auth != null;
      allow write: if false; // Only admins can write (handled via admin SDK)
    }
    
    // Registrations collection
    match /registrations/{registrationId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow delete: if request.auth != null && resource.data.user_id == request.auth.uid;
    }
    
    // Audit logs (admin only)
    match /audit_logs/{logId} {
      allow read, write: if false; // Only accessible via admin SDK
    }
  }
}
```

### Storage Security Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /events/{eventId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if false; // Only admins can write (handled via admin SDK)
    }
  }
}
```

## Install Dependencies

After configuration, run:

```bash
flutter pub get
```

## Verify Setup

Run the app to verify Firebase is initialized correctly:

```bash
flutter run
```

Check the console for any Firebase initialization errors.

## Troubleshooting

### Android Build Issues

If you encounter build issues on Android:

1. Ensure `google-services.json` is in `android/app/`
2. Check that `android/build.gradle` includes the Google services plugin
3. Verify minimum SDK version is at least 21 in `android/app/build.gradle`

### iOS Build Issues

If you encounter build issues on iOS:

1. Ensure `GoogleService-Info.plist` is in `ios/Runner/`
2. Run `pod install` in the `ios/` directory
3. Open `ios/Runner.xcworkspace` in Xcode and verify the plist is included

### Web Issues

If Firebase doesn't work on web:

1. Verify the web configuration in `firebase_options.dart`
2. Check browser console for CORS or configuration errors
3. Ensure Firebase Hosting is configured if deploying to production

## Next Steps

After Firebase is configured:

1. Test user registration and authentication
2. Verify Firestore read/write operations
3. Test file uploads to Firebase Storage
4. Set up the admin web panel with the same Firebase project

## Additional Resources

- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)
