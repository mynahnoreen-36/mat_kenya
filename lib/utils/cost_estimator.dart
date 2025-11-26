import 'package:flutter/foundation.dart';

/// Firebase cost estimation utility
/// Helps estimate monthly Firebase costs based on usage patterns
class FirebaseCostEstimator {
  // Firestore pricing (USD) - as of 2025
  static const double firestoreReadCost = 0.06 / 100000; // $0.06 per 100K reads
  static const double firestoreWriteCost =
      0.18 / 100000; // $0.18 per 100K writes
  static const double firestoreDeleteCost =
      0.02 / 100000; // $0.02 per 100K deletes
  static const double firestoreStorageCost = 0.18; // $0.18 per GB/month

  // Free tier limits
  static const int freeTierReads = 50000; // per day
  static const int freeTierWrites = 20000; // per day
  static const int freeTierDeletes = 20000; // per day
  static const double freeTierStorage = 1.0; // GB

  // Cloud Functions pricing
  static const double functionInvocationCost =
      0.40 / 1000000; // $0.40 per 1M invocations
  static const double functionComputeTimeCost =
      0.0000025; // Per GB-second
  static const int functionFreeTierInvocations = 2000000; // per month

  // Storage pricing
  static const double storageCost = 0.026; // $0.026 per GB/month
  static const double downloadCost = 0.12; // $0.12 per GB
  static const double freeTierStorageGB = 5.0;
  static const double freeTierDownloadGB = 1.0; // per day

  // Hosting pricing
  static const double hostingStorageCost = 0.026; // $0.026 per GB/month
  static const double hostingTransferCost = 0.15; // $0.15 per GB
  static const double freeTierHostingStorageGB = 10.0;
  static const double freeTierHostingTransferGB = 360.0; // per month

  /// Estimate monthly Firestore costs
  static double estimateMonthlyFirestoreCost({
    required int readsPerDay,
    required int writesPerDay,
    int deletesPerDay = 0,
    required double storageGB,
  }) {
    final monthlyReads = readsPerDay * 30;
    final monthlyWrites = writesPerDay * 30;
    final monthlyDeletes = deletesPerDay * 30;

    // Subtract free tier (daily limit * 30 days)
    final paidReads =
        (monthlyReads - (freeTierReads * 30)).clamp(0, double.infinity);
    final paidWrites =
        (monthlyWrites - (freeTierWrites * 30)).clamp(0, double.infinity);
    final paidDeletes =
        (monthlyDeletes - (freeTierDeletes * 30)).clamp(0, double.infinity);
    final paidStorage = (storageGB - freeTierStorage).clamp(0, double.infinity);

    final readCost = paidReads * firestoreReadCost;
    final writeCost = paidWrites * firestoreWriteCost;
    final deleteCost = paidDeletes * firestoreDeleteCost;
    final storageCost = paidStorage * firestoreStorageCost;

    return readCost + writeCost + deleteCost + storageCost;
  }

  /// Estimate monthly Cloud Functions costs
  static double estimateMonthlyFunctionsCost({
    required int invocationsPerDay,
    double averageExecutionTimeSeconds = 1.0,
    double memoryGB = 0.256, // 256MB default
  }) {
    final monthlyInvocations = invocationsPerDay * 30;
    final paidInvocations = (monthlyInvocations - functionFreeTierInvocations)
        .clamp(0, double.infinity);

    final invocationCost = paidInvocations * functionInvocationCost;

    // Compute time cost (GB-seconds)
    final gbSeconds =
        monthlyInvocations * averageExecutionTimeSeconds * memoryGB;
    final computeCost = gbSeconds * functionComputeTimeCost;

    return invocationCost + computeCost;
  }

  /// Estimate monthly Storage costs
  static double estimateMonthlyStorageCost({
    required double storageGB,
    required double downloadGBPerDay,
  }) {
    final paidStorage =
        (storageGB - freeTierStorageGB).clamp(0, double.infinity);
    final monthlyDownload = downloadGBPerDay * 30;
    final paidDownload =
        (monthlyDownload - (freeTierDownloadGB * 30)).clamp(0, double.infinity);

    return (paidStorage * storageCost) + (paidDownload * downloadCost);
  }

  /// Estimate total monthly cost for the Mat Kenya app
  static CostEstimate estimateTotalMonthlyCost({
    required int dailyActiveUsers,
    int firestoreReadsPerUser = 100,
    int firestoreWritesPerUser = 20,
    int firestoreDeletesPerUser = 2,
    double firestoreStorageGB = 5.0,
    int functionInvocationsPerUser = 10,
    double functionAvgExecutionTime = 1.0,
    double cloudStorageGB = 10.0,
    double cloudStorageDownloadGBPerDay = 1.0,
  }) {
    // Calculate total daily operations
    final totalReadsPerDay = dailyActiveUsers * firestoreReadsPerUser;
    final totalWritesPerDay = dailyActiveUsers * firestoreWritesPerUser;
    final totalDeletesPerDay = dailyActiveUsers * firestoreDeletesPerUser;
    final totalFunctionInvocationsPerDay =
        dailyActiveUsers * functionInvocationsPerUser;

    // Calculate costs
    final firestoreCost = estimateMonthlyFirestoreCost(
      readsPerDay: totalReadsPerDay,
      writesPerDay: totalWritesPerDay,
      deletesPerDay: totalDeletesPerDay,
      storageGB: firestoreStorageGB,
    );

    final functionsCost = estimateMonthlyFunctionsCost(
      invocationsPerDay: totalFunctionInvocationsPerDay,
      averageExecutionTimeSeconds: functionAvgExecutionTime,
    );

    final storageCost = estimateMonthlyStorageCost(
      storageGB: cloudStorageGB,
      downloadGBPerDay: cloudStorageDownloadGBPerDay,
    );

    // Authentication is free
    final authCost = 0.0;

    final totalCost = firestoreCost + functionsCost + storageCost + authCost;

    return CostEstimate(
      firestoreCost: firestoreCost,
      functionsCost: functionsCost,
      storageCost: storageCost,
      authenticationCost: authCost,
      totalCost: totalCost,
      dailyActiveUsers: dailyActiveUsers,
      breakdown: {
        'Firestore Reads':
            '${(totalReadsPerDay * 30 / 1000000).toStringAsFixed(2)}M/month',
        'Firestore Writes':
            '${(totalWritesPerDay * 30 / 1000000).toStringAsFixed(2)}M/month',
        'Cloud Functions':
            '${(totalFunctionInvocationsPerDay * 30 / 1000000).toStringAsFixed(2)}M/month',
        'Firestore Storage': '${firestoreStorageGB.toStringAsFixed(1)} GB',
        'Cloud Storage': '${cloudStorageGB.toStringAsFixed(1)} GB',
      },
    );
  }

