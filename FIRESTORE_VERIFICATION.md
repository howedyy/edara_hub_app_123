# Firestore Verification Checklist

This guide helps you verify that your Firestore database is correctly configured for the Edara Hub app.

## 1. Firestore Database Setup

### Check Database Exists
- [ ] Go to Firebase Console → Firestore Database
- [ ] Database should be created (not showing "Create database" button)
- [ ] Database should be in "Production mode" or "Test mode"

### Check Collections
You should have these collections:
- [ ] `users` - User profiles and authentication data
- [ ] `events` - Events created by admin
- [ ] `deals` - Deals created by admin

## 2. Users Collection

### Sample User Document
```javascript
users/{userId}
{
  "name": "John Doe",
  "email": "john@example.com",
  "employee_id": "EMP001",
  "approved": true,  // Must be true for login
  "created_at": Timestamp
}
```

### Verification Steps
- [ ] At least one user document exists
- [ ] User has `approved: true`
- [ ] User has valid `employee_id`
- [ ] User has valid `email`

## 3. Deals Collection

### Sample Deal Document
```javascript
deals/{dealId}
{
  "title": "50% Off Electronics",
  "description": "Amazing discount on all electronics",
  "category": "Electronics",
  "original_price": 100,
  "discounted_price": 50,
  "discount_percentage": 50,
  "valid_until": Timestamp (future date),
  "is_published": true,  // Must be true to appear in app
  "visibility": "all_users",  // or "selected_users"
  "allowed_users": [],  // Array of user IDs if visibility is "selected_users"
  "wishlist": [],  // Array of user IDs who wishlisted this deal
  "created_at": Timestamp,
  "image_url": "https://..." // Optional
}
```

### Verification Steps
- [ ] At least one deal document exists
- [ ] Deal has `is_published: true`
- [ ] Deal has `visibility: "all_users"` (for testing)
- [ ] Deal has `valid_until` date in the FUTURE
- [ ] Deal has all required fields (title, description, category, prices, etc.)
- [ ] `created_at` is a valid Timestamp (not null)
- [ ] `discount_percentage` matches calculation: `((original_price - discounted_price) / original_price) * 100`

### Common Mistakes
❌ `is_published: false` - Deal won't appear in app
❌ `visibility: "selected_users"` with empty `allowed_users` - No one can see it
❌ `valid_until` in the past - Deal will be filtered out as expired
❌ Missing required fields - App will crash when parsing
❌ `created_at` as string instead of Timestamp - Sorting will fail

## 4. Events Collection

### Sample Event Document
```javascript
events/{eventId}
{
  "title": "Company Meeting",
  "description": "Monthly all-hands meeting",
  "category": "Meeting",
  "attachments": ["https://..."],  // Array of image/video URLs
  "is_published": true,
  "visibility": "all_users",
  "allowed_users": [],
  "wishlist": [],
  "comments": [],
  "created_at": Timestamp
}
```

### Verification Steps
- [ ] At least one event document exists
- [ ] Event has `is_published: true`
- [ ] Event has `visibility: "all_users"` (for testing)
- [ ] Event has all required fields

## 5. Firestore Security Rules

### Check Current Rules
- [ ] Go to Firebase Console → Firestore Database → Rules
- [ ] Rules should allow authenticated users to read/write
- [ ] Rules should allow unauthenticated read for users collection (for login)

