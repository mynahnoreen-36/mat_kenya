# Troubleshooting Guide - MAT Kenya App

## 🗺️ Issue 1: Map Shows Black Screen

### Why This Happens
A black/gray map with no tiles means Google Maps can't load map data. Common causes:
1. **Maps SDK not enabled** in Google Cloud Console
2. **Invalid or restricted API key**
3. **Missing SHA-1 certificate fingerprint**
4. **Billing not enabled** on Google Cloud

---

### 🔧 Fix 1: Enable Google Maps SDK

#### Step 1: Go to Google Cloud Console
1. Open [Google Cloud Console](https://console.cloud.google.com/)
2. Select project: **matkenya-a1926**

#### Step 2: Enable Required APIs
1. Go to **APIs & Services** → **Library**
2. Search and **Enable** these APIs:
   - ✅ **Maps SDK for Android**
   - ✅ **Maps SDK for iOS** (if building for iOS)
   - ✅ Directions API (already used)
   - ✅ Places API (already used)
   - ✅ Geocoding API (already used)

#### Step 3: Check API Key Restrictions
1. Go to **APIs & Services** → **Credentials**
2. Find your Android API key: `AIzaSyA83l7vwVAGweMIzBDL6H728YHWwAMB-Zk`
3. Click to edit
4. Check **Application restrictions**:
   - Should be: **Android apps**
   - Package name: `com.mycompany.matkenya`
   - **SHA-1 certificate fingerprint**: ADD THIS (see below)

---

### 🔧 Fix 2: Get SHA-1 Certificate Fingerprint

The API key needs your app's SHA-1 fingerprint to work.

#### For Debug Builds (Development)
Run this command in your project root:

```bash
cd android
./gradlew signingReport
```

Or manually:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Copy the SHA-1** fingerprint (looks like: `9B:BB:31:86:B2:18:9E:F1:6D:8F:27:2B:DA:B5:93:62:C3:95:CB:B4`)

#### For Release Builds (Production)
If you have a release keystore:
```bash
keytool -list -v -keystore android/app/matkenya.keystore -alias matkenya
```

#### Add SHA-1 to API Key
1. Google Cloud Console → **Credentials**
2. Edit your Android API key
3. Under **Application restrictions**:
   - Add package name: `com.mycompany.matkenya`
   - Add the **SHA-1 fingerprint** you copied
4. Click **Save**
5. Wait 5 minutes for changes to propagate

---

### 🔧 Fix 3: Verify AndroidManifest.xml

Check that API key is in manifest:

```bash
cat android/app/src/main/AndroidManifest.xml | grep -A 2 "geo.API_KEY"
```

Should show:
```xml
<meta-data android:name="com.google.android.geo.API_KEY"
           android:value="AIzaSyA83l7vwVAGweMIzBDL6H728YHWwAMB-Zk"/>
```

If missing, the map won't work.

---

### 🔧 Fix 4: Check Google Cloud Billing

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click **Billing** in left menu
3. Ensure billing account is **linked** to your project
4. Maps SDK requires billing (but has $200/month free credit)

---

### 🔧 Fix 5: Clean and Rebuild

After making API changes:

```bash
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter run
```

---

## 👤 Issue 2: "Create Admin" Fails

### Why This Happens
Common causes:
1. **Email/Password authentication not enabled** in Firebase
2. **Firestore security rules** blocking writes
3. **Network issues**
4. **Firebase not initialized**

---

### 🔧 Fix 1: Enable Email/Password Authentication

#### Step 1: Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **matkenya-a1926**
3. Go to **Authentication** → **Sign-in method**
4. Find **Email/Password** provider
5. Click to edit
6. **Enable** both:
   - ✅ Email/Password
   - ✅ Email link (passwordless sign-in) - Optional
7. Click **Save**

---

### 🔧 Fix 2: Check Firestore Security Rules

#### Current Rules Issue
If your rules are too restrictive, admin creation will fail.

#### Update Firestore Rules
1. Firebase Console → **Firestore Database** → **Rules**
2. Update to allow admin creation:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper function to check if user is admin
    function isAdmin() {
      return request.auth != null && (
        exists(/databases/$(database)/documents/Admin/$(request.auth.uid)) ||
        get(/databases/$(database)/documents/Users/$(request.auth.uid)).data.role == 'admin'
      );
    }

    // Users collection
    match /Users/{userId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == userId;
      allow update: if request.auth != null &&
        (request.auth.uid == userId || isAdmin());
      allow delete: if false; // Don't allow deletes
    }

    // Admin collection
    match /Admin/{adminId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null; // Allow creation during setup
      allow update: if isAdmin();
      allow delete: if false; // Don't allow deletes
    }

    // Routes collection
    match /Routes/{routeId} {
      allow read: if true; // Anyone can read
      allow write: if isAdmin(); // Only admins can write
    }

    // Fares collection
    match /Fares/{fareId} {
      allow read: if true; // Anyone can read
      allow write: if isAdmin(); // Only admins can write
    }
  }
}
```

3. Click **Publish**

---

### 🔧 Fix 3: Check Console Logs

Run the app from terminal to see detailed errors:

```bash
flutter run
```

Then try creating admin again and watch the console output. Look for:
- ❌ `FirebaseAuthException`
- ❌ `FirebaseException`
- ❌ Network errors

**Common Error Messages**:

| Error | Cause | Fix |
|-------|-------|-----|
| `email-already-in-use` | Admin already exists | Use existing credentials or delete user first |
| `invalid-email` | Email format wrong | Check email in code |
| `operation-not-allowed` | Auth method disabled | Enable Email/Password in Firebase Console |
| `permission-denied` | Firestore rules block write | Update Firestore rules (see above) |
| `network-request-failed` | No internet | Check connection |

---

### 🔧 Fix 4: Manual Console Check

#### Check if Admin Already Exists
1. Firebase Console → **Authentication** → **Users**
2. Look for: `mynahnoreen@gmail.com`
3. If exists, note the **UID**

4. Firebase Console → **Firestore Database**
5. Check if `Admin` collection has document with that UID
6. Check if `Users` collection has `role: 'admin'` for that UID

**If admin exists**: Just login with the credentials!
```
Email:    mynahnoreen@gmail.com
Password: Kitiko.13936
```

---

### 🔧 Fix 5: Alternative - Create Admin via Firestore Console

If the automatic creation keeps failing:

#### Step 1: Create User in Authentication
1. Firebase Console → **Authentication** → **Users**
2. Click **Add User**
3. Email: `admin@matkenya.com` (or your email)
4. Password: Choose a secure password
5. Click **Add User**
6. **Copy the UID** shown

#### Step 2: Create Admin Document
1. Firestore Database → **Admin** collection
2. Click **Add Document**
3. Document ID: Paste the UID
4. Add fields:
   ```
   adminid: <paste-uid>
   email: admin@matkenya.com
   name: Administrator
   role: admin
   ```
5. Click **Save**

#### Step 3: Update Users Document
1. Firestore → **Users** collection
2. Add document with same UID
3. Add fields:
   ```
   uid: <paste-uid>
   email: admin@matkenya.com
   display_name: Administrator
   role: admin
   created_time: <click "timestamp">
   ```
4. Click **Save**

#### Step 4: Login
Use the email/password you created in Step 1.

---

## 🧪 Testing Your Fixes

### Test Map
```bash
# 1. Clean build
flutter clean
flutter pub get