  /// Get cost estimate for different user tiers
  static Map<String, CostEstimate> getScalingEstimates() {
    return {
      'Development (10 DAU)': estimateTotalMonthlyCost(
        dailyActiveUsers: 10,
        firestoreStorageGB: 0.5,
        cloudStorageGB: 1.0,
      ),
      'Early Stage (100 DAU)': estimateTotalMonthlyCost(
        dailyActiveUsers: 100,
        firestoreStorageGB: 2.0,
        cloudStorageGB: 5.0,
      ),
      'Launch (1K DAU)': estimateTotalMonthlyCost(
        dailyActiveUsers: 1000,
        firestoreStorageGB: 10.0,
        cloudStorageGB: 20.0,
        cloudStorageDownloadGBPerDay: 5.0,
      ),
      'Growth (10K DAU)': estimateTotalMonthlyCost(
        dailyActiveUsers: 10000,
        firestoreStorageGB: 50.0,
        cloudStorageGB: 100.0,
        cloudStorageDownloadGBPerDay: 20.0,
      ),
      'Mature (100K DAU)': estimateTotalMonthlyCost(
        dailyActiveUsers: 100000,
        firestoreReadsPerUser: 150, // Higher with scale
        firestoreWritesPerUser: 30,
        firestoreStorageGB: 200.0,
        cloudStorageGB: 500.0,
        cloudStorageDownloadGBPerDay: 100.0,
      ),
    };
  }

  /// Print cost estimates for different scales
  static void printScalingEstimates() {
    final estimates = getScalingEstimates();

    debugPrint('\n=== Mat Kenya Firebase Cost Estimates ===\n');

    estimates.forEach((tier, estimate) {
      debugPrint('$tier:');
      debugPrint('  Total: \$${estimate.totalCost.toStringAsFixed(2)}/month');
      debugPrint(
          '  - Firestore: \$${estimate.firestoreCost.toStringAsFixed(2)}');
      debugPrint(
          '  - Functions: \$${estimate.functionsCost.toStringAsFixed(2)}');
      debugPrint(
          '  - Storage: \$${estimate.storageCost.toStringAsFixed(2)}');
      debugPrint('  Breakdown:');
      estimate.breakdown.forEach((key, value) {
        debugPrint('    - $key: $value');
      });
      debugPrint('');
    });

    debugPrint('Note: Actual costs may vary based on usage patterns.');
    debugPrint('Free tier: 50K reads, 20K writes, 1GB storage per day\n');
  }
}

/// Cost estimate result
class CostEstimate {
  final double firestoreCost;
  final double functionsCost;
  final double storageCost;
  final double authenticationCost;
  final double totalCost;
  final int dailyActiveUsers;
  final Map<String, String> breakdown;

  CostEstimate({
    required this.firestoreCost,
    required this.functionsCost,
    required this.storageCost,
    required this.authenticationCost,
    required this.totalCost,
    required this.dailyActiveUsers,
    required this.breakdown,
  });

  @override
  String toString() {
    return 'CostEstimate(total: \$${totalCost.toStringAsFixed(2)}/month, '
        'DAU: $dailyActiveUsers, '
        'firestore: \$${firestoreCost.toStringAsFixed(2)}, '
        'functions: \$${functionsCost.toStringAsFixed(2)}, '
        'storage: \$${storageCost.toStringAsFixed(2)})';
  }

  /// Convert to JSON for logging/storage
  Map<String, dynamic> toJson() {
    return {
      'firestoreCost': firestoreCost,
      'functionsCost': functionsCost,
      'storageCost': storageCost,
      'authenticationCost': authenticationCost,
      'totalCost': totalCost,
      'dailyActiveUsers': dailyActiveUsers,
      'breakdown': breakdown,
    };
  }
}

/// Example usage:
///
/// ```dart
/// void main() {
///   // Estimate for 1000 daily active users
///   final estimate = FirebaseCostEstimator.estimateTotalMonthlyCost(
///     dailyActiveUsers: 1000,
///     firestoreReadsPerUser: 100,
///     firestoreWritesPerUser: 20,
///     firestoreStorageGB: 10,
///     functionInvocationsPerUser: 10,
///   );
///
///   print('Estimated monthly cost: \$${estimate.totalCost.toStringAsFixed(2)}');
///   print('Firestore: \$${estimate.firestoreCost.toStringAsFixed(2)}');
///   print('Functions: \$${estimate.functionsCost.toStringAsFixed(2)}');
///
///   // Print scaling estimates
///   FirebaseCostEstimator.printScalingEstimates();
/// }
/// ```
