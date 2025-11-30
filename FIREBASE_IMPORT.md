# Firebase Data Import Guide

This guide explains how to import the generated mock routes and fares into your Firebase Firestore database.

## Quick Summary

You have **5 mock routes** with matching fares generated in:
- `scripts/mock_data/routes.json`
- `scripts/mock_data/fares.json`

Choose one of the methods below to import them.

---

## Method 1: Automated Import (Node.js) - RECOMMENDED

### Prerequisites
- Node.js installed (check: `node --version`)
- Firebase service account key

### Step 1: Get Firebase Service Account Key

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: **matkenya-a1926**
3. Click the gear icon ⚙️ → **Project settings**
4. Go to **Service accounts** tab
5. Click **Generate new private key**
6. Download the JSON file
7. Save it as: `scripts/serviceAccountKey.json`

⚠️ **IMPORTANT:** Never commit this file to git! It's already in `.gitignore`.

### Step 2: Install Dependencies

```bash
cd scripts
npm install
```

### Step 3: Run Import Script

```bash
npm run import
```

Or directly:

```bash
node import_to_firebase.js
```

### Expected Output

```
🚍 MAT Kenya - Firebase Data Import
==================================================
✅ Using local service account key

📍 Importing routes...
  ✅ Added: route_1 (CBD → Westlands)
  ✅ Added: route_2 (CBD → Karen)
  ✅ Added: route_3 (CBD → Ngong)
  ✅ Added: route_4 (CBD → Thika)
  ✅ Added: route_5 (CBD → Embakasi)

📊 Routes: 5 imported, 0 skipped

💰 Importing fares...
  ✅ Added: route_1 (Ksh 149)
  ✅ Added: route_2 (Ksh 112)
  ✅ Added: route_3 (Ksh 87)
  ✅ Added: route_4 (Ksh 134)
  ✅ Added: route_5 (Ksh 95)

📊 Fares: 5 imported, 0 skipped

🔍 Verifying import...
  Routes in database: 5
  Fares in database: 5
  ✅ All fares have matching routes

==================================================
✨ Import completed successfully!
   Total: 5 routes, 5 fares added
```

---

## Method 2: Manual Import (Firebase Console)

### For Routes Collection

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select project: **matkenya-a1926**
3. Navigate to **Firestore Database**
4. Click on **Routes** collection (or create it)
5. Click **Add document**
6. For each route in `scripts/mock_data/routes.json`:

#### Route 1: CBD → Westlands
```
Document ID: (Auto-generated)

Fields:
- route_id (string): route_1
- origin (string): CBD
- destination (string): Westlands
- stages (string): CBD,Nairobi Hospital,Chiromo,Westlands
- is_verified (boolean): true
```

#### Route 2: CBD → Karen
```
Document ID: (Auto-generated)

Fields:
- route_id (string): route_2
- origin (string): CBD
- destination (string): Karen
- stages (string): CBD,Yaya Centre,Adams Arcade,Karen
- is_verified (boolean): true
```

#### Route 3: CBD → Ngong
```
Document ID: (Auto-generated)

Fields:
- route_id (string): route_3
- origin (string): CBD
- destination (string): Ngong
- stages (string): CBD,Dagoretti,Uthiru,Karen,Ngong
- is_verified (boolean): true
```

#### Route 4: CBD → Thika
```
Document ID: (Auto-generated)

Fields:
- route_id (string): route_4
- origin (string): CBD
- destination (string): Thika
- stages (string): CBD,Roysambu,Kasarani,Ruiru,Thika
- is_verified (boolean): true
```

#### Route 5: CBD → Embakasi
```
Document ID: (Auto-generated)

Fields:
- route_id (string): route_5
- origin (string): CBD
- destination (string): Embakasi
- stages (string): CBD,Donholm,Umoja,Buruburu,Embakasi
- is_verified (boolean): true
```

### For Fares Collection

1. Click on **Fares** collection (or create it)
2. Click **Add document**
3. For each fare in `scripts/mock_data/fares.json`:

**Example Fare for route_1:**
```
Document ID: (Auto-generated)

Fields:
- route_id (string): route_1
- standard_fare (number): 149
- peak_multiplier (number): 1.36
- peak_hours_starts (string): 07:00
- peak_hours_end (string): 09:00
```

**Note:** The exact values for `standard_fare` and `peak_multiplier` will vary as they're randomly generated. Copy from your actual `scripts/mock_data/fares.json` file.

---

## Method 3: Firebase CLI Import

### Prerequisites
```bash
npm install -g firebase-tools
firebase login
```

### Import Command
```bash
firebase firestore:import scripts/mock_data/
```

---

## Verification

After importing, verify the data:

### 1. Check Firebase Console
- Navigate to Firestore Database
- Verify **5 documents** in Routes collection
- Verify **5 documents** in Fares collection

### 2. Check in App
1. Build and install the app:
   ```bash
   flutter build apk --release
   ```

2. Open the app → **Routes Page**
3. You should see 5 routes listed:
   - CBD → Westlands
   - CBD → Karen
   - CBD → Ngong
   - CBD → Thika
   - CBD → Embakasi

4. Tap any route to see its fare details

### 3. Test Map Functionality
1. Go to **Map Page**
2. Tap two points on the map
3. Routes matching those locations should appear

---

## Troubleshooting

### "Error: Firebase service account credentials not found"
- Make sure you downloaded the service account key
- Save it as `scripts/serviceAccountKey.json`
- Verify the file exists: `ls scripts/serviceAccountKey.json`

### "Routes already exist" messages
- The script skips existing routes to avoid duplicates
- This is normal if you run the import multiple times

### No routes showing in app
1. Verify data is in Firestore (check Firebase Console)
2. Check app is querying correctly:
   - Open Routes Page
   - Look for loading indicator
   - Check for error messages
3. Verify route_id field names match:
   - Routes collection should have `route_id` field
   - Fares collection should have `route_id` field

### Firebase permission errors
- Check Firestore security rules allow read access
- For testing, you can temporarily set rules to:
  ```
  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      match /{document=**} {
        allow read: if true;
        allow write: if request.auth != null;
      }
    }
  }
  ```

---

## Adding More Routes

### Generate More Mock Data

Edit `scripts/generate_mock_data.py` and add more routes to the `REAL_ROUTES` list:

```python
REAL_ROUTES = [
    # Existing routes...

    # Add your custom routes here:
    ("Ngong", "Karen", ["Langata", "Nairobi West"]),
    ("Thika", "Ruiru", ["Juja", "Githurai"]),
    # etc...
]
```

Then regenerate:
```bash
python3 scripts/generate_mock_data.py
npm run import
```

---

## Next Steps

After importing data:

1. ✅ Rebuild app: `flutter build apk --release`
2. ✅ Test Routes Page - should show 5 routes
3. ✅ Test Map Page - tap points to find routes
4. ✅ Test Fares Page - tap route to see fare details
5. ⏭️ Enable Google Maps APIs (fix black map)
6. ⏭️ Implement Forgot Password feature

---

## Summary

**Quick command (automated):**
```bash
cd scripts
npm install
node import_to_firebase.js
```

**Files created:**
- ✅ `scripts/mock_data/routes.json` - 5 routes
- ✅ `scripts/mock_data/fares.json` - 5 fares
- ✅ `scripts/import_to_firebase.js` - Import script
- ✅ `scripts/package.json` - Dependencies

**What gets imported:**
- 5 verified routes covering major Nairobi destinations
- 5 matching fares with realistic pricing
- All routes use consistent `route_id` for proper matching

Happy routing! 🚍
