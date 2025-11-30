# Google Maps Implementation - Issues & Fixes

## 🔍 Issues Found (Based on Google Cloud Documentation)

### 1. **CRITICAL: API Key Security Vulnerability**
**Issue**: Using web API key client-side for backend APIs
- **Location**: `lib/pages/map_page/map_page_widget.dart:93, 133, 160, 180`
- **Problem**:
  - Directions API, Places API, and Geocoding API are called directly from client with `GOOGLE_MAPS_API_KEY_WEB`
  - API key exposed in client code can be extracted and misused
  - Could lead to quota exhaustion and unexpected bills
- **Google's Recommendation**:
  - Use Cloud Functions or backend server for these API calls
  - Implement API key restrictions
  - Never expose server-side API keys in client code

**Fix Priority**: 🔴 HIGH - Security Risk

### 2. **Hardcoded API Key in Android Manifest**
**Issue**: API key hardcoded in `AndroidManifest.xml:61`
- **Problem**:
  ```xml
  <meta-data android:name="com.google.android.geo.API_KEY"
             android:value="AIzaSyA83l7vwVAGweMIzBDL6H728YHWwAMB-Zk"/>
  ```
  - If committed to public repo, key is exposed
  - Should use build-time environment variables
- **Fix**: Use Gradle properties or Flutter environment variables

**Fix Priority**: 🔴 HIGH - Security Risk

### 3. **Missing API Key Restrictions**
**Issue**: No verification that keys have proper restrictions
- **Required Restrictions**:
  - **Android Key** (`AIzaSyA83l7vwVAGweMIzBDL6H728YHWwAMB-Zk`):
    - Application restrictions: Android apps
    - Package name: `com.mycompany.matkenya`
    - SHA-1 certificate fingerprint
  - **iOS Key** (`AIzaSyCYgomyZ7m0LTNOdjPqA5nFMWBdklwY9x0`):
    - Application restrictions: iOS apps
    - Bundle identifier: `com.company.MatKenya`
  - **Web/Server Key**: Should NOT be used client-side for Directions/Places/Geocoding

**Fix Priority**: 🔴 HIGH - Security & Cost Management

### 4. **No Rate Limiting on Places Autocomplete**
**Issue**: API called on every keystroke
- **Location**: `map_page_widget.dart:652`
- **Problem**:
  ```dart
  onChanged: (value) {
    _searchLocations(value); // Called for EVERY character typed
  }
  ```
- **Cost Impact**:
  - Places Autocomplete: $2.83 per 1000 requests
  - Typing "Nairobi" = 7 API calls = $0.02 per search
  - 1000 searches/day = $20/day = $600/month
- **Google's Recommendation**: Implement debouncing (300-500ms delay)

**Fix Priority**: 🟡 MEDIUM - Cost Optimization

### 5. **Missing Error Handling**
**Issue**: API errors only logged, not shown to users
- **Location**: `map_page_widget.dart:118, 153, 172, 202`
- **Problem**:
  ```dart
  } catch (e) {
    debugPrint('Directions API error: $e');
    // No user notification!
  }
  ```
- **Missing Scenarios**:
  - Quota exceeded (OVER_QUERY_LIMIT)
  - Invalid API key (REQUEST_DENIED)
  - No results found (ZERO_RESULTS)
  - Network errors

**Fix Priority**: 🟡 MEDIUM - User Experience

### 6. **Location Permission Not Checked**
**Issue**: Enabling location without permission check
- **Location**: `map_page_widget.dart:602`
- **Problem**:
  ```dart
  myLocationEnabled: true, // No permission check!
  ```
- **Android Requirement**: Must request `ACCESS_FINE_LOCATION` at runtime
- **Best Practice**: Check permission before enabling, show rationale

**Fix Priority**: 🟡 MEDIUM - User Experience & Compliance

### 7. **No Caching of API Results**
**Issue**: Same API calls made repeatedly
- **Impact**:
  - Reverse geocoding same location multiple times
  - Re-fetching route directions
  - Places details for same place_id
- **Fix**: Implement LRU cache with TTL

**Fix Priority**: 🟢 LOW - Performance Optimization

