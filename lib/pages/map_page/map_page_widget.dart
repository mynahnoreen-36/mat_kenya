import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:math' show cos, sqrt, asin;
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'map_page_model.dart';
export 'map_page_model.dart';

class MapPageWidget extends StatefulWidget {
  const MapPageWidget({
    super.key,
    required this.selectedRouteName,
  });

  final String? selectedRouteName;

  static String routeName = 'MapPage';
  static String routePath = '/mapPage';

  @override
  State<MapPageWidget> createState() => _MapPageWidgetState();
}

class _MapPageWidgetState extends State<MapPageWidget> {
  late MapPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  Set<google_maps.Marker> _markers = {};
  Set<google_maps.Polyline> _polylines = {};
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchResults = false;
  List<Map<String, dynamic>> _searchResults = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MapPageModel());
    _requestLocationPermission();
  }

  // Request location permission at runtime
  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.status;

    if (status.isDenied) {
      // Request permission
      final result = await Permission.location.request();

      if (result.isDenied) {
        _showError('Location permission denied. Map features may not work properly.');
      } else if (result.isPermanentlyDenied) {
        _showError('Location permission permanently denied. Please enable it in app settings.');
      }
    } else if (status.isPermanentlyDenied) {
      _showError('Location permission denied. Go to Settings > Apps > MatKenya > Permissions to enable.');
    }
  }

  @override
  void dispose() {
    _model.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Decode polyline from Google Directions API
  List<google_maps.LatLng> _decodePolyline(String encoded) {
    List<google_maps.LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(google_maps.LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  // Show error message to user
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: FlutterFlowTheme.of(context).error,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Get route polyline from Google Directions API
  Future<void> _drawRouteBetweenPoints() async {
    if (_model.originLocation == null || _model.destinationLocation == null) return;

    try {
      final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY_ANDROID'] ?? '';
      if (apiKey.isEmpty) {
        _showError('Maps API key not configured');
        return;
      }

      final origin = '${_model.originLocation!.latitude},${_model.originLocation!.longitude}';
      final destination = '${_model.destinationLocation!.latitude},${_model.destinationLocation!.longitude}';
      final url = 'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$apiKey';

      final response = await http.get(Uri.parse(url)).timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final polylinePoints = route['overview_polyline']['points'];
          final decodedPoints = _decodePolyline(polylinePoints);

          setState(() {
            _polylines.add(google_maps.Polyline(
              polylineId: google_maps.PolylineId('route'),
              points: decodedPoints,
              color: FlutterFlowTheme.of(context).primary,
              width: 5,
              patterns: [google_maps.PatternItem.dash(20), google_maps.PatternItem.gap(10)],
            ));
          });
        } else if (data['status'] == 'ZERO_RESULTS') {
          _showError('No route found between these locations');
        } else if (data['status'] == 'OVER_QUERY_LIMIT') {
          _showError('API quota exceeded. Please try again later');
        } else if (data['status'] == 'REQUEST_DENIED') {
          _showError('Maps API request denied. Check API key');
        } else {
          _showError('Cannot find route: ${data['status']}');
        }
      } else {
        _showError('Network error. Please check your connection');
      }
    } on TimeoutException {
      _showError('Request timeout. Please try again');
    } catch (e) {
      debugPrint('Directions API error: $e');
      _showError('Failed to load route. Please try again');
    }
  }

  // Search for locations using Google Places Autocomplete (with debouncing)
  Future<void> _searchLocations(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      setState(() {
        _showSearchResults = false;
        _searchResults = [];
      });
      return;
    }

    // Debounce: wait 500ms after user stops typing before making API call
    _debounce = Timer(Duration(milliseconds: 500), () async {
      try {
        final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY_ANDROID'] ?? '';
        if (apiKey.isEmpty) {
          _showError('Maps API key not configured');
          return;
        }

        // Focus on Kenya with location bias
        final url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&components=country:ke&key=$apiKey';

        final response = await http.get(Uri.parse(url)).timeout(Duration(seconds: 10));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'OK' && data['predictions'] != null) {
            setState(() {
              _searchResults = List<Map<String, dynamic>>.from(
                data['predictions'].map((prediction) => {
                  'description': prediction['description'],
                  'place_id': prediction['place_id'],
                })
              );
              _showSearchResults = true;
            });
          } else if (data['status'] == 'ZERO_RESULTS') {
            setState(() {
              _searchResults = [];
              _showSearchResults = true;
            });
          } else if (data['status'] == 'OVER_QUERY_LIMIT') {
            _showError('Search quota exceeded. Please try again later');
          } else if (data['status'] == 'REQUEST_DENIED') {
            _showError('Search not available. Check API key');
          }
        } else {
          _showError('Network error during search');
        }
      } on TimeoutException {
        _showError('Search timeout. Please try again');
      } catch (e) {
        debugPrint('Places API error: $e');
        _showError('Search failed. Please try again');
      }
    });
  }

  // Get coordinates from place ID
  Future<LatLng?> _getPlaceCoordinates(String placeId) async {
    try {
      final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY_ANDROID'] ?? '';
      final url = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry&key=$apiKey';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final location = data['result']['geometry']['location'];
          return LatLng(location['lat'], location['lng']);
        }
      }
    } catch (e) {
      debugPrint('Place details error: $e');
    }
    return null;
  }

  // Reverse geocode to get place name from coordinates
  Future<String> _getPlaceName(LatLng position) async {
    try {
      final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY_ANDROID'] ?? '';
      final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          // Get the formatted address or locality
          String address = data['results'][0]['formatted_address'] ?? '';
          // Try to get a shorter name (locality or neighborhood)
          for (var component in data['results'][0]['address_components']) {
            if (component['types'].contains('locality') ||
                component['types'].contains('sublocality') ||
                component['types'].contains('neighborhood')) {
              return component['long_name'];
            }
          }
          // Return first part of address if no locality found
          return address.split(',')[0];
        }
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }
    return '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
  }

  // Calculate distance between two points in kilometers (Haversine formula)
  double _calculateDistance(LatLng point1, LatLng point2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 - cos((point2.latitude - point1.latitude) * p) / 2 +
        cos(point1.latitude * p) * cos(point2.latitude * p) *
        (1 - cos((point2.longitude - point1.longitude) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  // Check if current time is peak hours
  bool _isPeakHour() {
    final now = DateTime.now();
    final hour = now.hour;
    // Peak hours: 7-9 AM and 5-7 PM
    return (hour >= 7 && hour < 9) || (hour >= 17 && hour < 19);
  }

  // Calculate fare with peak hour multiplier
  double _calculateFare(FaresRecord? fare) {
    if (fare == null) return 0;
    double baseFare = fare.standardFare.toDouble();
    if (_isPeakHour()) {
      return baseFare * (fare.peakMultiplier ?? 1.0);
    }
    return baseFare;
  }

  // Get color for peak hour indicator
  Color _getPeakHourColor() {
    if (_isPeakHour()) {
      return Color(0xFFFF5722); // Red for peak hours
    }
    final now = DateTime.now();
    final hour = now.hour;
    // Yellow for near-peak hours (6-7 AM, 9-10 AM, 4-5 PM, 7-8 PM)
    if ((hour >= 6 && hour < 7) || (hour >= 9 && hour < 10) ||
        (hour >= 16 && hour < 17) || (hour >= 19 && hour < 20)) {
      return Color(0xFFFFC107); // Yellow
    }
    return Color(0xFF4CAF50); // Green for off-peak
  }

  // Handle map tap to select origin or destination
  Future<void> _handleMapTap(LatLng position) async {
    if (_model.selectingOrigin) {
      _model.originLocation = position;
      _model.originName = 'Loading...';
      setState(() {});

      // Add origin marker
      _markers.add(google_maps.Marker(
        markerId: google_maps.MarkerId('origin'),
        position: google_maps.LatLng(position.latitude, position.longitude),
        icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(google_maps.BitmapDescriptor.hueGreen),
        infoWindow: google_maps.InfoWindow(title: 'Origin'),
      ));

      // Get place name
      _model.originName = await _getPlaceName(position);
      setState(() {});
    } else {
      _model.destinationLocation = position;
      _model.destinationName = 'Loading...';
      setState(() {});

      // Add destination marker
      _markers.add(google_maps.Marker(
        markerId: google_maps.MarkerId('destination'),
        position: google_maps.LatLng(position.latitude, position.longitude),
        icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(google_maps.BitmapDescriptor.hueRed),
        infoWindow: google_maps.InfoWindow(title: 'Destination'),
      ));

      // Get place name
      _model.destinationName = await _getPlaceName(position);
      setState(() {});

      // Draw route polyline between origin and destination
      await _drawRouteBetweenPoints();

      // Query routes when both locations are selected
      if (_model.originLocation != null) {
        await _findMatchingRoutes();
      }
    }
  }

  // Find routes that match the selected locations
  Future<void> _findMatchingRoutes() async {
    setState(() {
      _model.isLoadingRoutes = true;
    });

    try {
      // Query all verified routes
      final routesSnapshot = await queryRoutesRecord(
        queryBuilder: (routesRecord) => routesRecord.where(
          'is_verified',
          isEqualTo: true,
        ),
      ).first;

      // Filter routes by proximity (within 50km of selected points)
      // This is a simple implementation - in production you'd use geohashing
      final filteredRoutes = <RoutesRecord>[];
      const maxDistance = 50.0; // km

      for (var route in routesSnapshot) {
        // For now, we'll use the route's origin/destination strings
        // In a real app, you'd have lat/lng for each route
        // Since we don't have exact coordinates for routes, we'll show all
        // but sort by relevance based on name matching
        filteredRoutes.add(route);
      }

      // Sort routes by name matching with selected locations
      filteredRoutes.sort((a, b) {
        final aOrigin = a.origin.toLowerCase();
        final aDestination = a.destination.toLowerCase();
        final bOrigin = b.origin.toLowerCase();
        final bDestination = b.destination.toLowerCase();
        final originName = _model.originName?.toLowerCase() ?? '';
        final destName = _model.destinationName?.toLowerCase() ?? '';

        // Score based on name similarity
        int aScore = 0;
        int bScore = 0;

        if (aOrigin.contains(originName) || originName.contains(aOrigin)) aScore += 10;
        if (aDestination.contains(destName) || destName.contains(aDestination)) aScore += 10;
        if (bOrigin.contains(originName) || originName.contains(bOrigin)) bScore += 10;
        if (bDestination.contains(destName) || destName.contains(bDestination)) bScore += 10;

        return bScore.compareTo(aScore);
      });

      setState(() {
        _model.matchingRoutes = filteredRoutes;
        _model.isLoadingRoutes = false;
      });

      // Load fare data for all routes in batches (Firestore whereIn limit is 10)
      _model.routeFares.clear();
      final routeIds = _model.matchingRoutes.map((route) => route.routeId).toList();

      // Process in chunks of 10 due to Firestore whereIn limitation
      for (var i = 0; i < routeIds.length; i += 10) {
        final chunk = routeIds.skip(i).take(10).toList();

        final faresSnapshot = await queryFaresRecord(
          queryBuilder: (faresRecord) => faresRecord.where(
            'route_id',
            whereIn: chunk,
          ),
        ).first;

        // Map fares to route IDs
        for (var fare in faresSnapshot) {
          _model.routeFares[fare.routeId] = fare;
        }
      }

      setState(() {});
    } catch (e) {
      debugPrint('Error finding routes: $e');
      setState(() {
        _model.isLoadingRoutes = false;
      });
    }
  }

  // Build route result card
  Widget _buildRouteCard(RoutesRecord route) {
    final fare = _model.routeFares[route.routeId];
    final routeNumber = route.routeId.replaceAll('route_', '').replaceAll('_', ' ').toUpperCase();
    final stageCount = route.stages.split(',').length;
    final isPeak = _isPeakHour();
    final currentFare = _calculateFare(fare);
    final peakColor = _getPeakHourColor();

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () async {
          // Navigate to fares page
          context.pushNamed(
            FaresPageWidget.routeName,
            queryParameters: {
              'routeID': serializeParam(route.routeId, ParamType.String),
            }.withoutNulls,
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Route number badge
              Container(
                width: 50.0,
                height: 50.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    routeNumber.length > 5 ? routeNumber.substring(0, 5) : routeNumber,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: routeNumber.length > 3 ? 12.0 : 16.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(width: 16.0),
              // Route details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${route.origin} → ${route.destination}',
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                        font: GoogleFonts.inter(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14.0, color: FlutterFlowTheme.of(context).secondaryText),
                        SizedBox(width: 4.0),
                        Text(
                          '$stageCount stages',
                          style: FlutterFlowTheme.of(context).bodySmall,
                        ),
                        if (fare != null) ...[
                          SizedBox(width: 12.0),
                          Icon(Icons.money, size: 14.0, color: peakColor),
                          SizedBox(width: 4.0),
                          Text(
                            'Ksh ${currentFare.toStringAsFixed(0)}',
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                              font: GoogleFonts.inter(),
                              color: peakColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    // Peak hour indicator
                    if (fare != null && isPeak)
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: Color(0xFFFF5722).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.0),
                            border: Border.all(color: Color(0xFFFF5722), width: 1.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.trending_up, size: 12.0, color: Color(0xFFFF5722)),
                              SizedBox(width: 4.0),
                              Text(
                                'Peak Hours: +${((fare.peakMultiplier ?? 1.0 - 1.0) * 100).toStringAsFixed(0)}%',
                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                  font: GoogleFonts.inter(),
                                  color: Color(0xFFFF5722),
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: FlutterFlowTheme.of(context).secondaryText),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: const Color(0xFF202224),
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () async {
              context.safePop();
            },
          ),
          title: Text(
            'Route Finder',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              font: GoogleFonts.interTight(),
              color: Colors.white,
              fontSize: 22.0,
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 4.0, 0.0),
              child: FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 30.0,
                borderWidth: 1.0,
                buttonSize: 44.0,
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 24.0,
                ),
                onPressed: () {
                  setState(() {
                    _showSearchResults = !_showSearchResults;
                  });
                },
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 0.0),
              child: FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 30.0,
                borderWidth: 1.0,
                buttonSize: 44.0,
                icon: Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: 24.0,
                ),
                onPressed: () {
                  setState(() {
                    _model.clearSelections();
                    _markers.clear();
                    _polylines.clear();
                    _searchController.clear();
                    _showSearchResults = false;
                  });
                },
              ),
            ),
          ],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: Stack(
          children: [
            // Google Map (using native widget for tap support)
            google_maps.GoogleMap(
              onMapCreated: (controller) {
                if (!_model.googleMapsController.isCompleted) {
                  _model.googleMapsController.complete(controller);
                }
              },
              onCameraIdle: () {
                // Update center if needed
              },
              initialCameraPosition: google_maps.CameraPosition(
                target: google_maps.LatLng(-0.3031, 36.08),
                zoom: 12.0,
              ),
              markers: _markers,
              polylines: _polylines,  // Add polylines to map
              mapType: google_maps.MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              compassEnabled: true,
              mapToolbarEnabled: false,
              trafficEnabled: false,
              onTap: (google_maps.LatLng position) {
                _handleMapTap(LatLng(position.latitude, position.longitude));
              },
            ),

            // Search bar overlay
            if (_showSearchResults)
              Positioned(
                top: 16.0,
                left: 16.0,
                right: 16.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8.0,
                        color: Color(0x1A000000),
                        offset: Offset(0.0, 2.0),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Search input
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: _model.selectingOrigin ? 'Search origin...' : 'Search destination...',
                          prefixIcon: Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _showSearchResults = false;
                                _searchResults = [];
                              });
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16.0),
                        ),
                        onChanged: (value) {
                          _searchLocations(value);
                        },
                      ),
                      // Search results
                      if (_searchResults.isNotEmpty)
                        Container(
                          constraints: BoxConstraints(maxHeight: 300),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final result = _searchResults[index];
                              return ListTile(
                                leading: Icon(Icons.location_on),
                                title: Text(
                                  result['description'],
                                  style: FlutterFlowTheme.of(context).bodyMedium,
                                ),
                                onTap: () async {
                                  final coords = await _getPlaceCoordinates(result['place_id']);
                                  if (coords != null) {
                                    await _handleMapTap(coords);
                                    setState(() {
                                      _showSearchResults = false;
                                      _searchController.clear();
                                    });
                                  }
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            // Selection mode indicator
            if (!_showSearchResults)
            Positioned(
              top: 16.0,
              left: 16.0,
              right: 16.0,
              child: Container(
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 4.0,
                      color: Color(0x1A000000),
                      offset: Offset(0.0, 2.0),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _model.selectingOrigin ? 'Step 1: Tap on map to select ORIGIN' : 'Step 2: Tap on map to select DESTINATION',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    if (_model.originLocation != null)
                      Row(
                        children: [
                          Icon(Icons.trip_origin, size: 16.0, color: Colors.green),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              'Origin: ${_model.originName ?? "Not set"}',
                              style: FlutterFlowTheme.of(context).bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    if (_model.destinationLocation != null)
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16.0, color: Colors.red),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              'Destination: ${_model.destinationName ?? "Not set"}',
                              style: FlutterFlowTheme.of(context).bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    if (_model.originLocation != null && _model.destinationLocation == null)
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                        child: FFButtonWidget(
                          onPressed: () {
                            setState(() {
                              _model.toggleSelectionMode();
                            });
                          },
                          text: 'Next: Select Destination',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 36.0,
                            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context).labelMedium.override(
                              font: GoogleFonts.inter(),
                              color: Colors.white,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Bottom sheet with route results
            if (_model.matchingRoutes.isNotEmpty)
              DraggableScrollableSheet(
                initialChildSize: 0.3,
                minChildSize: 0.15,
                maxChildSize: 0.7,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10.0,
                          color: Color(0x1A000000),
                          offset: Offset(0.0, -2.0),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Handle bar
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 12.0),
                          width: 40.0,
                          height: 4.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).alternate,
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                        // Header
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Available Routes (${_model.matchingRoutes.length})',
                                style: FlutterFlowTheme.of(context).headlineSmall,
                              ),
                              Text(
                                'Tap to view details',
                                style: FlutterFlowTheme.of(context).bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Divider(),
                        // Routes list
                        Expanded(
                          child: _model.isLoadingRoutes
                              ? Center(child: CircularProgressIndicator())
                              : ListView.builder(
                                  controller: scrollController,
                                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                                  itemCount: _model.matchingRoutes.length,
                                  itemBuilder: (context, index) {
                                    return _buildRouteCard(_model.matchingRoutes[index]);
                                  },
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
