# Admin User Setup Guide

## 🎯 Quick Start - Create Your First Admin

You have **3 easy ways** to create an admin user:

---

## Method 1: Use the Built-in Setup Page (Recommended) ⭐

### Step 1: Open the App
1. Launch the MAT Kenya app
2. Go to the **Login Page**

### Step 2: Click "Create Admin User"
On the login page, you'll see:
- "Forgot password? Click here"
- "Don't have an account? Sign Up here"
- **"First time setup? Create Admin User"** ← Click this!

### Step 3: Create Default Admin
The setup page will create a default admin with:
- **Email**: `mynahnoreen@gmail.com`
- **Password**: `Kitiko.13936`
- **Name**: Administrator
- **Role**: admin

Click **"Create Admin User"** button and wait for success message.

### Step 4: Login
1. Go back to login page
2. Use the credentials shown above
3. You're now an admin!

### Step 5: Upload Mock Data
1. On Home Page, click **"Admin: Upload Data"** (orange button)
2. Click **"Upload Mock Data"**
3. Wait for confirmation
4. Done! You now have 5 routes and 5 fares

---

## Method 2: Manually via Firestore Console 🔧

### Step 1: Get Your User ID (UID)
1. Create a regular account in the app (Sign Up)
2. Go to [Firebase Console](https://console.firebase.google.com/)
3. Select project: **matkenya-a1926**
4. Go to **Authentication** → **Users**
5. Find your account and **copy the UID**

### Step 2: Add to Admin Collection
1. In Firebase Console, go to **Firestore Database**
2. Click **"Start collection"** (if Admin doesn't exist) OR Click **Admin** collection
3. Click **"Add document"**
4. **Document ID**: Paste your UID
5. **Add fields**:
   ```
   adminid: <your-uid>
   email: your-email@example.com
   name: Your Name
   role: admin
   ```
6. Click **Save**

### Step 3: Update Users Collection
1. Go to **Users** collection in Firestore
2. Find document with your UID
3. Click to edit
4. Add/Update field:
   ```
   role: admin
   ```
5. Click **Save**

### Step 4: Restart App & Login
You're now an admin!

---

## Method 3: Promote Current User (Code-Based) 💻

### Option A: Using Firestore Console (While Logged In)
1. Login to the app with your account
2. Open Firebase Console
3. Go to Firestore → **Users** collection
4. Find your user document (match your email)
5. Edit and add: `role: admin`
6. Go to **Admin** collection → Add document with your UID (see Method 2)
7. Restart the app

### Option B: Create Custom Setup Function
Add this code to run once in your app:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> makeCurrentUserAdmin() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print('No user logged in');
    return;
  }

  final uid = user.uid;
  final email = user.email ?? '';
  final name = user.displayName ?? 'Admin User';

  // Add to Users collection
  await FirebaseFirestore.instance.collection('Users').doc(uid).set({
    'role': 'admin',
    'email': email,
    'uid': uid,
    'display_name': name,
  }, SetOptions(merge: true));

  // Add to Admin collection
  await FirebaseFirestore.instance.collection('Admin').doc(uid).set({
    'adminid': uid,
    'email': email,
    'name': name,
    'role': 'admin',
  });

  print('✅ User $email is now an admin!');
}
```

Call this function once from a debug button or during development.

---

## ✅ Verify Admin Access

After creating admin user, verify it works:

### 1. Check Admin Utils
The app uses `AdminUtils.isCurrentUserAdmin()` which checks:
- ✅ User exists in `Admin` collection (by UID)
- ✅ OR User has `role: 'admin'` in `Users` collection

### 2. Check Home Page
Login with admin account:
- You should see **orange "Admin: Upload Data" button**
- If you don't see it, you're not recognized as admin

### 3. Check Admin Data Page
Click "Admin: Upload Data":
- Should open Admin Data Management page
- If you see "Access Denied", check your admin setup

---

## 🔒 Security Best Practices

### Change Default Password
If using Method 1 (built-in setup):
1. Login with default credentials
2. Go to Profile/Settings
3. Change password immediately
4. **Default password is public in the code!**

### Multiple Admins
To add more admins:
1. Login as existing admin
2. Use `AdminUtils.promoteUserToAdmin()` function
3. Or manually add to Firestore (Method 2)

### Firestore Security Rules
Ensure your Firestore rules allow:
```javascript
// Allow admins to read/write Routes and Fares
match /Routes/{document} {
  allow read: if true;  // Anyone can read routes
  allow write: if request.auth != null &&
    (exists(/databases/$(database)/documents/Admin/$(request.auth.uid)) ||
     get(/databases/$(database)/documents/Users/$(request.auth.uid)).data.role == 'admin');
}

match /Fares/{document} {
  allow read: if true;  // Anyone can read fares
  allow write: if request.auth != null &&
    (exists(/databases/$(database)/documents/Admin/$(request.auth.uid)) ||
     get(/databases/$(database)/documents/Users/$(request.auth.uid)).data.role == 'admin');
}
```

---

## 🐛 Troubleshooting

### "Create Admin User" Button Not Showing
**Solution**: Update app, the link was just added to login page

### Admin Creation Fails
**Check**:
1. Firebase Authentication enabled?
2. Email/Password sign-in enabled in Firebase Console?
3. Network connection active?
4. Check console logs for specific error

### Admin Button Not Showing After Login
**Causes**:
1. User not in Admin collection
2. User doesn't have `role: 'admin'` in Users collection
3. UID mismatch between Auth and Firestore

**Fix**:
1. Logout and re-login
2. Verify Admin collection has your UID
3. Verify Users collection has `role: 'admin'`
4. Check console logs for admin check results

### Can't Upload Data
**Check**:
1. Logged in as admin?
2. Firestore security rules allow admin writes?
3. Internet connection active?
4. Check console for specific errors

---

## 📊 Default Admin Credentials

**Created by Method 1**:
```
Email:    mynahnoreen@gmail.com
Password: Kitiko.13936
Name:     Administrator
Role:     admin
```

⚠️ **IMPORTANT**: Change password after first login!

---

## 🎉 After Admin Setup

Once you have admin access:

### 1. Upload Mock Data
- Home Page → **"Admin: Upload Data"**
- Click **"Upload Mock Data"**
- 5 routes + 5 fares will be added

### 2. Create More Admins (Optional)
Use `AdminUtils.promoteUserToAdmin()`:
```dart
await AdminUtils.promoteUserToAdmin(
  userId: '<target-user-uid>',
  userEmail: 'newadmin@example.com',
  userName: 'New Admin',
);
```

### 3. Manage Data
- View routes: **Find Route** page
- View fares: Click any route
- Upload more data: Modify `admin_data_page_widget.dart`

---

## 🚀 Next Steps

1. ✅ Create admin user (use Method 1 - easiest!)
2. ✅ Login with admin credentials
3. ✅ Upload mock data
4. ✅ Change default password
5. ✅ Test the app with real data
6. ✅ Create additional admin users if needed

**Need help?** Check:
- `SETUP_COMPLETE.md` - Full setup guide
- `GOOGLE_MAPS_ISSUES_AND_FIXES.md` - Google Maps configuration
- Firebase Console logs for detailed errors
