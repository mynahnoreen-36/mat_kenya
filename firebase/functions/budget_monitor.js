const functions = require("firebase-functions");
const admin = require("firebase-admin");

/**
 * Budget monitoring Cloud Function
 *
 * This function monitors Firebase billing and takes action when budget thresholds are exceeded.
 *
 * Setup:
 * 1. Create a Pub/Sub topic for billing alerts in GCP Console
 * 2. Set up budget alerts to publish to this topic
 * 3. Deploy this function
 *
 * Commands:
 * gcloud pubsub topics create billing-alerts
 * gcloud alpha billing budgets create \
 *   --billing-account=[BILLING_ACCOUNT_ID] \
 *   --display-name="Mat Kenya Budget" \
 *   --budget-amount=100 \
 *   --threshold-rule=percent=50 \
 *   --threshold-rule=percent=80 \
 *   --threshold-rule=percent=100 \
 *   --pubsub-topic=projects/[PROJECT_ID]/topics/billing-alerts
 */

// Initialize admin if not already done
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * Monitor budget and send alerts
 */
exports.budgetMonitor = functions.pubsub
  .topic("billing-alerts")
  .onPublish(async (message) => {
    try {
      const budgetData = JSON.parse(
        Buffer.from(message.data, "base64").toString()
      );

      console.log("Budget alert received:", budgetData);

      const costAmount = budgetData.costAmount || 0;
      const budgetAmount = budgetData.budgetAmount || 0;
      const percentOfBudget = costAmount / budgetAmount;
      const budgetDisplayName = budgetData.budgetDisplayName || "Unknown";

      // Log to Firestore for tracking
      await db.collection("budget_alerts").add({
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        costAmount,
        budgetAmount,
        percentOfBudget,
        budgetName: budgetDisplayName,
        alertLevel: getAlertLevel(percentOfBudget),
      });

      // Take action based on budget percentage
      if (percentOfBudget >= 1.1) {
        // 110% - Critical alert
        await handleCriticalBudget(percentOfBudget, costAmount, budgetAmount);
      } else if (percentOfBudget >= 1.0) {
        // 100% - Budget exceeded
        await handleBudgetExceeded(percentOfBudget, costAmount, budgetAmount);
      } else if (percentOfBudget >= 0.9) {
        // 90% - Warning
        await handleBudgetWarning(percentOfBudget, costAmount, budgetAmount);
      } else if (percentOfBudget >= 0.8) {
        // 80% - Notice
        await handleBudgetNotice(percentOfBudget, costAmount, budgetAmount);
      }

      return null;
    } catch (error) {
      console.error("Error processing budget alert:", error);
      return null;
    }
  });

/**
 * Handle critical budget situation (>110%)
 */
async function handleCriticalBudget(percent, cost, budget) {
  console.error("🚨 CRITICAL: Budget exceeded by", ((percent - 1) * 100).toFixed(1), "%");

  // Send urgent notification to all admins
  const admins = await db.collection("Admin").get();
  const notifications = [];

  for (const admin of admins.docs) {
    notifications.push(
      sendPushNotification(admin.id, {
        title: "🚨 URGENT: Budget Crisis",
        body: `Firebase costs at $${cost.toFixed(2)} (${(percent * 100).toFixed(1)}% of budget)`,
        priority: "high",
      })
    );
  }

  await Promise.all(notifications);

  // Log critical event
  await db.collection("system_events").add({
    type: "critical_budget_alert",
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    details: {
      percent,
      cost,
      budget,
    },
  });

  // Consider disabling non-critical functions here if needed
  // await disableNonCriticalFunctions();
}

/**
 * Handle budget exceeded (100-110%)
 */
async function handleBudgetExceeded(percent, cost, budget) {
  console.warn("⚠️ Budget exceeded:", cost, "/", budget);

  // Notify admins
  await sendAdminNotification({
    title: "Budget Exceeded",
    body: `Monthly budget of $${budget} exceeded. Current: $${cost.toFixed(2)}`,
    priority: "high",
  });
}

/**
 * Handle budget warning (90-100%)
 */
async function handleBudgetWarning(percent, cost, budget) {
  console.warn("⚠️ Budget warning:", (percent * 100).toFixed(1), "%");

  await sendAdminNotification({
    title: "Budget Warning",
    body: `Approaching budget limit: ${(percent * 100).toFixed(1)}% ($${cost.toFixed(2)}/$${budget})`,
    priority: "default",
  });
}

/**
 * Handle budget notice (80-90%)
 */
async function handleBudgetNotice(percent, cost, budget) {
  console.log("ℹ️ Budget notice:", (percent * 100).toFixed(1), "%");

  await sendAdminNotification({
    title: "Budget Notice",
    body: `${(percent * 100).toFixed(1)}% of monthly budget used ($${cost.toFixed(2)}/$${budget})`,
    priority: "low",
  });
}