# 2. Run app
flutter run

# 3. Navigate to Map page
# 4. Should see map tiles loading
# 5. Should be able to zoom/pan
```

**What you should see**:
- ✅ Map tiles (roads, labels, etc.)
- ✅ Zoom controls work
- ✅ Can tap to select origin/destination
- ✅ Blue dot shows your location (if permissions granted)

**If still black**:
- Wait 5-10 minutes after adding SHA-1
- Check API key restrictions match exactly
- Verify Maps SDK for Android is enabled
- Check billing is enabled

---

### Test Admin Creation
```bash
# 1. Run with console visible
flutter run

# 2. Go to Login Page
# 3. Click "Create Admin User"
# 4. Watch console output
```

**Success looks like**:
```
🚀 Creating default admin user...
📝 Creating new user in Firebase Auth...
✓ User created in Firebase Auth (UID: abc123...)
📝 Updating Users collection...
✓ Users collection updated
📝 Updating Admin collection...
✓ Admin collection updated
🎉 SUCCESS! Admin user is ready!
```

**Failure shows**:
```
❌ Error creating user: [specific error message]
```

Copy the error and see "Common Error Messages" table above.

---

## 🚀 Quick Fix Commands

### Get SHA-1 for Maps
```bash
cd /home/Root/Desktop/projects/mat_kenya/android
./gradlew signingReport | grep SHA1
```

### Check Firebase Config
```bash
cat android/app/google-services.json | grep project_id
cat android/app/src/main/AndroidManifest.xml | grep geo.API_KEY
```

### View Logs
```bash
flutter run --verbose 2>&1 | grep -i "error\|exception"
```

### Clean Everything
```bash
flutter clean
cd android
./gradlew clean
cd ..
rm -rf build/
flutter pub get
flutter run
```

---

## 📞 Still Having Issues?

### For Map Issues
1. ✅ Maps SDK enabled?
2. ✅ SHA-1 added to API key?
3. ✅ Waited 5-10 minutes after changes?
4. ✅ Billing enabled on Google Cloud?
5. ✅ API key restrictions correct?

**Check this file**: `GOOGLE_MAPS_ISSUES_AND_FIXES.md`

### For Admin Issues
1. ✅ Email/Password auth enabled?
2. ✅ Firestore rules allow writes?
3. ✅ Internet connection working?
4. ✅ Firebase initialized in app?
5. ✅ Checked console error messages?

**Alternative**: Create admin manually via Firestore Console (see Fix 5 above)

---

## 🎯 Expected Behavior

### Map Page Should Show
- Roads, highways, labels
- Your location (blue dot)
- Can zoom in/out
- Can tap to select locations
- Search works

### Admin Creation Should
- Complete in 2-3 seconds
- Show success message with credentials
- Allow immediate login
- Home page shows "Admin: Upload Data" button

---

## 📝 Collect This Info for Debugging

If you need more help, collect:

```bash
# 1. Flutter doctor
flutter doctor -v > flutter_info.txt

# 2. Firebase config
cat android/app/google-services.json | grep project_id

# 3. SHA-1 fingerprint
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1

# 4. API key from manifest
cat android/app/src/main/AndroidManifest.xml | grep geo.API_KEY

# 5. Console errors when creating admin
flutter run 2>&1 | tee console_output.txt
```

Then share the error messages from the console.
