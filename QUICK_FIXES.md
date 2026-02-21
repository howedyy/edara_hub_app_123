# Quick Fixes for Black Screen & Deals Issues

## Immediate Actions

### 1. Clean and Rebuild
Run these commands in order:

```bash
flutter clean
flutter pub get
flutter run --verbose
```

### 2. Check Console Output
After running the app, look for these messages in the console:

**Expected Success Messages:**
```
=== APP STARTING ===
✅ Firebase initialized successfully
✅ Service locator setup complete
ℹ️ No user logged in, showing sign in screen
ℹ️ Initial route: /signIn
=== LAUNCHING APP ===
ℹ️ Building MainApp with initialRoute: /signIn
ℹ️ ScreenUtilInit builder called
ℹ️ Generating route for: /signIn
SignInScreen: initState called
SignInScreen: build called
```

**If You See Errors:**
- Look for lines starting with `❌`
- Copy the full error message
- Check the stack trace

### 3. Test Login Flow
1. Enter employee ID and password
2. Click Login
3. Watch console for:
   ```
   MainLayout: initState called
   MainLayout: build called with currentIndex: 0
   DealsScreen: initState called
   DealsScreen: Current user ID: <user-id>
   DealsScreen: Loading deals for user: <user-id>
   DealsBloc: LoadDeals event received for userId: <user-id>
   DealsDataSource: Fetching deals for userId: <user-id>
   ```

### 4. Verify Deals Loading
After login, navigate to Deals tab and check console:

**Expected Messages:**
```
DealsDataSource: Received X published deals from Firestore
DealsDataSource: Processing deal <deal-id>
DealsDataSource: Deal <deal-id> is visible to all users
DealsDataSource: Deal <deal-id> expired: false
DealsDataSource: Returning X deals after filtering
DealsBloc: Received X deals from use case
DealsBloc: UpdateDeals event received with X deals
```

## Common Issues & Solutions

### Issue 1: Black Screen with No Console Output

**Cause**: App crashes before Flutter initializes

**Solution**:
1. Check Android logcat for native crashes:
   ```bash
   adb logcat | grep -i flutter
   ```

2. Try running on a different device/emulator

3. Check if Google Play Services is installed on emulator

### Issue 2: "Error initializing Firebase"

**Cause**: Firebase configuration issue

**Solution**:
1. Verify `google-services.json` is in `android/app/`
2. Verify `GoogleService-Info.plist` is in `ios/Runner/`
3. Check `lib/firebase_options.dart` has correct project ID
4. Rebuild app after verifying files

### Issue 3: "Error setting up service locator"

**Cause**: Dependency injection issue

**Solution**:
1. Check if all dependencies are registered in `service_locator.dart`
2. Verify Firebase services are initialized before service locator
3. Run `flutter pub get` to ensure all packages are installed

### Issue 4: SignInScreen Not Showing

**Cause**: Routing issue

**Solution**:
1. Check console for "Generating route for: /signIn"
2. Verify `Routes.signInRoute` is defined as "/signIn"
3. Check `RouteGenerator.getRoute()` handles signInRoute case

### Issue 5: Deals Not Loading

**Cause**: Multiple possible causes

**Solution A - Check User Authentication**:
```
If console shows: "DealsScreen: ⚠️ User ID is empty!"
→ User is not logged in
→ Login again and check Firebase Auth console
```

**Solution B - Check Firestore Data**:
```
If console shows: "DealsDataSource: Received 0 published deals"
→ No published deals in Firestore
→ Create a deal in admin panel with is_published = true
```

**Solution C - Check Deal Visibility**:
```
If console shows deals received but "Returning 0 deals after filtering"
→ Deals are not visible to current user
→ Set visibility to "all_users" in admin panel
```

**Solution D - Check Deal Expiration**:
```
If console shows: "Deal <id> expired: true"
→ Deal has passed valid_until date
→ Update valid_until to future date in Firestore
```

## Firestore Deal Document Template

Create a test deal in Firestore with this structure:

```javascript
{
  "title": "Test Deal",
  "description": "This is a test deal",
  "category": "Electronics",
  "original_price": 100,
  "discounted_price": 50,
  "discount_percentage": 50,
  "valid_until": Timestamp (set to 1 month from now),
  "is_published": true,
  "visibility": "all_users",
  "allowed_users": [],
  "wishlist": [],
  "created_at": Timestamp (now),
  "image_url": ""
}
```

## Testing Checklist

- [ ] Run `flutter clean && flutter pub get`
- [ ] Run app with `flutter run --verbose`
- [ ] Check console for "=== APP STARTING ===" message
- [ ] Verify Firebase initialization success
- [ ] Verify service locator setup success
- [ ] Check if SignInScreen appears (not black screen)
- [ ] Login with approved user
- [ ] Check if MainLayout appears
- [ ] Navigate to Deals tab
- [ ] Check console for deals loading messages
- [ ] Verify deals appear in UI

## If All Else Fails

1. **Create a minimal test**:
   - Comment out DealsScreen in MainLayout
   - Replace with simple Text widget
   - See if app launches

2. **Test Firebase connection**:
   - Create a simple button that reads from Firestore
   - Verify Firebase is working

3. **Check Flutter version**:
   ```bash
   flutter doctor -v
   ```
   - Ensure Flutter is up to date
   - Check for any issues

4. **Reinstall app**:
   ```bash
   flutter clean
   cd android
   ./gradlew clean
   cd ..
   flutter run --uninstall-first
   ```

## Next Steps After Fixing

Once app launches and deals load:

1. Test all deal interactions (wishlist, claim, filter)
2. Configure Firebase Storage CORS for image uploads
3. Test admin panel image uploads
4. Verify events feature still works
5. Test complete user flow from registration to deals

## Getting Help

If issues persist, provide:
1. Full console output from app start
2. Output of `flutter doctor -v`
3. Screenshot of Firebase Console (Firestore deals collection)
4. Screenshot of app screen
5. Any error messages from Android Studio

---

**Remember**: The debug logging we added will help identify exactly where the issue is occurring. Pay close attention to the console output!
