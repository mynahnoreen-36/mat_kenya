# MAT Kenya Data Import Scripts

This directory contains scripts to generate and import mock data to Firebase Firestore.

## Quick Start

### 1. Generate Mock Data
```bash
cd scripts
python3 generate_mock_data.py
```

This creates:
- `mock_data/routes.json` - 5 Nairobi matatu routes
- `mock_data/fares.json` - Corresponding fare data

### 2. Import to Firestore

**Prerequisites:**
- Download Firebase service account key from [Firebase Console](https://console.firebase.google.com/)
- Project: `matkenya-a1926`
- Path: Project Settings → Service Accounts → Generate New Private Key
- Save as: `scripts/serviceAccountKey.json`

**Run Import:**
```bash
cd scripts
npm install
npm run import
```

The script will:
- ✅ Import routes to `Routes` collection
- ✅ Import fares to `Fares` collection
- ✅ Skip duplicates (safe to run multiple times)
- ✅ Verify data integrity

## Mock Data Overview

### Routes (5 total)
- CBD → Westlands (via Nairobi Hospital, Chiromo)
- CBD → Karen (via Yaya Centre, Adams Arcade)
- CBD → Ngong (via Dagoretti, Uthiru, Karen)
- CBD → Thika (via Roysambu, Kasarani, Ruiru)
- CBD → Embakasi (via Donholm, Umoja, Buruburu)

### Fares
- Standard fares: Ksh 50-150
- Peak multipliers: 1.2x - 1.5x
- Peak hours: 07:00 - 09:00

## Data Structure

### Routes Collection
```json
{
  "route_id": "route_1",
  "origin": "CBD",
  "destination": "Westlands",
  "stages": "CBD,Nairobi Hospital,Chiromo,Westlands",
  "is_verified": true
}
```

### Fares Collection
```json
{
  "route_id": "route_1",
  "standard_fare": 149,
  "peak_multiplier": 1.36,
  "peak_hours_starts": "07:00",
  "peak_hours_end": "09:00"
}
```

## Troubleshooting

### "Firebase service account credentials not found"
- Ensure `serviceAccountKey.json` exists in `scripts/` directory
- File should contain valid JSON with private_key and client_email

### "Mock data files not found"
- Run `python3 generate_mock_data.py` first

### Permission Errors
- Ensure your Firebase service account has Firestore write permissions
- Check Firebase Console → Firestore → Rules

## Security Note

**⚠️ NEVER commit `serviceAccountKey.json` to git!**

The `.gitignore` file already excludes this file for safety.