### Recommended Rules
```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      // Allow read for authentication (login by employee_id)
      allow read: if true;
      // Allow create for registration
      allow create: if request.auth != null;
      // Allow update only for own document
      allow update: if request.auth != null && request.auth.uid == userId;
    }
    
    // Events collection
    match /events/{eventId} {
      // Anyone can read published events
      allow read: if true;
      // Only authenticated users (admins) can write
      allow create, update, delete: if request.auth != null;
    }
    
    // Deals collection
    match /deals/{dealId} {
      // Anyone can read published deals
      allow read: if true;
      // Only authenticated users (admins) can write
      allow create, update, delete: if request.auth != null;
    }
    
    // Deny all other collections
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### Verification Steps
- [ ] Rules are published (not in draft mode)
- [ ] Rules allow read access to deals collection
- [ ] Rules allow write access for authenticated users
- [ ] Rules allow unauthenticated read for users collection

## 6. Firestore Indexes

### Required Indexes

#### Deals Collection Index
- **Collection**: `deals`
- **Fields**:
  - `is_published` (Ascending)
  - `created_at` (Descending)
- **Query scope**: Collection
- **Status**: Enabled ✅

### Check Index Status
- [ ] Go to Firebase Console → Firestore Database → Indexes
- [ ] Look for index on `deals` collection
- [ ] Status should be "Enabled" (not "Building" or "Error")
- [ ] If status is "Building", wait for it to complete (can take a few minutes)

### Create Index Manually (if needed)
1. Go to Firebase Console → Firestore Database → Indexes
2. Click "Create Index"
3. Collection ID: `deals`
4. Add field: `is_published` → Ascending
5. Add field: `created_at` → Descending
6. Query scope: Collection
7. Click "Create"
8. Wait for status to change to "Enabled"

## 7. Test Queries

### Test Deal Query in Firebase Console
1. Go to Firestore Database → deals collection
2. Click "Filter" button
3. Add filter: `is_published` == `true`
4. Should return at least one deal
5. Check that returned deals have `valid_until` in the future

### Test User Query
1. Go to Firestore Database → users collection
2. Click "Filter" button
3. Add filter: `approved` == `true`
4. Should return at least one user
5. Note the `employee_id` for testing login

## 8. Data Validation

### Validate Deal Data
For each deal in Firestore, verify:

- [ ] `title` is a non-empty string
- [ ] `description` is a non-empty string
- [ ] `category` is one of: Electronics, Fashion, Food, Travel, or custom
- [ ] `original_price` is a number > 0
- [ ] `discounted_price` is a number > 0 and < original_price
- [ ] `discount_percentage` is a number between 0 and 100
- [ ] `valid_until` is a Timestamp in the future
- [ ] `is_published` is a boolean (true or false)
- [ ] `visibility` is either "all_users" or "selected_users"
- [ ] `allowed_users` is an array (can be empty)
- [ ] `wishlist` is an array (can be empty)
- [ ] `created_at` is a Timestamp

### Validate User Data
For each user in Firestore, verify:

- [ ] `name` is a non-empty string
- [ ] `email` is a valid email address
- [ ] `employee_id` is a non-empty string
- [ ] `approved` is a boolean
- [ ] `created_at` is a Timestamp

## 9. Common Issues & Solutions

### Issue: "No deals available" in app
**Check**:
- [ ] At least one deal has `is_published: true`
- [ ] Deal has `visibility: "all_users"`
- [ ] Deal has `valid_until` in the future
- [ ] Firestore index is "Enabled"

### Issue: "Permission denied" errors
**Check**:
- [ ] Firestore security rules are published
- [ ] Rules allow read access to deals collection
- [ ] User is authenticated (for write operations)

### Issue: Deals appear in Firestore but not in app
**Check**:
- [ ] Console shows "DealsDataSource: Received X published deals"
- [ ] Console shows "DealsDataSource: Returning X deals after filtering"
- [ ] Check if deals are being filtered out due to:
  - Expired (valid_until in past)
  - Visibility (selected_users but user not in allowed_users)
  - Missing required fields (app crashes when parsing)

### Issue: App crashes when loading deals
**Check**:
- [ ] All required fields are present in deal documents
- [ ] Field types are correct (numbers are numbers, not strings)
- [ ] Timestamps are Timestamp type, not strings
- [ ] Arrays are arrays, not null

## 10. Quick Test Procedure

1. **Create Test Deal**:
   - Go to Firestore Console → deals collection
   - Click "Add document"
   - Use auto-generated ID
   - Copy the sample deal structure from section 3
   - Set `valid_until` to 1 month from now
   - Set `is_published` to `true`
   - Set `visibility` to `"all_users"`
   - Click "Save"

2. **Verify in Console**:
   - Deal should appear in deals collection
   - Filter by `is_published == true` should show the deal

3. **Test in App**:
   - Run app: `flutter run`
   - Login with approved user
   - Navigate to Deals tab
   - Check console for debug messages
   - Deal should appear in app

4. **Check Console Output**:
   ```
   DealsDataSource: Received 1 published deals from Firestore
   DealsDataSource: Processing deal <deal-id>
   DealsDataSource: Deal <deal-id> is visible to all users
   DealsDataSource: Deal <deal-id> expired: false
   DealsDataSource: Returning 1 deals after filtering
   ```

## Summary Checklist

Before running the app, verify:

- [ ] Firestore database is created
- [ ] At least one user with `approved: true` exists
- [ ] At least one deal with `is_published: true` exists
- [ ] Deal has `valid_until` in the future
- [ ] Deal has `visibility: "all_users"`
- [ ] Firestore security rules are published
- [ ] Firestore index on deals collection is "Enabled"
- [ ] All required fields are present in deal documents
- [ ] Field types are correct (numbers, strings, timestamps, arrays)

If all items are checked ✅, the app should load deals successfully!

---

**Need Help?**
If deals still don't load after verifying everything:
1. Check console output for debug messages
2. Look for error messages starting with ❌
3. Verify user is logged in (userId not empty)
4. Check that deal document structure exactly matches the sample
5. Try creating a new deal with the exact sample structure
