# Mat Kenya Firebase Backend Documentation

## Overview
This is the Firebase backend for the Mat Kenya app - a Kenyan matatu (public transport) routing and fare information system.

## Database Schema

### Collections

#### 1. Users
Stores user account information.

**Fields:**
- `email` (string): User email address
- `uid` (string): Firebase Auth user ID
- `created_time` (timestamp): Account creation date
- `role` (string): User role (`user` or `admin`)
- `display_name` (string): User's display name
- `updatedAt` (timestamp): Last profile update
- `phone_number` (string): User's phone number
- `photo_url` (string): Profile photo URL

**Security:**
- Users can only create/read/update their own documents
- Admins can read/delete any user document

#### 2. Routes
Stores matatu route information.

**Fields:**
- `origin` (string): Starting location
- `destination` (string): End location
- `routeid` (string): Unique route identifier
- `is_verified` (bool): Whether route has been verified by admin
- `stages` (string): Route stages/stops (comma-separated)

**Security:**
- Public read access (all users can view routes)
- Only admins can create/update/delete routes

#### 3. Admin
Stores admin user information.

**Fields:**
- `adminid` (string): Admin ID (matches Firebase Auth UID)
- `email` (string): Admin email
- `name` (string): Admin name
- `role` (string): Admin role level

**Security:**
- Only admins can read admin collection
- Cannot be created via app (must be added manually or via backend)
- Cannot be deleted via app (protection against accidental deletion)

#### 4. Fares
Stores fare information for routes.

**Fields:**
- `route_id` (string): Associated route ID
- `standard_fare` (int): Base fare amount (KES)
- `peak_multiplier` (int): Multiplier for peak hours
- `peak_hours_starts` (string): Peak hours start time
- `peak_hours_end` (string): Peak hours end time

**Security:**
- Public read access (all users can view fares)
- Only admins can create/update/delete fares

## Security Rules

### Admin Verification
Two methods for admin verification:
1. Check if user exists in `/Admin/{uid}` collection
2. Check if user's role in `/Users/{uid}` is "admin"

### Access Control Summary

| Collection | Create | Read | Update | Delete |
|-----------|---------|------|--------|--------|
| Users | Self only | Self + Admins | Self only | Self + Admins |
| Routes | Admins only | Public | Admins only | Admins only |
| Admin | ❌ Never | Admins only | Admins only | ❌ Never |
| Fares | Admins only | Public | Admins only | Admins only |

## Cloud Functions

### 1. addFcmToken
**Type:** HTTPS Callable
**Purpose:** Register FCM push notification token for a user
**Auth:** Required
**Parameters:**
- `userDocPath`: Path to user document
- `fcmToken`: FCM device token
- `deviceType`: Device type (iOS/Android)

### 2. sendPushNotificationsTrigger
**Type:** Firestore Trigger
**Purpose:** Automatically send push notifications when created
**Triggers on:** `/ff_push_notifications/{id}` onCreate

### 3. onUserDeleted
**Type:** Auth Trigger
**Purpose:** Clean up Firestore data when user is deleted
**Triggers on:** User account deletion

## Indexes

Optimized composite indexes for common queries:

1. **Routes by Origin & Destination**
   - Fields: `origin`, `destination`
   - Use: Finding routes between two locations

2. **Verified Routes by Origin**
   - Fields: `is_verified`, `origin`
   - Use: Finding verified routes from a location

3. **Fares by Route**
   - Field: `route_id`
   - Use: Looking up fares for specific routes

4. **Users by Role & Creation Date**
   - Fields: `role`, `created_time`
   - Use: Admin dashboard user management

## Setup Instructions

### Initial Admin Setup

**IMPORTANT:** The first admin must be created manually to bootstrap the system.

#### Method 1: Firebase Console
1. Go to Firebase Console → Firestore Database
2. Create a document in the `Admin` collection:
   ```
   Document ID: [Your Firebase Auth UID]
   Fields:
     - adminid: [Your Firebase Auth UID]
     - email: [Your email]
     - name: [Your name]
     - role: "admin"
   ```
3. Update your user document in `Users` collection:
   ```
   Document ID: [Your Firebase Auth UID]
   Fields:
     - role: "admin"
   ```

#### Method 2: Firebase Admin SDK (Backend Script)
```javascript
const admin = require('firebase-admin');
admin.initializeApp();

async function createAdmin(uid, email, name) {
  const db = admin.firestore();

  // Add to Admin collection
  await db.collection('Admin').doc(uid).set({
    adminid: uid,
    email: email,
    name: name,
    role: 'admin'
  });

  // Update Users collection
  await db.collection('Users').doc(uid).update({
    role: 'admin'
  });

  console.log('Admin created successfully!');
}

// Run this with your first admin's details
createAdmin('your-firebase-uid', 'admin@example.com', 'Admin Name');
```

### Deploy Security Rules
```bash
firebase deploy --only firestore:rules
```

### Deploy Indexes
```bash
firebase deploy --only firestore:indexes
```

### Deploy Functions
```bash
cd firebase/functions
npm install
cd ../..
firebase deploy --only functions
```

### Deploy All
```bash
firebase deploy
```

## Testing Security Rules

Use the Firebase Emulator Suite for local testing:

```bash
firebase emulators:start
```

Test cases to verify:
- ✅ Regular users can create/read/update their own User document
- ✅ Regular users can read Routes and Fares
- ❌ Regular users cannot create Routes or Fares
- ❌ Regular users cannot access Admin collection
- ✅ Admins can manage Routes, Fares
- ✅ Admins can read Admin collection

## Performance Optimization

### Best Practices
1. Always use indexes for compound queries
2. Limit query results with `.limit()`
3. Use pagination for large datasets
4. Cache frequently accessed data client-side
5. Use real-time listeners sparingly

### Monitoring
- Check Firebase Console → Performance for query performance
- Review Firestore usage metrics regularly
- Set up budget alerts to avoid unexpected costs

## Security Best Practices

1. **Never expose admin credentials** in client code
2. **Always validate data** on the client before submission
3. **Use server-side validation** via Cloud Functions for critical operations
4. **Regularly audit** admin user list
5. **Monitor Firestore logs** for suspicious activity
6. **Keep Firebase SDK updated** to latest version

## Backup and Recovery

### Automated Backups
Set up automated Firestore backups:
```bash
gcloud firestore export gs://[BUCKET_NAME]/backups/[TIMESTAMP]
```

### Manual Backup
Use Firebase Console → Firestore → Import/Export

## Troubleshooting

### Common Issues

**Problem:** "Permission denied" errors
**Solution:** Check that user is authenticated and has correct role

**Problem:** Queries timing out
**Solution:** Ensure proper indexes are deployed

**Problem:** Admin creation fails
**Solution:** Verify you're using Firebase Admin SDK, not client SDK

**Problem:** Cloud functions not triggering
**Solution:** Check function deployment status and logs in Firebase Console

## Support

For issues or questions:
1. Check Firebase Console logs
2. Review this documentation
3. Check Firebase documentation: https://firebase.google.com/docs

## Version History

- **v1.1** (2025-01-25): Enhanced security rules with admin verification
- **v1.0** (Initial): Basic CRUD operations with public access
