# Google Maps API Setup Guide

Your map is showing black because the API credentials need to be properly configured. Follow these steps:

---

## Step 1: Get Your API Keys from Google Cloud Console

### 1.1 Go to Google Cloud Console
- Visit: https://console.cloud.google.com/
- Select project: **matkenya-a1926**

### 1.2 Navigate to Credentials
```
Left menu → APIs & Services → Credentials
```

### 1.3 Create or Configure API Keys

You need **3 separate API keys** (or 1 unrestricted key for testing):

#### Option A: One Unrestricted Key (Quick Testing)
1. Click **"+ CREATE CREDENTIALS"** → **"API key"**
2. Copy the key (e.g., `AIzaSyD...`)
3. Click on the key to edit
4. Set **Application restrictions** → **None**
5. Set **API restrictions** → **Don't restrict key**
6. Click **Save**

⚠️ **Security Warning:** Unrestricted keys should only be used for testing!

#### Option B: Separate Keys (Production)
Create 3 separate keys:

**Android API Key:**
- Application restrictions → **Android apps**
- Add restriction:
  - Package name: `com.mycompany.matkenya`
  - SHA-1: `87:FD:A4:38:2F:15:89:85:DF:1D:23:AE:09:FA:75:E6:57:FC:2B:10`
- API restrictions → Select these APIs:
  - Maps SDK for Android
  - Directions API
  - Places API
  - Geocoding API

**iOS API Key:**
- Application restrictions → **iOS apps**
- Add your bundle ID: `com.mycompany.matkenya`
- API restrictions → Select:
  - Maps SDK for iOS
  - Directions API
  - Places API
  - Geocoding API

**Web API Key:**
- Application restrictions → **HTTP referrers**
- API restrictions → Select:
  - Maps JavaScript API
  - Directions API
  - Places API
  - Geocoding API

---

## Step 2: Verify APIs are Enabled

Go to: **APIs & Services → Library**

Search and verify these are **ENABLED**:
- ✅ Maps SDK for Android
- ✅ Maps SDK for iOS
- ✅ Maps JavaScript API
- ✅ Directions API
- ✅ Places API
- ✅ Geocoding API

If any show "Enable" button, click it!

---

## Step 3: Update Your Project Files

### 3.1 Update .env file

**File:** `/home/Root/Desktop/projects/mat_kenya/.env`

Replace the API keys with your new ones:

```env
# Google Maps API Keys (Replace these with your actual keys)
GOOGLE_MAPS_API_KEY_IOS=YOUR_IOS_API_KEY_HERE
GOOGLE_MAPS_API_KEY_ANDROID=YOUR_ANDROID_API_KEY_HERE
GOOGLE_MAPS_API_KEY_WEB=YOUR_WEB_API_KEY_HERE

# Or use one unrestricted key for all platforms (testing only):
# GOOGLE_MAPS_API_KEY_IOS=AIzaSyD_YOUR_KEY_HERE
# GOOGLE_MAPS_API_KEY_ANDROID=AIzaSyD_YOUR_KEY_HERE
# GOOGLE_MAPS_API_KEY_WEB=AIzaSyD_YOUR_KEY_HERE
```

### 3.2 Update AndroidManifest.xml

**File:** `/home/Root/Desktop/projects/mat_kenya/android/app/src/main/AndroidManifest.xml`

The Android key should already be there at line 61. Verify it matches your Android API key:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ANDROID_API_KEY_HERE"/>
```

**Current value in your file:**
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyA83l7vwVAGweMIzBDL6H728YHWwAMB-Zk"/>
```

### 3.3 Update iOS Configuration (if building for iOS)

**File:** `ios/Runner/AppDelegate.swift`

Add this line in the `application` function:
```swift
GMSServices.provideAPIKey("YOUR_IOS_API_KEY_HERE")
```

---

## Step 4: Test Your Current Keys

Let's verify if your current keys work:

### Check Android Key Status

1. Go to: https://console.cloud.google.com/apis/credentials
2. Find key: `AIzaSyA83l7vwVAGweMIzBDL6H728YHWwAMB-Zk`
3. Click on it to see:
   - Is it enabled?
   - What restrictions does it have?
   - Which APIs is it allowed to use?

### Common Issues:

**Issue 1: Key is Restricted**
- Solution: Either add your SHA-1 fingerprint OR temporarily set to "None"

