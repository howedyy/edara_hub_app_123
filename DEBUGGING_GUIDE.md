# Debugging Guide - Black Screen & Deals Not Loading

## Issue 1: Black Screen on App Launch

### Possible Causes
1. Firebase initialization failing silently
2. Service locator setup issue
3. Widget rendering error
4. Route navigation problem

### Step-by-Step Debugging

#### Step 1: Clean Build
```bash
flutter clean
flutter pub get
flutter run
```

#### Step 2: Check Console Output
Look for these specific messages:
- "Firebase initialized successfully" ✅
- "Error initializing Firebase" ❌
- Any Flutter errors starting with "E/flutter"
- Any red error messages

#### Step 3: Add More Debug Logging
The app should print:
- Firebase initialization status
- Service locator setup completion
- Initial route determination
- Widget build calls

#### Step 4: Test on Real Device
If using emulator, try on a real Android device:
```bash
flutter run -d <device-id>
```

#### Step 5: Check for Missing Dependencies
Verify all packages are installed:
```bash
flutter pub get
flutter pub outdated
```

### Quick Fix Attempts

1. **Restart Flutter**
   ```bash
   flutter clean
   flutter pub get
   flutter run --verbose
   ```

2. **Check Android Build**
   ```bash
   cd android
   ./gradlew clean
   cd ..
   flutter run
   ```

3. **Invalidate Caches** (Android Studio)
   - File → Invalidate Caches / Restart
   - Choose "Invalidate and Restart"

## Issue 2: Deals Not Loading

### Verification Checklist

#### 1. Check Firestore Data
- Open Firebase Console
- Go to Firestore Database
- Navigate to `deals` collection
- Verify at least one deal has:
  - `is_published: true`
  - `created_at`: valid timestamp
  - `valid_until`: date in the future
  - `visibility`: "all_users" or "selected_users"
  - All required fields (title, description, category, etc.)

#### 2. Check Firestore Index
- Firebase Console → Firestore Database → Indexes
- Look for index on `deals` collection
- Status should be "Enabled" (not "Building")
- If still building, wait for it to complete

#### 3. Check Console Logs
Look for these debug messages:
```
DealsDataSource: Fetching deals for userId: <user-id>
DealsDataSource: Received X published deals from Firestore
DealsDataSource: Processing deal <deal-id>
DealsDataSource: Deal <deal-id> is visible to all users
DealsDataSource: Deal <deal-id> expired: false
DealsDataSource: Returning X deals after filtering
```

#### 4. Verify User is Logged In
- Check if userId is not empty
- Verify user is authenticated in Firebase Auth

### Common Issues & Solutions

#### Issue: "No deals available" despite deals in Firestore
**Solution**: Check deal document structure matches DealModel

Required fields in Firestore:
```javascript
{
  title: "string",
  description: "string",
  category: "string",
  original_price: number,
  discounted_price: number,
  discount_percentage: number,
  valid_until: Timestamp,
  is_published: true,
  visibility: "all_users" or "selected_users",
  allowed_users: [],
  wishlist: [],
  created_at: Timestamp,
  image_url: "string" (optional)
}
```

#### Issue: Deals loading but not visible
**Solution**: Check visibility settings
- If visibility is "selected_users", verify current user is in `allowed_users` array
- If visibility is "all_users", should work for everyone

#### Issue: Index not created
**Solution**: Create index manually
1. Go to Firebase Console → Firestore → Indexes
2. Click "Create Index"
3. Collection: `deals`
4. Fields:
   - `is_published` (Ascending)
   - `created_at` (Descending)
5. Click "Create"
6. Wait for status to change to "Enabled"

## Testing Procedure

### Test 1: Verify App Launches
1. Run app
2. Should see login screen (not black screen)
3. Login with approved user
4. Should navigate to main screen

### Test 2: Verify Deals Load
1. Navigate to Deals tab (bottom navigation)
2. Should see deals list (not "No deals available")
3. Check console for debug messages
4. Verify deals display correctly

### Test 3: Verify Deal Interactions
1. Click category filter
2. Deals should filter by category
3. Click wishlist heart icon
4. Should toggle wishlist status
5. Click "Claim Deal" button
6. Should show success message

## Emergency Fixes

### If Black Screen Persists

1. **Simplify main.dart**
   - Remove Firebase initialization temporarily
   - Hardcode initialRoute to signInRoute
   - Test if app launches

2. **Check for Null Safety Issues**
   - Verify all nullable fields are handled
   - Check for null pointer exceptions

3. **Test Individual Screens**
   - Navigate directly to SignInScreen
   - Test if screen renders

### If Deals Still Don't Load

1. **Simplify Query**
   - Remove all filters temporarily
   - Just fetch all deals
   - See if any data comes through

2. **Test with Sample Data**
   - Create a simple deal in Firestore
   - Verify it appears in console logs
   - Check if it reaches the UI

3. **Check Bloc State**
   - Add print statements in DealsBloc
   - Verify events are being triggered
   - Check if state changes are emitted

## Contact Points

If issues persist, provide:
1. Full console output (from app start to error)
2. Screenshot of Firestore deals collection
3. Screenshot of Firestore indexes
4. Screenshot of app screen (black screen or error)
5. Flutter doctor output: `flutter doctor -v`

## Next Steps

After fixing black screen:
1. Test login flow
2. Test navigation to main screen
3. Test deals loading
4. Test deal interactions
5. Configure Firebase Storage CORS for image uploads
