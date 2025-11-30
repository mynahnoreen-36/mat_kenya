# 🚨 QUICK FIX - Black Map & Admin Creation Failed

## Issue 1: Black Map 🗺️

### The Problem
Map shows black screen because Google Maps SDK can't authenticate your app.

### Quick Fix (5 minutes)

#### Step 1: Get Your SHA-1 Fingerprint
Run this command in your project directory:
```bash
cd android
./gradlew signingReport
```

Look for the line that says:
```
SHA1: 9B:BB:31:86:B2:18:9E:F1:6D:8F:27:2B:DA:B5:93:62:C3:95:CB:B4
```

**Copy this SHA-1 value** ☝️

#### Step 2: Add SHA-1 to Google Cloud
1. Open: https://console.cloud.google.com/apis/credentials
2. Select project: **matkenya-a1926**
3. Find API key: `AIzaSyA83l7vwVAGweMIzBDL6H728YHWwAMB-Zk`
4. Click to edit
5. Under **Application restrictions**:
   - Select: **Android apps**
   - Add package name: `com.mycompany.matkenya`
   - Add **SHA-1** fingerprint you copied
   - Click **Add**
6. Click **Save**

#### Step 3: Enable Maps SDK
1. Still in Google Cloud Console
2. Go to: https://console.cloud.google.com/apis/library
3. Search: **Maps SDK for Android**
4. Click **ENABLE** (if not already enabled)

#### Step 4: Enable Billing (Required!)
1. Go to: https://console.cloud.google.com/billing
2. Link a billing account (credit card required)
3. Don't worry: **$200/month FREE credit**
4. Your usage will likely stay free

#### Step 5: Wait & Rebuild
```bash
# Wait 5 minutes for changes to propagate
# Then clean and rebuild:

flutter clean
flutter pub get
flutter run
```

**Map should now work!** ✅

---

## Issue 2: Admin Creation Failed 👤

### The Problem
Creating admin fails because either:
1. Email/Password auth not enabled
2. Firestore rules blocking writes
3. Admin already exists

### Quick Fix - Method A: Enable Firebase Auth

#### Step 1: Enable Email/Password
1. Open: https://console.firebase.google.com/
2. Select: **matkenya-a1926**
3. Go to: **Authentication** → **Sign-in method**
4. Click **Email/Password**
5. Toggle **Enable**
6. Click **Save**

#### Step 2: Update Firestore Rules
1. Go to: **Firestore Database** → **Rules**
2. Replace with this:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Allow anyone to create Users and Admin during initial setup
    match /Users/{userId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
    }

    match /Admin/{adminId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
    }

    // Public read for routes and fares
    match /Routes/{routeId} {
      allow read: if true;
      allow write: if request.auth != null;
    }

    match /Fares/{fareId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

3. Click **Publish**

#### Step 3: Try Creating Admin Again
```bash
flutter run
# Go to Login Page
# Click "Create Admin User"
# Should work now!
```

---

### Quick Fix - Method B: Check if Admin Exists

Maybe admin already exists! Try logging in:
```
Email:    mynahnoreen@gmail.com
Password: Kitiko.13936
```

If login works, **you already have admin access!**

---

### Quick Fix - Method C: Manual Creation (Failsafe)

If automatic creation still fails, create manually:

#### Step 1: Create in Firebase Authentication
1. Firebase Console → **Authentication** → **Users**
2. Click **Add User**
3. Enter:
   - Email: `admin@matkenya.com` (or your email)
   - Password: (choose a secure one)
4. Click **Add User**
5. **Copy the UID** (long string like: `fh3k2jh4k2jh4k32jh4`)

#### Step 2: Create in Firestore - Admin Collection
1. Firestore Database → Create collection: **Admin**
2. Document ID: **Paste the UID you copied**
3. Add fields:
   - `adminid` (string): Paste UID again
   - `email` (string): admin@matkenya.com
   - `name` (string): Administrator
   - `role` (string): admin
4. Click **Save**

#### Step 3: Create in Firestore - Users Collection
1. Firestore Database → Create collection: **Users** (if not exists)
2. Document ID: **Same UID**
3. Add fields:
   - `uid` (string): Paste UID
   - `email` (string): admin@matkenya.com
   - `display_name` (string): Administrator
   - `role` (string): admin
4. Click **Save**

#### Step 4: Login
Use the email/password you created in Step 1.

**You're now an admin!** ✅

---

## ✅ Verification Checklist

### Map Working?
- [ ] SHA-1 added to API key restrictions
- [ ] Maps SDK for Android enabled
- [ ] Billing enabled on Google Cloud
- [ ] Waited 5 minutes after changes
- [ ] Rebuilt app with `flutter clean && flutter run`

### Admin Working?
- [ ] Email/Password auth enabled
- [ ] Firestore rules allow writes
- [ ] Tried existing credentials first
- [ ] OR created admin manually

---

## 🎯 After Fixes Work

Once both are fixed:

### 1. Test Map
```
Home Page → View Map
- Should see roads, labels, etc.
- Can zoom and pan
- Can tap to select locations
```

### 2. Test Admin
```
Login → Home Page → "Admin: Upload Data"
- Click "Upload Mock Data"
- Should upload 5 routes + 5 fares
- Check "Find Route" to verify
```

---

## 🆘 Still Not Working?

### For Map Issues
Run this and share output:
```bash
cd android
./gradlew signingReport | grep SHA1
cat app/src/main/AndroidManifest.xml | grep geo.API_KEY
```

### For Admin Issues
Run app and share console error:
```bash
flutter run
# Then try creating admin
# Copy the error message shown
```

**Common Errors**:
- `email-already-in-use` → Admin exists, just login!
- `operation-not-allowed` → Enable Email/Password auth
- `permission-denied` → Update Firestore rules

---

## 📞 Need More Help?

See detailed guides:
- **TROUBLESHOOTING.md** - Complete troubleshooting guide
- **GOOGLE_MAPS_ISSUES_AND_FIXES.md** - Maps configuration
- **ADMIN_SETUP_GUIDE.md** - Admin creation methods

Or run these diagnostic commands:
```bash
# Check Flutter
flutter doctor -v

# Check Firebase config
cat android/app/google-services.json | grep project_id

# Check API key
cat android/app/src/main/AndroidManifest.xml | grep -A 2 geo.API_KEY

# Get SHA-1
cd android && ./gradlew signingReport | grep SHA1
```
