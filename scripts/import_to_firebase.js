#!/usr/bin/env node
/**
 * Firebase Data Import Script
 * Imports mock routes and fares data to Firestore
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Initialize Firebase Admin with environment variables
const serviceAccount = {
  type: "service_account",
  project_id: process.env.FIREBASE_PROJECT_ID || "matkenya-a1926",
  private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
  private_key: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
  client_email: process.env.FIREBASE_CLIENT_EMAIL,
  client_id: process.env.FIREBASE_CLIENT_ID,
  auth_uri: "https://accounts.google.com/o/oauth2/auth",
  token_uri: "https://oauth2.googleapis.com/token",
  auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
};

// Check if we have service account credentials
if (!serviceAccount.private_key || !serviceAccount.client_email) {
  console.error('❌ Error: Firebase service account credentials not found!');
  console.error('\nTo use this script, you need to:');
  console.error('1. Download your Firebase service account key from:');
  console.error('   Firebase Console → Project Settings → Service Accounts');
  console.error('2. Save it as: scripts/serviceAccountKey.json');
  console.error('   OR set environment variables:');
  console.error('   - FIREBASE_PRIVATE_KEY');
  console.error('   - FIREBASE_CLIENT_EMAIL');
  console.error('   - FIREBASE_PRIVATE_KEY_ID');
  console.error('   - FIREBASE_CLIENT_ID');
  console.error('\nAlternatively, use the manual import instructions in the README.');
  process.exit(1);
}

// Try to use local service account file if env vars not set
let config;
try {
  const serviceAccountPath = path.join(__dirname, 'serviceAccountKey.json');
  if (fs.existsSync(serviceAccountPath)) {
    config = { credential: admin.credential.cert(require(serviceAccountPath)) };
    console.log('✅ Using local service account key');
  } else {
    config = { credential: admin.credential.cert(serviceAccount) };
    console.log('✅ Using environment variables for credentials');
  }
} catch (error) {
  config = { credential: admin.credential.cert(serviceAccount) };
}

admin.initializeApp(config);
const db = admin.firestore();

// Load mock data
const routesPath = path.join(__dirname, 'mock_data', 'routes.json');
const faresPath = path.join(__dirname, 'mock_data', 'fares.json');

if (!fs.existsSync(routesPath) || !fs.existsSync(faresPath)) {
  console.error('❌ Error: Mock data files not found!');
  console.error('Run: python3 scripts/generate_mock_data.py');
  process.exit(1);
}

const routes = JSON.parse(fs.readFileSync(routesPath, 'utf8'));
const fares = JSON.parse(fs.readFileSync(faresPath, 'utf8'));

async function importRoutes() {
  console.log('\n📍 Importing routes...');
  let imported = 0;
  let skipped = 0;

  for (const route of routes) {
    try {
      // Check if route already exists
      const existing = await db.collection('Routes')
        .where('route_id', '==', route.route_id)
        .limit(1)
        .get();

      if (existing.empty) {
        await db.collection('Routes').add(route);
        console.log(`  ✅ Added: ${route.route_id} (${route.origin} → ${route.destination})`);
        imported++;
      } else {
        console.log(`  ⏭️  Skipped: ${route.route_id} (already exists)`);
        skipped++;
      }
    } catch (error) {
      console.error(`  ❌ Error adding ${route.route_id}:`, error.message);
    }
  }

  console.log(`\n📊 Routes: ${imported} imported, ${skipped} skipped`);
  return imported;
}

async function importFares() {
  console.log('\n💰 Importing fares...');
  let imported = 0;
  let skipped = 0;

  for (const fare of fares) {
    try {
      // Check if fare already exists
      const existing = await db.collection('Fares')
        .where('route_id', '==', fare.route_id)
        .limit(1)
        .get();

      if (existing.empty) {
        await db.collection('Fares').add(fare);
        console.log(`  ✅ Added: ${fare.route_id} (Ksh ${fare.standard_fare})`);
        imported++;
      } else {
        console.log(`  ⏭️  Skipped: ${fare.route_id} (already exists)`);
        skipped++;
      }
    } catch (error) {
      console.error(`  ❌ Error adding fare for ${fare.route_id}:`, error.message);
    }
  }

  console.log(`\n📊 Fares: ${imported} imported, ${skipped} skipped`);
  return imported;
}

async function verifyImport() {
  console.log('\n🔍 Verifying import...');

  const routesSnapshot = await db.collection('Routes').get();
  const faresSnapshot = await db.collection('Fares').get();

  console.log(`  Routes in database: ${routesSnapshot.size}`);
  console.log(`  Fares in database: ${faresSnapshot.size}`);

  // Check for orphaned fares (fares without matching routes)
  const routeIds = new Set();
  routesSnapshot.forEach(doc => {
    const data = doc.data();
    if (data.route_id) routeIds.add(data.route_id);
  });

  let orphaned = 0;
  faresSnapshot.forEach(doc => {
    const data = doc.data();
    if (data.route_id && !routeIds.has(data.route_id)) {
      orphaned++;
    }
  });

  if (orphaned > 0) {
    console.log(`  ⚠️  Warning: ${orphaned} fares don't have matching routes`);
  } else {
    console.log(`  ✅ All fares have matching routes`);
  }
}

async function main() {
  console.log('🚍 MAT Kenya - Firebase Data Import');
  console.log('=' .repeat(50));

  try {
    const routesImported = await importRoutes();
    const faresImported = await importFares();
    await verifyImport();

    console.log('\n' + '='.repeat(50));
    console.log('✨ Import completed successfully!');
    console.log(`   Total: ${routesImported} routes, ${faresImported} fares added`);
    console.log('\n💡 Next steps:');
    console.log('   1. Rebuild the app: flutter build apk --release');
    console.log('   2. Test the app to see the imported routes');
    console.log('   3. Enable Google Maps APIs for map display');

  } catch (error) {
    console.error('\n❌ Import failed:', error);
    process.exit(1);
  } finally {
    // Cleanup
    await admin.app().delete();
  }
}

main();
