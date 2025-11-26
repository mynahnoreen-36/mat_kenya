# Creating the Default Admin User

This guide explains how to create the default admin user for MAT Kenya.

## Admin Credentials
- **Email:** mynahnoreen@gmail.com
- **Password:** Kitiko.13936
- **Display Name:** Administrator

## Method 1: Using the Built-in Setup Page (EASIEST!)

The easiest way to create the admin is to use the built-in Setup Admin page:

1. **Run your Flutter app:**
   ```bash
   flutter run
   ```

2. **Navigate to the Setup Admin page:**
   - URL: `/setupAdmin`
   - You can navigate to it from your browser or add a temporary button to navigate there
   - Or use this code snippet to navigate:
     ```dart
     context.pushNamed('SetupAdminPage');
     ```

3. **Tap "Create Admin User"** - The page will automatically:
   - Create the Firebase Auth user
   - Set up the Users collection document with role: admin
   - Set up the Admin collection document
   - Show you the credentials

4. **Done!** You can now log in with the admin credentials.

### Quick Test Navigation

You can temporarily add this to any page (like SignupPage or WelcomePage) to navigate to the setup page:

```dart
TextButton(
  onPressed: () => context.pushNamed('SetupAdminPage'),
  child: Text('Setup Admin (DEV)'),
)
```

## Method 2: Using the Flutter App Programmatically

1. First, deploy the Firebase Cloud Functions:
   ```bash
   cd firebase/functions
   firebase deploy --only functions:createDefaultAdmin
   ```

2. Add the following code to your Flutter app (e.g., in a test or initialization screen):

   ```dart
   import 'package:cloud_functions/cloud_functions.dart';

   Future<void> createDefaultAdmin() async {
     try {
       final result = await FirebaseFunctions.instance
           .httpsCallable('createDefaultAdmin')
           .call({
         'email': 'mynahnoreen@gmail.com',
         'password': 'Kitiko.13936',
         'displayName': 'Administrator',
       });

       print('Success: ${result.data['message']}');
       print('User ID: ${result.data['userId']}');
     } catch (e) {
       print('Error creating admin: $e');
     }
   }
   ```

3. Call this function once during app setup or from a test screen.

## Method 2: Using Firebase Console

1. Deploy the Firebase Cloud Functions:
   ```bash
   cd firebase/functions
   firebase deploy --only functions:createDefaultAdmin
   ```

2. Go to Firebase Console > Functions
3. Find the `createDefaultAdmin` function
4. Click "Test function" and use this JSON payload:
   ```json
   {
     "email": "mynahnoreen@gmail.com",
     "password": "Kitiko.13936",
     "displayName": "Administrator"
   }
   ```

## Method 3: Using Node.js Script

1. Deploy the cloud function (if not already deployed):
   ```bash
   cd firebase/functions
   firebase deploy --only functions:createDefaultAdmin
   ```

2. Create a test script `test_admin_creation.js` in your project root:
   ```javascript
   const admin = require('firebase-admin');
   const serviceAccount = require('./path/to/serviceAccountKey.json');

   admin.initializeApp({
     credential: admin.credential.cert(serviceAccount)
   });

   const db = admin.firestore();
   const auth = admin.auth();

   async function createDefaultAdmin() {
     const email = 'mynahnoreen@gmail.com';
     const password = 'Kitiko.13936';
     const displayName = 'Administrator';

     try {
       // Check if user exists
       let userRecord;
       try {
         userRecord = await auth.getUserByEmail(email);
         console.log(`User already exists: ${userRecord.uid}`);
       } catch (error) {
         if (error.code === 'auth/user-not-found') {
           // Create new user
           userRecord = await auth.createUser({
             email: email,
             password: password,
             displayName: displayName,
             emailVerified: true,
           });
           console.log(`Created new user: ${userRecord.uid}`);
         } else {
           throw error;
         }
       }

       const uid = userRecord.uid;

       // Update Users collection
       await db.collection('Users').doc(uid).set({
         email: email,
         uid: uid,
         display_name: displayName,
         role: 'admin',
         created_time: admin.firestore.FieldValue.serverTimestamp(),
         updatedAt: admin.firestore.FieldValue.serverTimestamp(),
       }, { merge: true });

       // Add to Admin collection
       await db.collection('Admin').doc(uid).set({
         adminid: uid,
         email: email,
         name: displayName,
         role: 'admin',
       }, { merge: true });

       console.log('✓ Admin user created successfully!');
       console.log(`  Email: ${email}`);
       console.log(`  UID: ${uid}`);
       console.log(`  Role: admin`);
     } catch (error) {
       console.error('Error creating admin:', error);
     } finally {
       process.exit(0);
     }
   }

   createDefaultAdmin();
   ```

3. Run the script:
   ```bash
   node test_admin_creation.js
   ```

## Method 4: Direct Firebase Admin SDK (Quickest)

If you have the Firebase Admin SDK credentials, you can run this directly:

1. Install firebase-admin if not already installed:
   ```bash
   npm install firebase-admin
   ```

2. Run this quick script (save as `create_admin.js`):
   ```javascript
   const admin = require('firebase-admin');

   // Initialize with your service account
   admin.initializeApp();

   const email = 'mynahnoreen@gmail.com';
   const password = 'Kitiko.13936';

   admin.auth().createUser({
     email: email,
     password: password,
     displayName: 'Administrator',
     emailVerified: true,
   }).then(async (userRecord) => {
     const uid = userRecord.uid;
     const db = admin.firestore();

     await db.collection('Users').doc(uid).set({
       email: email,
       uid: uid,
       display_name: 'Administrator',
       role: 'admin',
       created_time: admin.firestore.FieldValue.serverTimestamp(),
       updatedAt: admin.firestore.FieldValue.serverTimestamp(),
     });

     await db.collection('Admin').doc(uid).set({
       adminid: uid,
       email: email,
       name: 'Administrator',
       role: 'admin',
     });

     console.log('Admin created:', uid);
     process.exit(0);
   }).catch(error => {
     console.error('Error:', error);
     process.exit(1);
   });
   ```

## Verification

After creating the admin, you can verify by:

1. **Firebase Console:**
   - Go to Authentication > Users
   - Check if mynahnoreen@gmail.com exists

2. **Firestore:**
   - Go to Firestore Database
   - Check `Users` collection for a document with `role: "admin"`
   - Check `Admin` collection for the admin document

3. **App Login:**
   - Try logging in with the credentials
   - Navigate to admin-protected routes to verify access

## Security Notes

- Change the default password after first login
- Consider implementing 2FA for admin accounts
- Keep the credentials secure and don't commit them to version control
- The cloud function should be secured in production to prevent unauthorized admin creation

## Troubleshooting

- **Error: User already exists:** The user was created successfully before. You can still log in with the credentials.
- **Error: Permission denied:** Check your Firestore security rules allow admin creation.
- **Error: Function not found:** Make sure you deployed the cloud function first.
