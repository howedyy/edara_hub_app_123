# Quick Setup Guide for Edara Hub Admin Panel

## Step-by-Step Setup (5 minutes)

### 1. Install Dependencies
```bash
cd admin_panel
flutter pub get
```

### 2. Create Your Admin User

#### Option A: Use Existing Mobile App User
1. Register in your mobile app with your admin email
2. Go to [Firebase Console](https://console.firebase.google.com/) → **edaraapp-cb18b**
3. Navigate to **Firestore Database**
4. Find your user in the `users` collection
5. Click on your user document
6. Add these fields:
   - `approved: true`
   - `role: "admin"`
7. Click **Update**

#### Option B: Create Admin User Directly in Firestore
1. Go to [Firebase Console](https://console.firebase.google.com/) → **edaraapp-cb18b**
2. Navigate to **Authentication** → **Users**
3. Click **Add user**
4. Enter your admin email and password
5. Copy the **User UID**
6. Go to **Firestore Database**
7. Click **Start collection** → Enter `users`
8. Click **Add document**
9. Use the **User UID** as Document ID
10. Add these fields:
    ```
    name: "Your Name"
    email: "your-admin@email.com"
    employee_id: "ADMIN001"
    phone: "+1234567890"
    approved: true
    role: "admin"
    status: "active"
    created_at: [Current timestamp]
    updated_at: [Current timestamp]
    ```

### 3. Update Firestore Security Rules

1. Go to **Firestore Database** → **Rules** tab
2. Replace existing rules with:

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
      
      // Allow users to update their own document (but not admin fields)
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
      // Allow authenticated users to read events
      allow read: if request.auth != null;
      
      // Allow admins to manage events
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

3. Click **Publish**

### 4. Run the Admin Panel

```bash
cd admin_panel
flutter run -d chrome
```

### 5. Login and Test

1. Open the admin panel (should open automatically)
2. Login with your admin email and password
3. You should see the dashboard with **Users** and **Events** tabs

## Quick Test Checklist

### ✅ User Management Test
1. Go to **Users** tab
2. You should see any pending user registrations
3. Try approving a user (if any exist)

### ✅ Event Management Test
1. Go to **Events** tab
2. Click **Create Event**
3. Fill in basic details:
   - Title: "Test Event"
   - Description: "This is a test"
   - Location: "Test Location"
   - Select a future date and time
4. Choose **All Users** visibility
5. Toggle **Publish Event** to ON
6. Click **Create Event**
7. You should see the event in the list

## Troubleshooting

### ❌ "Access denied. Admin privileges required."
- Check that your user has `role: "admin"` in Firestore
- Ensure `approved: true` is set
- Verify you're using the correct email/password

### ❌ "Permission denied" errors
- Make sure you updated the Firestore security rules
- Click **Publish** after updating rules
- Wait 30 seconds for rules to propagate

### ❌ Can't see users/events
- Check Firestore security rules are updated
- Verify your admin user exists in Firestore
- Check browser console for errors (F12)

### ❌ Image upload not working
- Ensure Firebase Storage is enabled in your project
- Check Storage security rules allow authenticated uploads

## Default Storage Rules (if needed)

If image uploads don't work, update Firebase Storage rules:

1. Go to **Firebase Console** → **Storage** → **Rules**
2. Use these rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Success! 🎉

If everything works:
- ✅ You can login to the admin panel
- ✅ You can see the Users and Events tabs
- ✅ You can create a test event
- ✅ No permission errors in browser console

Your admin panel is ready to use!

## Next Steps

1. **Create real events** for your organization
2. **Approve pending users** from mobile app registrations
3. **Test user targeting** by creating events for specific users
4. **Upload event images** to make events more engaging

## Production Deployment

When ready for production:

```bash
cd admin_panel
flutter build web
```

Upload the `build/web/` folder to your web hosting service.

## Need Help?

Check the full README.md for detailed documentation and advanced features.