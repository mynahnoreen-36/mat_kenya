# MAT Kenya App - Implementation Summary & Recommendations

**Date:** November 26, 2025
**Status:** Phase 1 & 2 Completed | Phase 3 (Map Implementation) Pending

---

## ✅ COMPLETED FIXES

### 1. Profile Page Back Button Fixed
**File:** `lib/pages/profile_page/profile_page_widget.dart`
**Issue:** Back button only had `debugPrint`, didn't navigate back
**Fix:** Added `context.safePop()` to properly navigate back to previous page

```dart
onPressed: () async {
  context.safePop();  // Now properly navigates back
},
```

### 2. Profile Page Navigation Added
**File:** `lib/pages/home_page/home_page_widget.dart`
**Issue:** No way to navigate to the profile page from anywhere in the app
**Fix:** Added profile icon button to HomePage app bar
- Person icon in top-right corner
- Navigates to ProfilePage on tap
- White color to match app bar design

```dart
IconButton(
  icon: Icon(Icons.person, color: Colors.white, size: 28.0),
  onPressed: () async {
    context.pushNamed(ProfilePageWidget.routeName);
  },
),
```

### 3. Estimate Fares Button Removed from HomePage
**File:** `lib/pages/home_page/home_page_widget.dart`
**Issue:** Button navigated to FaresPage with empty `routeID` parameter, causing crashes
**Fix:** Removed entire "Estimate Fare" button (lines 197-248)
**Reason:** Users should access fare information through the proper flow: HomePage → RoutesPage → FaresPage

### 4. FaresPage Crash Fixed
**File:** `lib/pages/fares_page/fares_page_widget.dart`
**Issue:** When no fare data existed, page returned empty `Container()`, causing blank screen
**Fix:** Added proper error handling UI with:
- Error icon and message
- "No fare information available" text
- "View Available Routes" button to navigate to RoutesPage
- Proper app bar with back navigation

**Result:** Users now see helpful error message instead of blank screen

### 5. Routes Page Redesigned
**File:** `lib/pages/routes_page/routes_page_widget.dart`
**Issue:** Basic list view with minimal information and no back button
**Fix:** Complete redesign with modern card-based UI

**New Features:**
- ✅ Back button in app bar for proper navigation
- ✅ Route number displayed in circular badge (extracted from routeid)
- ✅ Origin → Destination with arrow icon
- ✅ Stage count displayed (e.g., "5 stages")
- ✅ Verified badge for verified routes (green checkmark)
- ✅ Card-based design with shadows and borders
- ✅ Proper spacing and padding
- ✅ Chevron right indicator for tap affordance
- ✅ Responsive text with ellipsis for long names

**Design Follows Best Practices:**
- Citymapper-style card layout
- Clear visual hierarchy
- Easy-to-scan information
- Touch-friendly tap targets

### 6. Environment Variables Migration
**Files:** `pubspec.yaml`, `lib/main.dart`, `lib/backend/firebase/firebase_config.dart`, `.env`
**Completed:** Successfully migrated from hardcoded credentials to `.env` file
- Added `flutter_dotenv` package
- Firebase credentials now loaded from `.env` file
- Google Maps API keys added to `.env`
- `.env` file protected in `.gitignore`

### 7. Map Route Selection & Fare Calculator Implemented ⭐ NEW
**Files:** `lib/pages/map_page/map_page_widget.dart`, `lib/pages/map_page/map_page_model.dart`
**Issue:** Map had hardcoded query and no route selection functionality
**Fix:** Complete redesign with interactive route finding

**New Features:**
- ✅ **Interactive Map Selection:** Tap on map to select origin and destination
- ✅ **Step-by-Step UI:** Clear instructions guide users through 2-step process
- ✅ **Visual Markers:** Green marker for origin, red marker for destination
- ✅ **Automatic Route Query:** Queries Firebase for all verified routes when both locations selected
- ✅ **Fare Display:** Loads and displays fare information for each route
- ✅ **Draggable Bottom Sheet:** Shows matching routes in scrollable sheet (15%-70% height)
- ✅ **Route Cards:** Each card shows:
  - Route number in circular badge
  - Origin → Destination
  - Stage count
  - Standard fare (if available)
  - Tap to view full details on FaresPage
- ✅ **Refresh Button:** Clear selections and start over
- ✅ **Back Navigation:** Proper back button to return to HomePage
- ✅ **Loading States:** Shows spinner while querying routes
- ✅ **State Management:** Comprehensive model with origin, destination, routes, and fares

