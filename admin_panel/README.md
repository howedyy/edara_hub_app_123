# Edara Hub - Admin Panel

A web-based admin panel for managing Edara Hub users and events.

## Features

### 👥 User Management
- **View pending registrations** - See all users waiting for approval
- **Approve/reject users** - Control who can access the mobile app
- **Manage approved users** - View and revoke approval if needed
- **User details** - See complete user information (name, email, employee ID, phone, etc.)

### 📅 Event Management
- **Create events** - Add new events with images, descriptions, and details
- **Edit events** - Modify existing event information
- **Publish/unpublish** - Control event visibility
- **User targeting** - Choose who can see specific events:
  - **All Users** - Visible to all approved users
  - **Selected Users** - Visible only to chosen users
- **Image uploads** - Add event images via Firebase Storage
- **Event scheduling** - Set date, time, and location

## Setup Instructions

### 1. Prerequisites
- Flutter SDK (3.9.0 or higher)
- Firebase project (same as mobile app)
- Web browser for testing

### 2. Install Dependencies
```bash
cd admin_panel
flutter pub get
```

### 3. Firebase Configuration

#### Option A: Use Existing Configuration
The admin panel uses the same Firebase project as your mobile app (`edaraapp-cb18b`).

#### Option B: Add Web App to Firebase (Recommended)
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **edaraapp-cb18b**
3. Click **Project Settings** (gear icon)
4. Scroll to **Your apps** section
5. Click **Add app** → **Web** (</> icon)
6. Enter app nickname: **"Edara Admin Panel"**
7. **Enable Firebase Hosting** (optional)
8. Copy the configuration
9. Update `lib/firebase_options.dart` with the web app ID

### 4. Create Admin User

You need to create an admin user to access the panel:

#### Method 1: Manual Setup (Quick)
1. Register a user in your mobile app
2. Go to Firebase Console → Firestore Database
3. Find your user document in the `users` collection
4. Add these fields:
   ```
   approved: true
   role: "admin"
   ```
   OR
   ```
   approved: true
   is_admin: true
   ```

#### Method 2: Direct Firestore Creation
1. Go to Firebase Console → Firestore Database
2. Create a new document in `users` collection
3. Use your Firebase Auth UID as document ID
4. Add these fields:
   ```json
   {
     "name": "Admin User",
     "email": "admin@example.com",
     "employee_id": "ADMIN001",
     "phone": "+1234567890",
     "approved": true,
     "role": "admin",
     "status": "active",
     "created_at": "2025-01-29T10:00:00Z",
     "updated_at": "2025-01-29T10:00:00Z"
   }
   ```

### 5. Update Firestore Security Rules

Add admin access rules to your Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function to check if user is admin
    function isAdmin() {
      return request.auth != null && 
             (get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin' ||
              get(/databases/$(database)/documents/users/$(request.auth.uid)).data.is_admin == true);
    }
    
    // Users collection
    match /users/{userId} {
      // Allow authenticated users to create their own document during registration
      allow create: if request.auth != null && request.auth.uid == userId;
      
      // Allow authenticated users to read their own document
      allow read: if request.auth != null && request.auth.uid == userId;
      
      // Allow unauthenticated read for login (query by employee_id)
      allow read: if request.auth == null;
      
      // Allow users to update their own document (but not the approved field)
      allow update: if request.auth != null && 
                      request.auth.uid == userId &&
                      !request.resource.data.diff(resource.data).affectedKeys().hasAny(['approved', 'role', 'is_admin']);
      
      // Allow admins to read and update any user
      allow read, update: if isAdmin();
      
      // Allow admins to delete users (for rejection)
      allow delete: if isAdmin();
    }
    
    // Events collection
    match /events/{eventId} {
      // Allow authenticated users to read published events
      allow read: if request.auth != null;
      
      // Allow admins to create, update, and delete events
      allow create, update, delete: if isAdmin();
    }
    
    // Registrations collection
    match /registrations/{registrationId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow delete: if request.auth != null && 
                      resource.data.user_id == request.auth.uid;
      
      // Allow admins to manage all registrations
      allow read, write: if isAdmin();
    }
  }
}
```

### 6. Run the Admin Panel

#### Development Mode
```bash
cd admin_panel
flutter run -d chrome
```

#### Build for Production
```bash
cd admin_panel
flutter build web
```

The built files will be in `admin_panel/build/web/`

### 7. Deploy (Optional)

#### Firebase Hosting
```bash
cd admin_panel
firebase init hosting
firebase deploy
```

#### Other Hosting Services
Upload the contents of `admin_panel/build/web/` to your web hosting service.

## Usage Guide

### 1. Login
1. Open the admin panel in your browser
2. Enter your admin email and password
3. Click **Login**

### 2. User Management
1. Click **Users** in the sidebar
2. Use filters to view:
   - **Pending** - Users waiting for approval
   - **Approved** - Users who can access the app
   - **All** - All users
3. For pending users:
   - Click **Approve** to grant access
   - Click **Reject** to delete the user
4. For approved users:
   - Click **Revoke Approval** to block access

### 3. Event Management
1. Click **Events** in the sidebar
2. Click **Create Event** to add a new event
3. Fill in event details:
   - **Title** and **Description**
   - **Location** and **Date/Time**
   - **Max Attendees** (optional)
   - **Upload Image** (optional)
4. Choose visibility:
   - **All Users** - Everyone can see it
   - **Selected Users** - Choose specific users
5. Toggle **Publish Event** to make it live
6. Click **Create Event**

### 4. Managing Existing Events
- **Edit** - Modify event details
- **Publish/Unpublish** - Control visibility
- **Delete** - Remove event permanently

## Troubleshooting

### Login Issues
- Ensure your user has `role: "admin"` or `is_admin: true` in Firestore
- Check that `approved: true` is set
- Verify email and password are correct

### Permission Errors
- Update Firestore security rules (see step 5)
- Ensure admin user exists in Firestore
- Check browser console for detailed errors

### Image Upload Issues
- Verify Firebase Storage is enabled
- Check Storage security rules
- Ensure file size is reasonable (< 5MB)

### Build Issues
```bash
flutter clean
flutter pub get
flutter build web
```

## Security Notes

⚠️ **Important Security Considerations:**

1. **Admin Access**: Only trusted users should have admin privileges
2. **Firestore Rules**: Always use proper security rules in production
3. **HTTPS**: Deploy admin panel over HTTPS only
4. **Regular Audits**: Review admin actions regularly
5. **Strong Passwords**: Enforce strong passwords for admin accounts

## Support

For issues or questions:
1. Check browser console for errors
2. Review Firebase Console logs
3. Verify Firestore security rules
4. Ensure all Firebase services are enabled

## Features Overview

### ✅ Completed Features
- User approval/rejection system
- Event creation and management
- User targeting for events
- Image upload for events
- Responsive web design
- Real-time data updates
- Secure admin authentication

### 🔄 Future Enhancements
- Analytics dashboard
- Bulk user operations
- Event attendance tracking
- Email notifications
- Advanced user filtering
- Event templates
- Audit logs