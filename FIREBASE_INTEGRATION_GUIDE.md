# Firebase Integration Guide - Edara Hub App

## Overview

This guide explains how the Edara Hub app has been integrated with Firebase Authentication and Firestore, implementing an admin approval workflow for user registration.

## Architecture

### Authentication Flow

```
User Registration → Firebase Auth → Firestore (approved: false) → Logout
                                                                      ↓
Admin Approves in Admin Panel → Firestore (approved: true)
                                                                      ↓
User Login → Firebase Auth → Check Firestore approval → Grant Access
```

### Key Components

1. **FirebaseAuthService** (`lib/core/services/firebase_auth_service.dart`)
   - Handles Firebase Authentication operations
   - Methods: signUp, login, logout, getCurrentUser

2. **FirestoreService** (`lib/core/services/firestore_service.dart`)
   - Manages Firestore database operations
   - User CRUD operations with approval status
   - Event queries with visibility filtering
   - Registration management

3. **FirebaseStorageService** (`lib/core/services/firebase_storage_service.dart`)
   - Handles media file uploads (images/videos)
   - File URL retrieval and management

4. **AuthFirebaseRepositoryImpl** (`lib/features/auth/data/repositories_impl/auth_firebase_repository_impl.dart`)
   - Implements the authentication repository using Firebase
   - Handles the approval workflow
   - Replaces the old API-based authentication

## Firebase Configuration

### Current Setup

Your Firebase project is configured with:
- **Project ID**: `edaraapp-cb18b`
- **Project Number**: `140881193724`
- **Storage Bucket**: `edaraapp-cb18b.firebasestorage.app`
- **API Key**: `AIzaSyC-U7bLeW3bQUasoRo0bkZzixNJgDc9kxs`

### Files Configured

1. **android/app/google-services.json** ✓ (Already configured)
2. **lib/firebase_options.dart** ✓ (Updated with your project credentials)

## User Registration Flow

### 1. User Signs Up

When a user registers:
1. Firebase Authentication creates a new user account
2. User data is stored in Firestore with `approved: false`
3. User is immediately logged out
4. UI shows "Registration successful! Pending admin approval" message

### 2. Admin Approval (Admin Panel - To be built)

The admin panel will:
1. Query Firestore for users with `approved: false`
2. Display pending registrations
3. Allow admin to approve/reject users
4. Update Firestore: `approved: true` or delete user

### 3. User Login

When a user tries to login:
1. Firebase Authentication validates credentials
2. System checks Firestore for `approved` status
3. If `approved: false` → Show "Account pending approval" message and logout
4. If `approved: true` → Generate token and grant access

## Firestore Data Structure

### Users Collection

```javascript
users/{userId}
{
  name: string,
  employee_id: string,
  email: string,
  phone: string,
  ip_device: string,
  status: string ("active" | "inactive"),
  approved: boolean (default: false),
  created_at: timestamp,
  updated_at: timestamp,
  approved_at: timestamp | null
}
```

### Events Collection

```javascript
events/{eventId}
{
  title: string,
  description: string,
  category: string,
  start_date: timestamp,
  end_date: timestamp,
  location: string,
  is_published: boolean,
  visibility: string ("all_users" | "selected_users"),
  allowed_users: array of userId strings,
  current_attendees: number,
  media: {
    images: array,
    videos: array
  },
  created_at: timestamp,
  updated_at: timestamp
}
```

### Registrations Collection

```javascript
registrations/{registrationId}
{
  user_id: string,
  event_id: string,
  registered_at: timestamp,
  status: string ("confirmed" | "attended" | "cancelled"),
  updated_at: timestamp
}
```

## Firebase Console Setup

### Enable Authentication

1. Go to Firebase Console: https://console.firebase.google.com/
2. Select your project: `edaraapp-cb18b`
3. Navigate to **Authentication** → **Sign-in method**
4. Enable **Email/Password** provider ✓ (Already done based on your screenshot)

### Enable Firestore

