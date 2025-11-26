# Firebase Billing & Cost Management Guide

## Overview
This guide helps you set up billing alerts and manage costs for your Mat Kenya Firebase backend.

## Table of Contents
1. [Enable Billing](#enable-billing)
2. [Set Up Billing Alerts](#set-up-billing-alerts)
3. [Budget Recommendations](#budget-recommendations)
4. [Cost Monitoring](#cost-monitoring)
5. [Set Usage Quotas](#set-usage-quotas)
6. [Cost Optimization](#cost-optimization)
7. [Emergency Cost Controls](#emergency-cost-controls)

---

## Enable Billing

### Step 1: Link Billing Account

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your Mat Kenya project
3. Click the gear icon ⚙️ → **Project Settings**
4. Go to **Usage and Billing** tab
5. Click **Modify Plan**
6. Select **Blaze (Pay as you go)** plan
7. Link or create a Google Cloud billing account

### Step 2: Verify Billing Setup

```bash
# Check if billing is enabled (requires gcloud CLI)
gcloud projects describe mat-kenya --format="value(projectId)"
gcloud beta billing projects describe mat-kenya
```

---

## Set Up Billing Alerts

### Method 1: Google Cloud Console (Recommended)

#### A. Set Up Budget Alerts

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select your Mat Kenya project
3. Navigate to **Billing** → **Budgets & alerts**
4. Click **CREATE BUDGET**

**Configure Budget:**

```yaml
Budget Name: Mat Kenya Monthly Budget
Time Range: Monthly
Projects: mat-kenya
Services: All services (or select specific Firebase services)
```

**Set Budget Amount:**
```
For development/testing: $10-50/month
For small production: $50-200/month
For growing app: $200-1000/month
```

**Configure Alert Thresholds:**
- ✅ 50% of budget ($25 if $50 budget)
- ✅ 80% of budget ($40 if $50 budget)
- ✅ 90% of budget ($45 if $50 budget)
- ✅ 100% of budget ($50 if $50 budget)
- ✅ 110% of budget ($55 if $50 budget) - Overage alert

**Set Alert Recipients:**
- Add email addresses for: developer@example.com, admin@example.com
- Optional: Set up Pub/Sub notifications for automated responses

#### B. Set Up Programmatic Notifications (Advanced)

Create a Cloud Function to respond to budget alerts:

```bash
# Enable required APIs
gcloud services enable cloudbilling.googleapis.com
gcloud services enable cloudpubsub.googleapis.com
gcloud services enable cloudfunctions.googleapis.com
```

### Method 2: Firebase Console Quick Setup

1. Firebase Console → **Usage and Billing**
2. Click **Set budget alert**
3. Enter monthly budget amount
4. Set alert threshold (e.g., 80%)
5. Add notification emails
6. Click **Save**

---

## Budget Recommendations

### Development Phase
```yaml
Recommended Budget: $10-20/month
Expected Usage:
  - Firestore: 10K reads, 5K writes/day
  - Cloud Functions: 1K invocations/day
  - Storage: < 1GB
  - Authentication: < 1K daily active users
```

### Launch Phase (First 1000 users)
```yaml
Recommended Budget: $50-100/month
Expected Usage:
  - Firestore: 100K reads, 50K writes/day
  - Cloud Functions: 10K invocations/day
  - Storage: 5-10GB
  - Authentication: 100-500 daily active users
```

### Growth Phase (1000-10000 users)
```yaml
Recommended Budget: $200-500/month
Expected Usage:
  - Firestore: 500K reads, 200K writes/day
  - Cloud Functions: 50K invocations/day
  - Storage: 20-50GB
  - Authentication: 500-2000 daily active users
```

### Mature Phase (10000+ users)
```yaml
Recommended Budget: $500-2000/month
Consider:
  - Committed use discounts
  - Architecture optimization
  - Caching strategies
  - CDN for static content
```

---

## Cost Monitoring

### Daily Monitoring Dashboard

Create a monitoring routine:

1. **Daily Quick Check** (5 minutes)
   - Firebase Console → Usage tab
   - Check current month's costs
   - Look for unusual spikes

2. **Weekly Review** (15 minutes)
   - Review cost breakdown by service
   - Check Cloud Functions execution count
   - Monitor Firestore read/write operations
   - Review storage usage

3. **Monthly Analysis** (30 minutes)
   - Compare month-over-month costs
   - Identify cost trends
   - Plan optimizations
   - Adjust budgets if needed

### Set Up Cost Reports

1. **Google Cloud Console** → **Billing** → **Reports**
2. Configure report:
   - Time range: Last 30 days
   - Group by: Service
   - Filters: Project = mat-kenya
3. Save report for recurring access

### Key Metrics to Monitor

| Metric | Warning Threshold | Critical Threshold |
|--------|------------------|-------------------|
| Firestore Reads | 1M/day | 5M/day |
| Firestore Writes | 500K/day | 2M/day |
| Cloud Functions Invocations | 100K/day | 500K/day |
| Storage (GB) | 50GB | 100GB |
| Bandwidth (GB) | 10GB/day | 50GB/day |

---

## Set Usage Quotas

### Firestore Quotas

Firebase automatically enforces these limits:
- Free tier: 50K reads, 20K writes, 20K deletes per day
- Blaze plan: Pay per operation after free tier

**Custom Quotas (Optional):**

You can implement app-level rate limiting:

```dart
// lib/backend/rate_limiter.dart
class RateLimiter {
  static final Map<String, List<DateTime>> _userRequests = {};

  // Max 100 requests per user per minute
  static bool checkRateLimit(String userId, {int maxRequests = 100}) {
    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(Duration(minutes: 1));

    // Clean old requests
    _userRequests[userId]?.removeWhere((time) => time.isBefore(oneMinuteAgo));

    // Check current count
    final requests = _userRequests[userId] ?? [];
    if (requests.length >= maxRequests) {
      return false; // Rate limit exceeded
    }

    // Add current request
    _userRequests[userId] = [...requests, now];
    return true;
  }
}
```

### Cloud Functions Quotas

Set maximum instances to prevent runaway costs:

```javascript
// firebase/functions/index.js
// Add this configuration to each function
exports.sendPushNotifications = functions
  .runWith({
    timeoutSeconds: 540,
    memory: '2GB',
    maxInstances: 10, // Limit concurrent executions
  })
  .firestore.document('ff_push_notifications/{id}')
  .onCreate(async (snapshot, _) => {
    // Function code...
  });
```

### Storage Quotas

Set up Firebase Storage rules with size limits:

```javascript
// firebase/storage.rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId
                   && request.resource.size < 5 * 1024 * 1024  // 5MB max
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
```

---

## Cost Optimization

### 1. Firestore Optimization

#### Use Pagination
```dart
// ❌ Bad: Load everything
final allRoutes = await RoutesRecord.collection.get();

// ✅ Good: Load in batches
final routes = await queryCollectionOnce(
  RoutesRecord.collection,
  RoutesRecord.fromSnapshot,
  limit: 50, // Only load 50 at a time
);
```

#### Implement Caching
```dart
// ✅ Cache frequently accessed data
class RouteCache {
  static final Map<String, RoutesRecord> _cache = {};
  static DateTime? _lastUpdate;

  static Future<RoutesRecord?> getRoute(String routeId) async {
    // Return cached if less than 5 minutes old
    if (_cache.containsKey(routeId) &&
        _lastUpdate != null &&
        DateTime.now().difference(_lastUpdate!) < Duration(minutes: 5)) {
      return _cache[routeId];
    }

    // Otherwise fetch and cache
    final route = await RoutesRecord.getDocumentOnce(
      RoutesRecord.collection.doc(routeId)
    );
    _cache[routeId] = route;
    _lastUpdate = DateTime.now();
    return route;
  }
}
```

#### Minimize Real-time Listeners
```dart
// ❌ Expensive: Real-time listener for rarely changing data
StreamBuilder<List<FaresRecord>>(
  stream: queryCollection(FaresRecord.collection, FaresRecord.fromSnapshot),
  ...
);

// ✅ Better: One-time fetch for static data
FutureBuilder<List<FaresRecord>>(
  future: queryCollectionOnce(FaresRecord.collection, FaresRecord.fromSnapshot),
  ...
);
```

### 2. Cloud Functions Optimization

#### Reduce Cold Starts
```javascript
// Keep functions warm with scheduled pings
exports.keepWarm = functions.pubsub
  .schedule('every 5 minutes')
  .onRun(async (context) => {
    console.log('Keeping function warm');
  });
```

#### Batch Operations
```javascript
// ❌ Bad: Multiple function invocations
for (const user of users) {
  await sendNotification(user);
}

// ✅ Good: Single batch operation
await sendBatchNotifications(users);
```

### 3. Storage Optimization

#### Compress Images
```dart
// Use image compression before upload
import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<File> compressImage(File file) async {
  final result = await FlutterImageCompress.compressAndGetFile(
    file.path,
    '${file.path}_compressed.jpg',
    quality: 70,
    minWidth: 1024,
    minHeight: 1024,
  );
  return File(result!.path);
}
```

#### Use CDN for Public Assets
- Store app assets in Firebase Hosting (cheaper than Storage for public files)
- Use Cloud Storage only for user-generated content

### 4. Authentication Optimization

#### Implement Rate Limiting
```dart
// Prevent abuse of auth endpoints
class AuthRateLimiter {
  static DateTime? _lastAttempt;

  static bool canAttemptAuth() {
    if (_lastAttempt != null &&
        DateTime.now().difference(_lastAttempt!) < Duration(seconds: 3)) {
      return false;
    }
    _lastAttempt = DateTime.now();
    return true;
  }
}
```

---

## Emergency Cost Controls

### Automated Shutdown Script

Create a Cloud Function to automatically disable expensive operations:

```javascript
// firebase/functions/budget_monitor.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');

exports.budgetMonitor = functions.pubsub
  .topic('billing-alerts')
  .onPublish(async (message) => {
    const budgetData = JSON.parse(
      Buffer.from(message.data, 'base64').toString()
    );

    const percentOfBudget = budgetData.costAmount / budgetData.budgetAmount;

    // If over 110% of budget, take action
    if (percentOfBudget >= 1.1) {
      console.error('⚠️ BUDGET EXCEEDED! Taking emergency actions...');

      // 1. Disable expensive Cloud Functions
      // 2. Throttle Firestore writes
      // 3. Send urgent alerts

      // Send alert email
      await sendAlertEmail({
        to: 'admin@example.com',
        subject: '🚨 URGENT: Firebase Budget Exceeded',
        text: `Budget exceeded by ${((percentOfBudget - 1) * 100).toFixed(1)}%`,
      });
    }
  });
```

### Manual Emergency Actions

If costs spike unexpectedly:

1. **Immediate Actions (Do within minutes):**
   ```bash
   # Disable Cloud Functions
   firebase functions:config:unset somefunction

   # Or disable all functions temporarily
   gcloud functions list
   gcloud functions delete FUNCTION_NAME --region=us-central1
   ```

2. **Investigate:**
   - Check Cloud Functions logs for infinite loops
   - Look for DDoS or abuse patterns
   - Check for accidental infinite reads/writes
   - Review recent code deployments

3. **Temporary Fixes:**
   - Enable Firestore App Check to block unauthorized access
   - Add stricter rate limiting
   - Disable non-critical features
   - Scale down Cloud Functions max instances

4. **Long-term Fixes:**
   - Implement caching
   - Optimize queries
   - Add monitoring and alerts
   - Review and optimize code

---

## Cost Estimation Tool

Create a simple cost estimator:

```dart
// lib/utils/cost_estimator.dart
class FirebaseCostEstimator {
  // Firestore pricing (USD)
  static const firestoreReadCost = 0.06 / 100000; // $0.06 per 100K reads
  static const firestoreWriteCost = 0.18 / 100000; // $0.18 per 100K writes
  static const firestoreStorageCost = 0.18; // $0.18 per GB/month

  // Cloud Functions pricing
  static const functionInvocationCost = 0.40 / 1000000; // $0.40 per 1M invocations
  static const functionComputeCost = 0.0000025; // Per GB-second

  // Storage pricing
  static const storageCost = 0.026; // $0.026 per GB/month
  static const downloadCost = 0.12; // $0.12 per GB

  static double estimateMonthlyFirestoreCost({
    required int readsPerDay,
    required int writesPerDay,
    required double storageGB,
  }) {
    final monthlyReads = readsPerDay * 30;
    final monthlyWrites = writesPerDay * 30;

    // Subtract free tier
    final paidReads = (monthlyReads - 50000).clamp(0, double.infinity);
    final paidWrites = (monthlyWrites - 20000).clamp(0, double.infinity);

    return (paidReads * firestoreReadCost) +
           (paidWrites * firestoreWriteCost) +
           (storageGB * firestoreStorageCost);
  }

  static double estimateMonthlyCost({
    required int dailyActiveUsers,
    required int firestoreReadsPerUser,
    required int firestoreWritesPerUser,
    required double storageGB,
    required int functionInvocationsPerUser,
  }) {
    final totalReadsPerDay = dailyActiveUsers * firestoreReadsPerUser;
    final totalWritesPerDay = dailyActiveUsers * firestoreWritesPerUser;
    final totalFunctionInvocationsPerDay =
      dailyActiveUsers * functionInvocationsPerUser;

    final firestoreCost = estimateMonthlyFirestoreCost(
      readsPerDay: totalReadsPerDay,
      writesPerDay: totalWritesPerDay,
      storageGB: storageGB,
    );

    final functionCost =
      (totalFunctionInvocationsPerDay * 30 - 2000000) * functionInvocationCost;

    final storageCostTotal = storageGB * storageCost;

    return firestoreCost + functionCost.clamp(0, double.infinity) + storageCostTotal;
  }
}

// Usage:
void main() {
  final estimatedCost = FirebaseCostEstimator.estimateMonthlyCost(
    dailyActiveUsers: 1000,
    firestoreReadsPerUser: 100,
    firestoreWritesPerUser: 20,
    storageGB: 10,
    functionInvocationsPerUser: 10,
  );

  print('Estimated monthly cost: \$${estimatedCost.toStringAsFixed(2)}');
}
```

---

## Monitoring Checklist

### Daily
- [ ] Check Firebase Console usage tab
- [ ] Verify no unusual spikes in metrics
- [ ] Check email for budget alerts

### Weekly
- [ ] Review detailed cost breakdown
- [ ] Check Cloud Functions execution logs
- [ ] Monitor Firestore operation counts
- [ ] Review storage usage trends

### Monthly
- [ ] Full cost analysis and report
- [ ] Compare against budget
- [ ] Identify optimization opportunities
- [ ] Adjust budgets for next month
- [ ] Review and update quotas

---

## Resources

- [Firebase Pricing](https://firebase.google.com/pricing)
- [Cloud Functions Pricing](https://cloud.google.com/functions/pricing)
- [Firestore Pricing Calculator](https://cloud.google.com/products/calculator)
- [Cost Optimization Guide](https://firebase.google.com/docs/firestore/optimize-for-cost)

---

## Quick Reference: Cost Triggers

| Service | Free Tier | Price After Free Tier |
|---------|-----------|----------------------|
| **Firestore Reads** | 50K/day | $0.06 per 100K |
| **Firestore Writes** | 20K/day | $0.18 per 100K |
| **Firestore Storage** | 1 GB | $0.18/GB/month |
| **Cloud Functions** | 2M invocations/month | $0.40 per 1M |
| **Authentication** | Unlimited | Free |
| **Storage** | 5 GB | $0.026/GB/month |
| **Hosting** | 10 GB/month | $0.15/GB |

---

## Support

If you experience unexpected costs:
1. Check [Firebase Status Dashboard](https://status.firebase.google.com)
2. Review [Firebase Support](https://firebase.google.com/support)
3. Contact Google Cloud Billing Support
4. Post in [Firebase Community](https://groups.google.com/g/firebase-talk)
