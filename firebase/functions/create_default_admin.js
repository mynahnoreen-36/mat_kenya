#!/usr/bin/env node

/**
 * Script to create the default admin user
 *
 * Usage:
 *   node firebase/create_default_admin.js
 *
 * This script requires Firebase Admin SDK to be initialized.
 * Make sure you have the Firebase credentials set up.
 */

const admin = require('firebase-admin');
const path = require('path');

// Try to initialize Firebase Admin
try {
  // Check if already initialized
  if (admin.apps.length === 0) {
    // Try to use application default credentials
    admin.initializeApp({
      projectId: 'matkenya-a1926',
    });
  }
} catch (error) {
  console.error('Error initializing Firebase Admin:', error);
  console.log('\nPlease ensure you have Firebase credentials set up.');
  console.log('You can set up default credentials by running:');
  console.log('  firebase login');
  console.log('  export GOOGLE_APPLICATION_CREDENTIALS="path/to/serviceAccountKey.json"');
  process.exit(1);
}

const db = admin.firestore();
const auth = admin.auth();

// Default admin credentials
const DEFAULT_ADMIN = {
  email: 'mynahnoreen@gmail.com',
  password: 'Kitiko.13936',
  displayName: 'Administrator',
};

async function createDefaultAdmin() {
  console.log('🚀 Creating default admin user...\n');
  console.log(`Email: ${DEFAULT_ADMIN.email}`);
  console.log(`Display Name: ${DEFAULT_ADMIN.displayName}\n`);

  try {
    let userRecord;
    let isNewUser = false;

    // Check if user already exists
    try {
      userRecord = await auth.getUserByEmail(DEFAULT_ADMIN.email);
      console.log(`ℹ️  User already exists in Firebase Auth`);
      console.log(`   UID: ${userRecord.uid}\n`);
    } catch (error) {
      if (error.code === 'auth/user-not-found') {
        // Create new user in Firebase Auth
        console.log('📝 Creating new user in Firebase Auth...');
        userRecord = await auth.createUser({
          email: DEFAULT_ADMIN.email,
          password: DEFAULT_ADMIN.password,
          displayName: DEFAULT_ADMIN.displayName,
          emailVerified: true,
        });
        isNewUser = true;
        console.log(`✓ User created in Firebase Auth`);
        console.log(`   UID: ${userRecord.uid}\n`);
      } else {
        throw error;
      }
    }

    const uid = userRecord.uid;

    // Update/Create Users collection document
    console.log('📝 Updating Users collection...');
    await db.collection('Users').doc(uid).set({
      email: DEFAULT_ADMIN.email,
      uid: uid,
      display_name: DEFAULT_ADMIN.displayName,
      role: 'admin',
      created_time: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
    console.log('✓ Users collection updated\n');

    // Update/Create Admin collection document
    console.log('📝 Updating Admin collection...');
    await db.collection('Admin').doc(uid).set({
      adminid: uid,
      email: DEFAULT_ADMIN.email,
      name: DEFAULT_ADMIN.displayName,
      role: 'admin',
    }, { merge: true });
    console.log('✓ Admin collection updated\n');

    // Success message
    console.log('🎉 SUCCESS! Admin user is ready!\n');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📋 Admin Credentials:');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`   Email:        ${DEFAULT_ADMIN.email}`);
    console.log(`   Password:     ${DEFAULT_ADMIN.password}`);
    console.log(`   Display Name: ${DEFAULT_ADMIN.displayName}`);
    console.log(`   UID:          ${uid}`);
    console.log(`   Role:         admin`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    if (isNewUser) {
      console.log('⚠️  IMPORTANT: This is the only time the password is shown.');
      console.log('   Save it securely and change it after first login.\n');
    }

    console.log('✓ You can now log in to the app with these credentials.');
    console.log('✓ The user has full admin privileges.\n');

  } catch (error) {
    console.error('❌ Error creating admin user:', error);
    console.error('\nDetails:', error.message);

    if (error.code === 'permission-denied') {
      console.error('\n⚠️  Permission denied. Please check:');
      console.error('   1. Firebase credentials are properly set up');
      console.error('   2. Your service account has the necessary permissions');
      console.error('   3. Firestore security rules allow this operation');
    }

    process.exit(1);
  }
}

// Run the script
createDefaultAdmin()
  .then(() => {
    console.log('✓ Script completed successfully!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Script failed:', error);
    process.exit(1);
  });
