import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Utility to create the default admin user
/// Call this once during app initialization or from a debug screen
class CreateDefaultAdmin {
  static const String defaultAdminEmail = 'mynahnoreen@gmail.com';
  static const String defaultAdminPassword = 'Kitiko.13936';
  static const String defaultAdminName = 'Administrator';

  /// Creates the default admin user
  /// Returns true if successful, false otherwise
  static Future<bool> createAdmin() async {
    try {
      debugPrint('🚀 Creating default admin user...');
      debugPrint('Email: $defaultAdminEmail');

      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;

      UserCredential? userCredential;
      String uid;
      bool isNewUser = false;

      try {
        // Try to create a new user
        debugPrint('📝 Creating new user in Firebase Auth...');
        userCredential = await auth.createUserWithEmailAndPassword(
          email: defaultAdminEmail,
          password: defaultAdminPassword,
        );
        uid = userCredential.user!.uid;
        isNewUser = true;
        debugPrint('✓ User created in Firebase Auth (UID: $uid)');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // User exists, try to sign in to get the UID
          debugPrint('ℹ️  User already exists, signing in...');
          try {
            userCredential = await auth.signInWithEmailAndPassword(
              email: defaultAdminEmail,
              password: defaultAdminPassword,
            );
            uid = userCredential.user!.uid;
            debugPrint('✓ Signed in successfully (UID: $uid)');
          } catch (signInError) {
            debugPrint('❌ User exists but cannot sign in: $signInError');
            debugPrint('   The password might have been changed.');
            return false;
          }
        } else {
          debugPrint('❌ Error creating user: ${e.message}');
          rethrow;
        }
      }

      // Update display name if new user
      if (isNewUser && userCredential?.user != null) {
        await userCredential!.user!.updateDisplayName(defaultAdminName);
        await userCredential.user!.reload();
      }

      // Create/Update Users collection document
      debugPrint('📝 Updating Users collection...');
      await firestore.collection('Users').doc(uid).set({
        'email': defaultAdminEmail,
        'uid': uid,
        'display_name': defaultAdminName,
        'role': 'admin',
        'created_time': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('✓ Users collection updated');

      // Create/Update Admin collection document
      debugPrint('📝 Updating Admin collection...');
      await firestore.collection('Admin').doc(uid).set({
        'adminid': uid,
        'email': defaultAdminEmail,
        'name': defaultAdminName,
        'role': 'admin',
      }, SetOptions(merge: true));
      debugPrint('✓ Admin collection updated');

      // Success!
      debugPrint('🎉 SUCCESS! Admin user is ready!');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📋 Admin Credentials:');
      debugPrint('   Email:        $defaultAdminEmail');
      debugPrint('   Password:     $defaultAdminPassword');
      debugPrint('   Display Name: $defaultAdminName');
      debugPrint('   UID:          $uid');
      debugPrint('   Role:         admin');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (isNewUser) {
        debugPrint('⚠️  IMPORTANT: Change the password after first login!');
      }

      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating admin user: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Sign out after creating admin (optional)
  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    debugPrint('✓ Signed out');
  }
}