1. Navigate to **Firestore Database**
2. Click **Create database**
3. Choose **Start in production mode** (we'll set rules later)
4. Select a location (choose closest to your users)

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      // Allow users to read their own data
      allow read: if request.auth != null && request.auth.uid == userId;
      // Allow creation during registration
      allow create: if request.auth != null;
      // Only admins can update approval status (implement admin check)
      allow update: if request.auth != null && 
                      (request.auth.uid == userId || 
                       get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.isAdmin == true);
    }
    
    // Events collection
    match /events/{eventId} {
      // Allow approved users to read published events
      allow read: if request.auth != null && 
                    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.approved == true;
      // Only admins can write events
      allow write: if request.auth != null && 
                     get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.isAdmin == true;
    }
    
    // Registrations collection
    match /registrations/{registrationId} {
      // Users can read their own registrations
      allow read: if request.auth != null && 
                    resource.data.user_id == request.auth.uid;
      // Users can create/delete their own registrations
      allow create, delete: if request.auth != null && 
                              request.resource.data.user_id == request.auth.uid;
    }
  }
}
```

## Testing the Integration

### 1. Test Registration

```dart
// Run the app
flutter run

// In the app:
1. Navigate to Sign Up screen
2. Fill in all fields
3. Click "Sign Up"
4. You should see: "Registration successful! Your account is pending admin approval"
5. You'll be redirected to Sign In screen
```

### 2. Test Login (Before Approval)

```dart
// Try to login with the registered account
1. Enter email and password
2. Click "Login"
3. You should see: "Your account is pending approval. Please wait for admin confirmation."
```

### 3. Manually Approve User (Until Admin Panel is Built)

```javascript
// In Firebase Console → Firestore Database
1. Find the users collection
2. Find your user document
3. Edit the document
4. Change "approved" from false to true
5. Save
```

### 4. Test Login (After Approval)

```dart
// Try to login again
1. Enter email and password
2. Click "Login"
3. You should see: "User Logged In Successfully"
4. You'll be redirected to the main screen
```

## Next Steps

### 1. Build Admin Web Panel

Create a web application for admins to:
- View pending user registrations
- Approve/reject users
- Manage events
- View analytics

### 2. Implement OTP Verification (Optional)

After admin approval, you can add OTP verification:
1. When admin approves, send OTP to user's phone
2. User must verify OTP before first login
3. Use Firebase Phone Authentication

### 3. Real-time Notifications

Implement real-time listeners to notify users when:
- Their account is approved
- New events are published
- Event details change

### 4. Migrate Existing Users

If you have existing users in your old API:
1. Export user data from old system
2. Create Firebase Auth accounts
3. Import data to Firestore
4. Set `approved: true` for existing users

## Troubleshooting

### Firebase Not Initialized Error

If you see "No Firebase App '[DEFAULT]' has been created":
1. Ensure `Firebase.initializeApp()` is called in `main.dart`
2. Check that `firebase_options.dart` has correct credentials
3. Verify `google-services.json` is in `android/app/`

### Authentication Errors

- **"Email already in use"**: User already registered
- **"Weak password"**: Password must be at least 6 characters
- **"Invalid email"**: Check email format

### Firestore Permission Denied

1. Check Firestore security rules
2. Ensure user is authenticated
3. Verify user has `approved: true` status

## Code Changes Summary

### New Files Created

1. `lib/core/services/firebase_auth_service.dart` - Firebase Auth wrapper
2. `lib/core/services/firestore_service.dart` - Firestore operations
3. `lib/core/services/firebase_storage_service.dart` - Storage operations
4. `lib/features/auth/data/repositories_impl/auth_firebase_repository_impl.dart` - Firebase repository
5. `lib/core/di/firebase_module.dart` - Dependency injection module

### Modified Files

1. `lib/firebase_options.dart` - Updated with your Firebase credentials
2. `lib/features/auth/presentation/cubit/auth_cubit.dart` - Added approval states
3. `lib/features/auth/presentation/screens/sign_up_screen.dart` - Handle approval pending
4. `lib/features/auth/presentation/screens/sign_in_screen.dart` - Handle approval pending

### To Switch to Firebase Auth

Update `lib/core/di/service_locator.dart` to use `AuthFirebaseRepositoryImpl` instead of `AuthRepositoryImpl`.

## Support

For issues or questions:
1. Check Firebase Console logs
2. Review Firestore security rules
3. Check app logs for detailed error messages
4. Verify all Firebase services are enabled in console