**User Flow:**
1. Tap "View Map" on HomePage
2. Tap on map to select origin (green marker appears)
3. Tap "Next: Select Destination" button
4. Tap on map to select destination (red marker appears)
5. Bottom sheet automatically slides up showing all available routes with fares
6. Tap any route card to view detailed fare information
7. Use refresh button to start over

**Technical Implementation:**
- Uses `google_maps_flutter` for native markers
- Queries Firestore for verified routes
- Loads fare data asynchronously for each route
- DraggableScrollableSheet for smooth UX
- Positioned widgets for overlay UI
- State management in MapPageModel

### 8. Quick Win Enhancements ⭐ NEW
**Files:** `lib/pages/map_page/map_page_widget.dart`
**Enhancements:** Three major UX improvements

#### A. Reverse Geocoding - Real Place Names
- **What:** Converts coordinates to readable addresses
- **How:** Uses Google Geocoding API
- **Result:**
  - Shows "Nairobi CBD" instead of "-1.2921, 36.8219"
  - Displays "Loading..." while fetching
  - Extracts locality/neighborhood names
  - Falls back to coordinates if geocoding fails
- **API:** `https://maps.googleapis.com/maps/api/geocode/json`

#### B. Peak Hour Indicators - Dynamic Pricing
- **What:** Real-time fare calculation with peak hour pricing
- **How:**
  - Checks current time against peak hours (7-9 AM, 5-7 PM)
  - Calculates fare with multiplier
  - Color-codes fares: 🟢 Green (off-peak), 🟡 Yellow (near-peak), 🔴 Red (peak)
- **Display:**
  - Fare amount changes based on time
  - Badge shows "Peak Hours: +30%" during peak times
  - Icon color matches pricing level
- **Peak Hours:** 7-9 AM and 5-7 PM (configurable per route)

#### C. Location-Based Filtering - Smart Route Sorting
- **What:** Sorts routes by relevance to selected locations
- **How:**
  - Compares route origin/destination with selected place names
  - Scores based on string matching
  - Shows most relevant routes first
- **Algorithm:**
  - +10 points if origin matches
  - +10 points if destination matches
  - Sorts by total score (higher = more relevant)
- **Future:** Can be enhanced with actual coordinate-based distance calculation

**User Experience Improvements:**
- ✅ Place names are immediately recognizable
- ✅ Users see exact current fare (not just base fare)
- ✅ Transparent about peak pricing with visual indicators
- ✅ Most relevant routes appear at top of list
- ✅ Loading states prevent confusion

---

## 📊 COMPREHENSIVE RESEARCH COMPLETED

Analyzed similar transportation apps:
- **Global:** Moovit (1.5B users), Google Maps Transit, Citymapper, Transit App
- **Kenyan:** Digital Matatus (MIT/UoN project), Swvl Kenya, Ma3Route (500K+ users)

