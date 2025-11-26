import 'package:flutter/foundation.dart';

/// Rate limiter to prevent excessive API calls and control costs
class RateLimiter {
  static final Map<String, List<DateTime>> _userRequests = {};
  static final Map<String, List<DateTime>> _globalRequests = {};

  /// Check if user has exceeded rate limit
  /// Returns true if request is allowed, false if rate limit exceeded
  static bool checkUserRateLimit(
    String userId, {
    int maxRequests = 100, // Max requests
    Duration window = const Duration(minutes: 1), // Time window
  }) {
    final now = DateTime.now();
    final windowStart = now.subtract(window);

    // Clean old requests outside the window
    _userRequests[userId]?.removeWhere((time) => time.isBefore(windowStart));

    // Check current count
    final requests = _userRequests[userId] ?? [];
    if (requests.length >= maxRequests) {
      debugPrint(
          'Rate limit exceeded for user $userId: ${requests.length}/$maxRequests in $window');
      return false; // Rate limit exceeded
    }

    // Add current request
    _userRequests[userId] = [...requests, now];
    return true;
  }

  /// Check global rate limit (for unauthenticated requests)
  static bool checkGlobalRateLimit({
    int maxRequests = 1000, // Max global requests
    Duration window = const Duration(minutes: 1),
  }) {
    final now = DateTime.now();
    final windowStart = now.subtract(window);

    // Clean old requests
    _globalRequests['global']
        ?.removeWhere((time) => time.isBefore(windowStart));

    // Check current count
    final requests = _globalRequests['global'] ?? [];
    if (requests.length >= maxRequests) {
      debugPrint(
          'Global rate limit exceeded: ${requests.length}/$maxRequests in $window');
      return false;
    }

    // Add current request
    _globalRequests['global'] = [...requests, now];
    return true;
  }

  /// Clear rate limit data for a user (useful after logout)
  static void clearUserRateLimit(String userId) {
    _userRequests.remove(userId);
  }

  /// Clear all rate limit data
  static void clearAllRateLimits() {
    _userRequests.clear();
    _globalRequests.clear();
  }

  /// Get remaining requests for a user
  static int getRemainingRequests(
    String userId, {
    int maxRequests = 100,
    Duration window = const Duration(minutes: 1),
  }) {
    final now = DateTime.now();
    final windowStart = now.subtract(window);

    // Clean old requests
    _userRequests[userId]?.removeWhere((time) => time.isBefore(windowStart));

    final requests = _userRequests[userId] ?? [];
    return maxRequests - requests.length;
  }

  /// Check if user is approaching rate limit (> 80%)
  static bool isApproachingLimit(
    String userId, {
    int maxRequests = 100,
    double threshold = 0.8,
  }) {
    final requests = _userRequests[userId] ?? [];
    return requests.length > (maxRequests * threshold);
  }
}

/// Rate limiter specifically for Firestore operations to control costs
class FirestoreRateLimiter {
  static final Map<String, int> _dailyReads = {};
  static final Map<String, int> _dailyWrites = {};
  static DateTime? _lastReset;

  // Conservative daily limits to stay within free tier
  static const int maxDailyReadsPerUser = 500;
  static const int maxDailyWritesPerUser = 200;
  static const int maxGlobalDailyReads = 45000; // Leave buffer from 50K free tier
  static const int maxGlobalDailyWrites = 18000; // Leave buffer from 20K free tier

  /// Reset counters daily
  static void _checkAndReset() {
    final now = DateTime.now();
    if (_lastReset == null ||
        now.difference(_lastReset!).inHours >= 24) {
      _dailyReads.clear();
      _dailyWrites.clear();
      _lastReset = now;
      debugPrint('Firestore rate limits reset');
    }
  }

  /// Check if user can perform a read operation
  static bool canRead(String userId) {
    _checkAndReset();

    final userReads = _dailyReads[userId] ?? 0;
    final globalReads = _dailyReads.values.fold(0, (sum, val) => sum + val);

    if (userReads >= maxDailyReadsPerUser) {
      debugPrint('User $userId exceeded daily read limit');
      return false;
    }

    if (globalReads >= maxGlobalDailyReads) {
      debugPrint('Global daily read limit exceeded');
      return false;
    }

    _dailyReads[userId] = userReads + 1;
    return true;
  }

  /// Check if user can perform a write operation
  static bool canWrite(String userId) {
    _checkAndReset();

    final userWrites = _dailyWrites[userId] ?? 0;
    final globalWrites = _dailyWrites.values.fold(0, (sum, val) => sum + val);

    if (userWrites >= maxDailyWritesPerUser) {
      debugPrint('User $userId exceeded daily write limit');
      return false;
    }

    if (globalWrites >= maxGlobalDailyWrites) {
      debugPrint('Global daily write limit exceeded');
      return false;
    }

    _dailyWrites[userId] = userWrites + 1;
    return true;
  }

  /// Get usage statistics
  static Map<String, dynamic> getUsageStats(String userId) {
    _checkAndReset();

    final userReads = _dailyReads[userId] ?? 0;
    final userWrites = _dailyWrites[userId] ?? 0;
    final globalReads = _dailyReads.values.fold(0, (sum, val) => sum + val);
    final globalWrites = _dailyWrites.values.fold(0, (sum, val) => sum + val);

    return {
      'userReads': userReads,
      'userWrites': userWrites,
      'userReadLimit': maxDailyReadsPerUser,
      'userWriteLimit': maxDailyWritesPerUser,
      'globalReads': globalReads,
      'globalWrites': globalWrites,
      'globalReadLimit': maxGlobalDailyReads,
      'globalWriteLimit': maxGlobalDailyWrites,
      'userReadPercentage': (userReads / maxDailyReadsPerUser * 100).toStringAsFixed(1),
      'userWritePercentage': (userWrites / maxDailyWritesPerUser * 100).toStringAsFixed(1),
    };
  }
}

/// Example usage:
///
/// ```dart
/// // Before making Firestore query
/// if (!RateLimiter.checkUserRateLimit(userId)) {
///   // Show error to user
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(content: Text('Too many requests. Please try again later.')),
///   );
///   return;
/// }
///
/// // Proceed with query
/// final routes = await queryCollection(...);
/// ```
///
/// ```dart
/// // Before Firestore read
/// if (!FirestoreRateLimiter.canRead(userId)) {
///   // Use cached data or show warning
///   return cachedData;
/// }
///
/// final data = await FirebaseFirestore.instance.collection('Routes').get();
/// ```