**Issue 2: Wrong APIs Selected**
- Solution: Under "API restrictions", select all Maps-related APIs

**Issue 3: Key is Disabled**
- Solution: Enable the key in Cloud Console

**Issue 4: Wrong Project**
- Solution: Make sure you're in project `matkenya-a1926`

---

## Step 5: Quick Fix for Testing

### Option 1: Remove Restrictions (Fast)

1. Go to your API key in Cloud Console
2. Set **Application restrictions** → **None**
3. Set **API restrictions** → **Don't restrict key**
4. Click **Save**
5. Wait 5 minutes for changes to propagate
6. Rebuild and test the app

### Option 2: Add SHA-1 Fingerprint

1. Go to your **Android API key**
2. Under **Application restrictions** → **Android apps**
3. Click **"Add an item"**
4. Enter:
   ```
   Package name: com.mycompany.matkenya
   SHA-1: 87:FD:A4:38:2F:15:89:85:DF:1D:23:AE:09:FA:75:E6:57:FC:2B:10
   ```
5. Click **Done** → **Save**
6. Wait 5 minutes
7. Rebuild and test

---

## Step 6: Rebuild and Test

```bash
cd /home/Root/Desktop/projects/mat_kenya
flutter clean
flutter build apk --release
```

Install the new APK and test:
1. Open the app
2. Navigate to **Map Page**
3. Map should now display correctly (not black)
4. Try tapping points on the map
5. Try the search feature

---

## Troubleshooting

### Map Still Black After Changes?

1. **Wait 5-10 minutes** - API key changes can take time to propagate

2. **Check Logs:**
   ```bash
   flutter run
   # Look for errors like:
   # - "API key not found"
   # - "This API project is not authorized"
   # - "BILLING_NOT_ENABLED"
   ```

3. **Verify Billing:**
   - Go to: https://console.cloud.google.com/billing
   - Make sure billing is enabled (Google Maps requires it)
   - Free tier: $200/month credit (plenty for testing)

4. **Check Package Name:**
   - In `android/app/build.gradle`, verify:
     ```gradle
     applicationId "com.mycompany.matkenya"
     ```

5. **Clean and Rebuild:**
   ```bash
   flutter clean
   rm -rf build/
   flutter pub get
   flutter build apk --release
   ```

### Still Having Issues?

**Debug with Android Studio:**
1. Open project in Android Studio
2. Run app
3. Check Logcat for errors
4. Look for "Google Maps" or "API key" errors

**Common Error Messages:**

❌ **"This API project is not authorized to use this API"**
→ Enable the API in Cloud Console → Library

❌ **"The provided API key is invalid"**
→ Check key is correct in AndroidManifest.xml and .env

❌ **"API key not found. Check that <meta-data android:name="com.google.android.geo.API_KEY""**
→ Add or fix the meta-data tag in AndroidManifest.xml

---

## Quick Checklist

Before testing, verify:

- [ ] Google Maps APIs are **enabled** in Cloud Console
- [ ] Billing is **enabled** (required for Maps API)
- [ ] API key has **no restrictions** OR has correct SHA-1
- [ ] API key is in **AndroidManifest.xml** line 61
- [ ] API key is in **.env** file
- [ ] Waited **5-10 minutes** after making changes
- [ ] App is **rebuilt** with new keys
- [ ] Internet permission is in AndroidManifest (already there)

---

## Your Current Setup

**Your Firebase Project:** matkenya-a1926

**Your Package Name:** com.mycompany.matkenya

**Your Debug SHA-1:**
```
87:FD:A4:38:2F:15:89:85:DF:1D:23:AE:09:FA:75:E6:57:FC:2B:10
```

**Your Current Android API Key:**
```
AIzaSyA83l7vwVAGweMIzBDL6H728YHWwAMB-Zk
```

**Next Step:** Go to Google Cloud Console and verify this key has:
1. No restrictions OR correct SHA-1 fingerprint
2. Maps SDK for Android enabled
3. All other Maps APIs enabled

---

## Summary

1. ✅ All APIs are activated (you confirmed this)
2. ⚠️ API key needs proper configuration
3. 🔧 Follow Step 5 "Quick Fix" above
4. ⏱️ Wait 5-10 minutes after changes
5. 🏗️ Rebuild the app
6. ✅ Map should work!

The most common issue is **API key restrictions**. Try removing all restrictions first for testing.