### Key Findings:
1. **Route Selection:** Multiple input methods (search, map tap, GPS auto-detect)
2. **Fare Models:** Stage-based pricing works best for matatus (not pure distance-based)
3. **UI Pattern:** Card-based route comparison (Citymapper shows 6 routes vs competitors' 3)
4. **Real-time Data:** Crowd-sourcing works in Kenya (Ma3Route model proven successful)
5. **Peak Hours:** Color-coded indicators (green/yellow/red) for transparent pricing

---

## 🎯 7 KEY RECOMMENDATIONS (Based on Research)

### Recommendation 1: Multi-Input Route Selection
- Search bar with autocomplete
- Long-press/tap on map for origin/destination
- GPS auto-detect current location
- Recent locations quick-select

**Priority:** HIGH

### Recommendation 2: Stage-Based Fare Calculation
Replace current route-based fares with:
```
Fare = numberOfStages × farePerStage × peakMultiplier (if peak hours)
```
**Example Display:**
```
Route 46: Kayole → CBD
Regular Hours: Ksh 50-60
Peak Hours (7-9 AM, 5-7 PM): Ksh 70-80

Breakdown:
• 5 stages × Ksh 12 = Ksh 60
• Peak multiplier: 1.3x
```

**Priority:** HIGH

### Recommendation 3: Citymapper-Style Route Comparison
**Card Layout:**
```
┌─────────────────────────────┐
│ [Icon] Route 46 • Kayole    │
├─────────────────────────────┤
│ ⏱ 40 min  💰 Ksh 60        │
│ 🚶 5 min   📍 5 stages      │
├─────────────────────────────┤
│ [View Map] [Select] [★]     │
└─────────────────────────────┘
```

**Priority:** HIGH

### Recommendation 4: Crowd-Sourced Real-Time Data (Ma3Route Model)
Allow users to report:
- Current matatu fares paid
- Traffic conditions
- Route availability/closures
- Matatu waiting times at stages

**Priority:** MEDIUM (Phase 2)

### Recommendation 5: Color-Coded Peak Hour Indicators
- 🟢 **Green:** Off-peak hours (Ksh 50)
- 🟡 **Yellow:** Moderate traffic (Ksh 60)
- 🔴 **Red:** Peak hours (Ksh 80)

**Priority:** MEDIUM

### Recommendation 6: Offline-First Route Data
- Cache route definitions, stages, base fares locally
- Enable offline route planning
- Sync real-time updates when online
- Show "Last updated" timestamp

**Priority:** MEDIUM

### Recommendation 7: Interactive Route Map with Digital Matatus Style
- Color-coded route lines (Route 7 = Blue, Route 46 = Green)
- Numbered stage markers along routes
- Tap stage marker to see fare from current location
- Show multiple routes simultaneously with transparency
- Animated vehicle icons (if real-time data available)

**Priority:** HIGH

---

## 📋 PENDING TASKS

### Task 1: Redesign Find Routes Page ⏳
**Current State:** Basic list view with origin → destination
**Needed Improvements:**
1. Add route number/name prominently
2. Show estimated travel time
3. Display fare range (min-max)
4. Add quick filters (sort by: fastest, cheapest, fewest transfers)
5. Show "Popular Routes" section at top
6. Add search/filter functionality

**Suggested UI:**
```dart
Card(
  child: ListTile(
    leading: CircleAvatar(
      child: Text('46'), // Route number
    ),
    title: Text('Kayole → CBD'),
    subtitle: Row(
      children: [
        Icon(Icons.schedule),
        Text('40 min'),
        SizedBox(width: 16),
        Icon(Icons.money),
        Text('Ksh 50-60'),
      ],
    ),
    trailing: Icon(Icons.arrow_forward_ios),
  ),
)
```

### Task 2: Implement Map Route Selection with Fare Calculation 🗺️
**Required Implementation:**

#### A. Map Interaction
1. **Origin/Destination Selection:**
   ```dart
   void _handleMapTap(LatLng position) async {
     if (_selectingOrigin) {
       setState(() => _origin = position);
     } else if (_selectingDestination) {
       setState(() => _destination = position);
       await _calculateRoutes();
     }
   }
   ```

2. **Find Matching Routes:**
   - Query Routes collection where origin/destination are within radius
   - Use `geolocator` package for distance calculations
   - Match user-selected points to known stage locations

3. **Calculate Fares:**
   ```dart
   double calculateFare(RoutesRecord route, DateTime time) {
     double baseFare = route.numberOfStages * route.farePerStage;
     if (_isPeakHour(time)) {
       return baseFare * route.peakHourMultiplier;
     }
     return baseFare;
   }

   bool _isPeakHour(DateTime time) {
     int hour = time.hour;
     return (hour >= 7 && hour < 9) || (hour >= 17 && hour < 19);
   }
   ```

4. **Display on Map:**
   ```dart
   // Draw route polyline
   googleMapController.addPolyline(
     Polyline(
       polylineId: PolylineId(route.routeId),
       points: route.routePath,
       color: Colors.blue.withOpacity(0.7),
       width: 6,
     ),
   );

   // Add stage markers
   for (var i = 0; i < route.stages.length; i++) {
     googleMapController.addMarker(
       Marker(
         markerId: MarkerId('stage_$i'),
         position: route.stages[i].location,
         infoWindow: InfoWindow(
           title: route.stages[i].name,
           snippet: 'Fare: Ksh ${route.calculateFareFromStage(i)}',
         ),
       ),
     );
   }
   ```

#### B. Database Schema Updates Needed

**Add to RoutesRecord:**
```dart
class RoutesRecord {
  // Existing fields
  String origin;
  String destination;
  String routeid;
  bool isVerified;
  String stages;

  // NEW fields needed:
  int numberOfStages;           // Total number of stages
  double farePerStage;          // Ksh per stage
  double peakHourMultiplier;    // e.g., 1.3 for 30% increase
  List<String> peakHours;       // ["07:00-09:00", "17:00-19:00"]
  List<LatLng> routePath;       // Polyline points for map display
  String routeNumber;           // e.g., "46", "7"
  String routeName;             // e.g., "Kayole Express"
  String color;                 // Hex color for map (#FF0000)
  int estimatedDuration;        // Travel time in minutes
  List<StageData> stageDetails; // Detailed stage information
}

class StageData {
  String name;
  LatLng location;
  int stageNumber;
  double cumulativeFare;
}
```

**Migration Steps:**
1. Add new fields to Firestore `Routes` collection
2. Update existing routes with stage data
3. Calculate and store route polylines (from Google Directions API)
4. Assign colors to each route for map visualization

#### C. Google Maps API Integration
**APIs Needed:**
- **Directions API:** Get route polylines between points
- **Distance Matrix API:** Calculate travel times
- **Places API:** Location autocomplete (already integrated)

**Example Directions API Call:**
```dart
Future<List<LatLng>> getRoutePolyline(LatLng origin, LatLng destination) async {
  final request = http.get(Uri.parse(
    'https://maps.googleapis.com/maps/api/directions/json?'
    'origin=${origin.latitude},${origin.longitude}&'
    'destination=${destination.latitude},${destination.longitude}&'
    'key=$googleMapsApiKey'
  ));

  final response = await request;
  final decoded = json.decode(response.body);

  if (decoded['status'] == 'OK') {
    final points = decoded['routes'][0]['overview_polyline']['points'];
    return _decodePolyline(points);
  }

  return [];
}
```

### Task 3: Testing Checklist ✅
After implementing above tasks, test:
- [ ] Profile page back button works
- [ ] HomePage no longer has "Estimate Fare" button
- [ ] FaresPage shows error screen for invalid routes
- [ ] RoutesPage displays redesigned cards
- [ ] Map allows origin/destination selection
- [ ] Map displays matching routes
- [ ] Fare calculation works correctly
- [ ] Peak hour pricing displays properly
- [ ] App works offline with cached data
- [ ] All navigation flows work correctly

---

## 🏗️ IMPLEMENTATION ROADMAP

### Phase 1: Critical Fixes ✅ COMPLETED
- [x] Fix Profile page back button
- [x] Add navigation to Profile page
- [x] Remove Estimate Fares button
- [x] Fix FaresPage crash handling
- [x] Research best practices
- [x] Migrate to .env file

**Status:** ✅ All completed (November 26, 2025)

### Phase 2: UI Redesign ✅ COMPLETED
- [x] Redesign RoutesPage with card-based UI
- [x] Add route number/name display
- [x] Add back button to RoutesPage
- [x] Display stage count
- [x] Add verified badge
- [x] Implement modern card design with proper spacing

**Status:** ✅ All completed (November 26, 2025)

### Phase 3: Map Enhancements (2-3 weeks)
- [ ] Implement tap-to-select on map
- [ ] Add route polyline display
- [ ] Integrate Google Directions API
- [ ] Calculate and display fares on map
- [ ] Add stage markers
- [ ] Enable route comparison on map

**Estimated Time:** 2-3 weeks

### Phase 4: Advanced Features (3-4 weeks)
- [ ] Implement stage-based fare calculation
- [ ] Add peak hour indicators
- [ ] Enable crowd-sourced real-time updates
- [ ] Implement offline-first architecture
- [ ] Add route favorites and history

**Estimated Time:** 3-4 weeks

---

## 🗃️ DATABASE STRUCTURE

### Current Collections (4):

#### 1. Users
```
/Users/{userId}
- email: string
- uid: string
- display_name: string
- phone_number: string
- photo_url: string
- role: string
- created_time: timestamp
- updatedAt: timestamp
```

#### 2. Routes
```
/Routes/{routeId}
- origin: string
- destination: string
- routeid: string
- is_verified: bool
- stages: string
```

#### 3. Fares
```
/Fares/{fareId}
- route_id: string
- standard_fare: int
- peak_hours_start: string
- peak_hours_end: string
- peak_multiplier: int
```

#### 4. Admin
```
/Admin/{adminId}
- adminid: string
- email: string
- name: string
- role: string
```

### Recommended New Collections:

#### 5. Stages
```
/Stages/{stageId}
- stage_name: string
- location: geopoint
- routes: array<string>  // Route IDs passing through
- matatu_count: int      // Current matatus at stage
- waiting_time: int      // Minutes (crowd-sourced)
```

#### 6. RealtimeUpdates
```
/RealtimeUpdates/{updateId}
- route_id: string
- user_id: string
- update_type: string    // "fare", "traffic", "delay", "availability"
- reported_fare: double
- traffic_level: string  // "clear", "moderate", "heavy"
- timestamp: timestamp
- location: geopoint
- upvotes: int           // Community validation
```

---

## 📱 FIREBASE COLLECTIONS - RECOMMENDED STRUCTURE

### Enhanced Routes Collection
```json
{
  "routeid": "route_46",
  "routeNumber": "46",
  "routeName": "Kayole Express",
  "origin": "Kayole",
  "destination": "CBD",
  "is_verified": true,

  "numberOfStages": 5,
  "farePerStage": 12,
  "peakHourMultiplier": 1.3,
  "peakHours": ["07:00-09:00", "17:00-19:00"],

  "estimatedDuration": 40,
  "color": "#4285F4",

  "routePath": [
    {"latitude": -1.2921, "longitude": 36.8219},
    {"latitude": -1.2850, "longitude": 36.8180},
    ...
  ],

  "stages": [
    {
      "name": "Kayole Stage",
      "location": {"latitude": -1.2921, "longitude": 36.8219},
      "stageNumber": 1,
      "cumulativeFare": 0
    },
    {
      "name": "Donholm",
      "location": {"latitude": -1.2850, "longitude": 36.8180},
      "stageNumber": 2,
      "cumulativeFare": 12
    },
    ...
  ],

  "operatingHours": "05:00-23:00",
  "frequency": "5-10 minutes",
  "lastUpdated": "2025-11-26T10:00:00Z"
}
```

---

## 🔧 TECHNICAL STACK

**Current:**
- Flutter SDK
- Firebase (Firestore, Auth, Storage, Functions)
- Google Maps Flutter plugin
- Provider (state management)
- GoRouter (navigation)

**Recommended Additions:**
- `geolocator`: Distance/location calculations
- `google_polyline_algorithm`: Decode polylines from Directions API
- `http`: API calls to Google Maps services
- `shared_preferences`: Offline caching
- `connectivity_plus`: Check online/offline status

---

## 🎨 UI/UX IMPROVEMENTS SUMMARY

### Before → After

**HomePage:**
- ✅ Removed confusing "Estimate Fare" button
- ✅ Cleaner interface with 2 main actions

**ProfilePage:**
- ✅ Fixed non-functional back button
- ✅ Now properly navigates back

**FaresPage:**
- ✅ Handles missing data gracefully
- ✅ Shows helpful error messages
- ✅ Guides users to correct flow

**RoutesPage (Pending):**
- ⏳ Will show route cards with fare ranges
- ⏳ Will display travel times
- ⏳ Will have filter/sort options

**MapPage (Pending):**
- ⏳ Will allow tap-to-select locations
- ⏳ Will calculate routes in real-time
- ⏳ Will display fares on map
- ⏳ Will show stage markers

---

## 📚 RESOURCES & REFERENCES

### Research Sources:
- Digital Matatus Project (MIT/UoN)
- Ma3Route App (500K+ Kenyan users)
- Moovit (1.5B global users)
- Citymapper UI patterns
- Google Maps Transit integration

### Documentation:
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase for Flutter](https://firebase.flutter.dev/)
- [Google Maps Platform](https://developers.google.com/maps)
- [GTFS Specification](https://developers.google.com/transit/gtfs)

---

## 🚀 NEXT STEPS

1. **Test Current Fixes:**
   - Run `flutter run` and test all fixed features
   - Verify no crashes on Profile/HomePage/FaresPage

2. **Database Updates:**
   - Add new fields to Routes collection
   - Populate sample route data with stages
   - Add route polylines

3. **UI Redesign:**
   - Implement new RoutesPage card design
   - Add route number/name display
   - Show fare ranges and travel times

4. **Map Implementation:**
   - Enable origin/destination selection
   - Integrate Google Directions API
   - Calculate and display fares
   - Show routes on map

---

## 📧 SUPPORT & MAINTENANCE

For questions or issues:
1. Check Flutter analyze output: `flutter analyze`
2. Review Firebase console for data issues
3. Check Google Maps API quotas
4. Test on physical device (not just emulator)

---

**Last Updated:** November 26, 2025
**Version:** 1.0.0+1
**Maintained By:** MAT Kenya Development Team