### 8. **Inefficient Firestore Queries**
**Issue**: Query all routes then filter client-side
- **Location**: `map_page_widget.dart:302-341`
- **Problem**:
  ```dart
  final routesSnapshot = await queryRoutesRecord(
    queryBuilder: (routesRecord) => routesRecord.where(
      'is_verified', isEqualTo: true,
    ),
  ).first;
  // Then filters in-memory by name matching
  ```
- **Better Approach**:
  - Add geopoint field to routes
  - Use geohashing for location-based queries
  - Use Firestore full-text search or Algolia

**Fix Priority**: 🟢 LOW - Performance (Future Enhancement)

---

## ✅ Recommended Fixes

### Fix 1: Secure API Key Management
```yaml
# pubspec.yaml - Add secure storage
dependencies:
  flutter_secure_storage: ^9.0.0
```

### Fix 2: Move Backend APIs to Cloud Functions
Create Firebase Cloud Functions for:
- Directions API
- Places Autocomplete
- Places Details
- Geocoding API

### Fix 3: Add Debouncing to Search
```dart
Timer? _debounce;

void _searchLocations(String query) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  _debounce = Timer(Duration(milliseconds: 500), () async {
    // Make API call
  });
}
```

### Fix 4: Check Location Permissions
```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> _checkLocationPermission() async {
  final status = await Permission.location.request();
  if (status.isGranted) {
    // Enable location
  } else {
    // Show rationale
  }
}
```

### Fix 5: Add Error Handling
```dart
Future<void> _drawRouteBetweenPoints() async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        // Success
      } else {
        _showError('Cannot find route: ${data['status']}');
      }
    } else {
      _showError('Network error. Please try again.');
    }
  } catch (e) {
    _showError('Failed to load route. Check your connection.');
  }
}
```

### Fix 6: API Key Restrictions Checklist
1. Go to [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
2. For each API key:
   - ✅ Set application restrictions (Android/iOS/HTTP referrers)
   - ✅ Set API restrictions (only enable needed APIs)
   - ✅ Add bundle IDs / package names
   - ✅ Add SHA-1 fingerprints (Android)
   - ✅ Enable only required APIs:
     - Maps SDK for Android
     - Maps SDK for iOS
     - (Move others to backend)

---

## 📊 Current API Usage & Estimated Costs

### APIs Used
1. **Maps SDK for Android/iOS** (embedded map) - FREE
2. **Directions API** (line 96) - $5.00 per 1000 requests
3. **Places Autocomplete** (line 135) - $2.83 per 1000 requests
4. **Places Details** (line 161) - $17.00 per 1000 requests
5. **Geocoding API** (line 181) - $5.00 per 1000 requests

### Monthly Free Tier
- $200 free credit = ~40,000 Places Autocomplete requests
- After that: Pay per use

### Cost Projection (1000 active users, 10 searches/day)
- Autocomplete: 10,000 requests/day × $0.00283 = $28.30/day = $849/month
- Directions: 2,000 requests/day × $0.005 = $10/day = $300/month
- Places Details: 2,000 requests/day × $0.017 = $34/day = $1,020/month
- Geocoding: 4,000 requests/day × $0.005 = $20/day = $600/month

**Total: ~$2,769/month** (without caching/optimization)

With recommended fixes: **~$200/month** (within free tier)

---

## 🎯 Implementation Priority

### Phase 1: Security (Do Immediately)
- [ ] Set up API key restrictions in Google Cloud Console
- [ ] Remove hardcoded keys from AndroidManifest.xml
- [ ] Add proper environment variable handling

### Phase 2: Cost Optimization (Do This Week)
- [ ] Implement debouncing on autocomplete
- [ ] Add caching layer
- [ ] Add error handling with user feedback

### Phase 3: Best Practices (Do This Month)
- [ ] Move backend APIs to Cloud Functions
- [ ] Implement location permission checks
- [ ] Add geohashing for route queries

### Phase 4: Advanced (Future)
- [ ] Implement offline caching
- [ ] Add analytics tracking
- [ ] Optimize Firestore queries with geohashing
