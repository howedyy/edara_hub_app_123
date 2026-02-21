# Firebase Storage Image Upload Fix

## Issue
Images are not uploading in the admin panel for both Events and Deals.

## Root Causes
1. Firebase Storage Rules may be blocking uploads
2. CORS configuration may not be set up for web uploads
3. Firebase Storage may not be enabled in your project

## Solutions

### Step 1: Enable Firebase Storage

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `edaraapp-cb18b`
3. Click on **Storage** in the left sidebar
4. If not enabled, click **Get Started**
5. Choose **Start in test mode** (we'll secure it later)
6. Click **Done**

### Step 2: Update Firebase Storage Rules

1. In Firebase Console, go to **Storage** → **Rules** tab
2. Replace the rules with:

```
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    // Allow authenticated users to upload to events folder
    match /events/{allPaths=**} {
      allow read: if true;  // Anyone can read
      allow write: if request.auth != null;  // Only authenticated users can write
    }
    
    // Allow authenticated users to upload to deals folder
    match /deals/{allPaths=**} {
      allow read: if true;  // Anyone can read
      allow write: if request.auth != null;  // Only authenticated users can write
    }
    
    // Default: deny all other paths
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

3. Click **Publish**

### Step 3: Configure CORS for Web Uploads

Firebase Storage requires CORS configuration for web uploads. You need to set this up using Google Cloud Console.

#### Option A: Using Google Cloud Console (Recommended)

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project: `edaraapp-cb18b`
3. Open **Cloud Shell** (icon at top right)
4. Create a file called `cors.json`:

```bash
cat > cors.json << 'EOF'
[
  {
    "origin": ["*"],
    "method": ["GET", "POST", "PUT", "DELETE"],
    "maxAgeSeconds": 3600,
    "responseHeader": ["Content-Type", "Authorization"]
  }
]
EOF
```

5. Apply CORS configuration:

```bash
gsutil cors set cors.json gs://edaraapp-cb18b.appspot.com
```

6. Verify CORS is set:

```bash
gsutil cors get gs://edaraapp-cb18b.appspot.com
```

#### Option B: Using Local Terminal (if you have gcloud CLI)

1. Install [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) if not already installed
2. Authenticate:

```bash
gcloud auth login
```

3. Set your project:

```bash
gcloud config set project edaraapp-cb18b
```

4. Create `cors.json` file in your project root (already exists in admin_panel folder)
5. Apply CORS:

```bash
gsutil cors set admin_panel/cors.json gs://edaraapp-cb18b.appspot.com
```

### Step 4: Test Image Upload

1. Open your admin panel in the browser
2. Login as admin
3. Try to create a new Event or Deal
4. Click on the image upload area
5. Select an image file
6. You should see:
   - Upload progress indicator
   - Image preview after successful upload
   - No error messages in the console

### Step 5: Check Browser Console for Errors

If uploads still fail:

1. Open browser DevTools (F12)
2. Go to **Console** tab
3. Try uploading an image
4. Look for error messages:
   - **CORS error**: CORS configuration not applied correctly
   - **Permission denied**: Storage rules issue
   - **Network error**: Check internet connection
   - **Auth error**: Make sure you're logged in

### Step 6: Verify Storage Rules Allow Your User

Make sure your admin user is authenticated:

1. In Firebase Console, go to **Authentication**
2. Find your admin user in the Users tab
3. Note the UID
4. Try uploading again

### Troubleshooting

#### Error: "Firebase Storage: User does not have permission"

**Solution**: Update Storage Rules (Step 2 above)

#### Error: "CORS policy: No 'Access-Control-Allow-Origin' header"

**Solution**: Configure CORS (Step 3 above)

#### Error: "Upload task failed"

**Possible causes**:
1. File too large (default limit is 10MB for free tier)
2. Invalid file type
3. Network timeout

**Solution**: 
- Check file size (should be < 5MB for images)
- Use common formats: JPG, PNG, JPEG
- Check internet connection

#### Images upload but don't appear in the app

**Solution**: 
1. Check Firestore to see if the image URL was saved
2. Verify the URL is accessible (paste in browser)
3. Check if the mobile app has internet permission

### Security Best Practices (After Testing)

Once uploads are working, tighten security:

```
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    // Only allow admins to upload
    match /events/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && 
                      request.auth.token.email == 'admin@edara.com';  // Replace with your admin email
    }
    
    match /deals/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && 
                      request.auth.token.email == 'admin@edara.com';  // Replace with your admin email
    }
  }
}
```

### Quick Test Command

To quickly test if CORS is configured:

```bash
curl -H "Origin: http://localhost" \
  -H "Access-Control-Request-Method: POST" \
  -X OPTIONS \
  https://firebasestorage.googleapis.com/v0/b/edaraapp-cb18b.appspot.com/o
```

If CORS is configured correctly, you should see `Access-Control-Allow-Origin` in the response headers.

## Summary

The most common issue is missing CORS configuration. Follow Step 3 to configure CORS using Google Cloud Console, and your image uploads should work immediately.
