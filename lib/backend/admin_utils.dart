import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'backend.dart';

/// Utility class for admin role verification and management
class AdminUtils {
  /// Check if the current user is an admin
  /// Returns true if user is in Admin collection OR has admin role in Users collection
  static Future<bool> isCurrentUserAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      // Method 1: Check Admin collection
      final adminDoc = await FirebaseFirestore.instance
          .collection('Admin')
          .doc(user.uid)
          .get();

      if (adminDoc.exists) {
        return true;
      }

      // Method 2: Check Users collection role or is_admin field
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        // Check both is_admin (matches Firestore rules) and role (legacy)
        final isAdmin = data?['is_admin'] as bool?;
        final role = data?['role'] as String?;
        return isAdmin == true || role == 'admin';
      }

      return false;
    } catch (e) {
      debugPrint('Error checking admin status: $e');
      return false;
    }
  }

  /// Check if a specific user ID is an admin
  static Future<bool> isUserAdmin(String userId) async {
    try {
      // Method 1: Check Admin collection
      final adminDoc = await FirebaseFirestore.instance
          .collection('Admin')
          .doc(userId)
          .get();

      if (adminDoc.exists) {
        return true;
      }

      // Method 2: Check Users collection role
      final userDoc =
          await FirebaseFirestore.instance.collection('Users').doc(userId).get();

      if (userDoc.exists) {
        final role = userDoc.data()?['role'] as String?;
        return role == 'admin';
      }

      return false;
    } catch (e) {
      debugPrint('Error checking admin status for user $userId: $e');
      return false;
    }
  }

  /// Get all admin users
  static Future<List<UsersRecord>> getAllAdmins() async {
    try {
      return await queryCollectionOnce(
        UsersRecord.collection,
        UsersRecord.fromSnapshot,
        queryBuilder: (q) => q.where('role', isEqualTo: 'admin'),
      );
    } catch (e) {
      debugPrint('Error getting admin users: $e');
      return [];
    }
  }

  /// Promote a user to admin role
  /// Note: This will only work if current user is already an admin
  /// The Firestore rules will reject this if not authorized
  static Future<bool> promoteUserToAdmin({
    required String userId,
    required String userEmail,
    required String userName,
  }) async {
    try {
      final isAdmin = await isCurrentUserAdmin();
      if (!isAdmin) {
        debugPrint('Error: Only admins can promote users');
        return false;
      }

      // Update Users collection
      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'role': 'admin',
      });

      // Add to Admin collection
      await FirebaseFirestore.instance.collection('Admin').doc(userId).set({
        'adminid': userId,
        'email': userEmail,
        'name': userName,
        'role': 'admin',
      });

      return true;
    } catch (e) {
      debugPrint('Error promoting user to admin: $e');
      return false;
    }
  }

  /// Remove admin privileges from a user
  /// Note: This will only work if current user is already an admin
  static Future<bool> revokeAdminPrivileges(String userId) async {
    try {
      final isAdmin = await isCurrentUserAdmin();
      if (!isAdmin) {
        debugPrint('Error: Only admins can revoke admin privileges');
        return false;
      }

      // Don't allow removing yourself as admin
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser?.uid == userId) {
        debugPrint('Error: Cannot remove your own admin privileges');
        return false;
      }

      // Update Users collection
      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'role': 'user',
      });

      // Note: We don't delete from Admin collection due to Firestore rules
      // That would need to be done manually or via backend function

      return true;
    } catch (e) {
      debugPrint('Error revoking admin privileges: $e');
      return false;
    }
  }

  /// Validate route data before creation
  static String? validateRouteData({
    required String origin,
    required String destination,
    required String routeId,
  }) {
    if (origin.trim().isEmpty) {
      return 'Origin cannot be empty';
    }
    if (destination.trim().isEmpty) {
      return 'Destination cannot be empty';
    }
    if (routeId.trim().isEmpty) {
      return 'Route ID cannot be empty';
    }
    if (origin.trim() == destination.trim()) {
      return 'Origin and destination cannot be the same';
    }
    return null; // Valid
  }

  /// Validate fare data before creation
  static String? validateFareData({
    required String routeId,
    required int standardFare,
    required double peakMultiplier,
  }) {
    if (routeId.trim().isEmpty) {
      return 'Route ID cannot be empty';
    }
    if (standardFare <= 0) {
      return 'Standard fare must be greater than 0';
    }
    if (peakMultiplier < 0) {
      return 'Peak multiplier cannot be negative';
    }
    if (peakMultiplier > 10) {
      return 'Peak multiplier seems too high (max 10x recommended)';
    }
    return null; // Valid
  }

  /// Calculate fare with peak hours consideration
  static int calculateFare({
    required int standardFare,
    required double peakMultiplier,
    required DateTime currentTime,
    required String peakHoursStart,
    required String peakHoursEnd,
  }) {
    if (peakMultiplier <= 0 ||
        peakHoursStart.isEmpty ||
        peakHoursEnd.isEmpty) {
      return standardFare;
    }

    try {
      // Parse peak hours (format: "HH:MM")
      final startParts = peakHoursStart.split(':');
      final endParts = peakHoursEnd.split(':');

      if (startParts.length != 2 || endParts.length != 2) {
        return standardFare;
      }

      final startHour = int.parse(startParts[0]);
      final startMinute = int.parse(startParts[1]);
      final endHour = int.parse(endParts[0]);
      final endMinute = int.parse(endParts[1]);

      final currentHour = currentTime.hour;
      final currentMinute = currentTime.minute;

      // Convert to minutes for easier comparison
      final currentMinutes = currentHour * 60 + currentMinute;
      final startMinutes = startHour * 60 + startMinute;
      final endMinutes = endHour * 60 + endMinute;

      // Check if current time is within peak hours
      bool isPeakHour;
      if (startMinutes < endMinutes) {
        // Peak hours don't cross midnight
        isPeakHour = currentMinutes >= startMinutes && currentMinutes < endMinutes;
      } else {
        // Peak hours cross midnight
        isPeakHour = currentMinutes >= startMinutes || currentMinutes < endMinutes;
      }

      return isPeakHour ? (standardFare * peakMultiplier).round() : standardFare;
    } catch (e) {
      debugPrint('Error calculating peak fare: $e');
      return standardFare;
    }
  }
}