/**
 * Send notification to all admins
 */
async function sendAdminNotification({ title, body, priority = "default" }) {
  try {
    // Create push notification document
    await db.collection("ff_push_notifications").add({
      notification_title: title,
      notification_text: body,
      target_audience: "All",
      initial_page_name: "AdminPage",
      parameter_data: JSON.stringify({ type: "budget_alert" }),
      status: "pending",
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log("Admin notification sent:", title);
  } catch (error) {
    console.error("Error sending admin notification:", error);
  }
}

/**
 * Send push notification to specific user
 */
async function sendPushNotification(userId, { title, body, priority = "default" }) {
  try {
    const userTokens = await db
      .collection("Users")
      .doc(userId)
      .collection("fcm_tokens")
      .get();

    const tokens = userTokens.docs.map((doc) => doc.data().fcm_token);

    if (tokens.length === 0) {
      console.log("No FCM tokens for user:", userId);
      return;
    }

    const message = {
      notification: { title, body },
      tokens,
    };

    const response = await admin.messaging().sendEachForMulticast(message);
    console.log("Push notification sent to user:", userId, "Success:", response.successCount);
  } catch (error) {
    console.error("Error sending push notification:", error);
  }
}

/**
 * Get alert level based on percentage
 */
function getAlertLevel(percent) {
  if (percent >= 1.1) return "critical";
  if (percent >= 1.0) return "exceeded";
  if (percent >= 0.9) return "warning";
  if (percent >= 0.8) return "notice";
  return "normal";
}

/**
 * Scheduled function to check usage metrics
 * Runs daily to monitor usage patterns
 */
exports.dailyUsageCheck = functions.pubsub
  .schedule("0 9 * * *") // Run at 9 AM daily
  .timeZone("Africa/Nairobi")
  .onRun(async (context) => {
    try {
      console.log("Running daily usage check...");

      // Get usage stats (you'd need to implement actual stat collection)
      const stats = await collectUsageStats();

      // Log usage
      await db.collection("daily_usage").add({
        date: admin.firestore.FieldValue.serverTimestamp(),
        ...stats,
      });

      // Check for anomalies
      if (stats.anomalyDetected) {
        await sendAdminNotification({
          title: "Usage Anomaly Detected",
          body: `Unusual spike in ${stats.anomalyType}: ${stats.anomalyValue}`,
          priority: "high",
        });
      }

      console.log("Daily usage check completed");
      return null;
    } catch (error) {
      console.error("Error in daily usage check:", error);
      return null;
    }
  });

/**
 * Collect usage statistics
 * Placeholder - implement based on your needs
 */
async function collectUsageStats() {
  // This is a placeholder - you'd need to use Firebase Admin SDK
  // or Google Cloud APIs to get actual usage metrics
  return {
    firestoreReads: 0,
    firestoreWrites: 0,
    functionInvocations: 0,
    storageGB: 0,
    anomalyDetected: false,
  };
}

/**
 * Disable non-critical functions in emergency
 * Only use if costs are spiraling out of control
 */
async function disableNonCriticalFunctions() {
  console.warn("🛑 Disabling non-critical functions...");

  // Log the action
  await db.collection("system_events").add({
    type: "emergency_shutdown",
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    message: "Non-critical functions disabled due to budget crisis",
  });

  // You would implement actual function disabling here
  // This might involve updating a config that your functions check
  await db.collection("config").doc("emergency").set({
    nonCriticalFunctionsEnabled: false,
    disabledAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  console.log("Non-critical functions disabled");
}

/**
 * HTTP endpoint to manually check budget status
 */
exports.checkBudgetStatus = functions.https.onCall(async (data, context) => {
  // Only allow admins
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Must be authenticated to check budget status"
    );
  }

  // Check if user is admin
  const adminDoc = await db.collection("Admin").doc(context.auth.uid).get();
  if (!adminDoc.exists) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Only admins can check budget status"
    );
  }

  try {
    // Get recent budget alerts
    const recentAlerts = await db
      .collection("budget_alerts")
      .orderBy("timestamp", "desc")
      .limit(10)
      .get();

    const alerts = recentAlerts.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    // Get daily usage stats
    const recentUsage = await db
      .collection("daily_usage")
      .orderBy("date", "desc")
      .limit(7)
      .get();

    const usage = recentUsage.docs.map((doc) => doc.data());

    return {
      success: true,
      recentAlerts: alerts,
      recentUsage: usage,
      status: alerts.length > 0 ? alerts[0].alertLevel : "normal",
    };
  } catch (error) {
    console.error("Error checking budget status:", error);
    throw new functions.https.HttpsError("internal", "Failed to check budget status");
  }
});
