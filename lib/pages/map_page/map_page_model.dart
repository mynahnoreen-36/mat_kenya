import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'map_page_widget.dart' show MapPageWidget;
import 'package:flutter/material.dart';

class MapPageModel extends FlutterFlowModel<MapPageWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for GoogleMap widget.
  LatLng? googleMapsCenter;
  final googleMapsController = Completer<GoogleMapController>();
  // State field(s) for PlacePicker widget.
  FFPlace placePickerValue = const FFPlace();

  // Route selection state
  LatLng? originLocation;
  String? originName;
  LatLng? destinationLocation;
  String? destinationName;
  bool selectingOrigin = true; // true = selecting origin, false = selecting destination
  List<RoutesRecord> matchingRoutes = [];
  Map<String, FaresRecord?> routeFares = {}; // Map routeID to fare data
  bool isLoadingRoutes = false;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  // Helper method to clear selections
  void clearSelections() {
    originLocation = null;
    originName = null;
    destinationLocation = null;
    destinationName = null;
    matchingRoutes = [];
    routeFares = {};
    selectingOrigin = true;
  }

  // Helper method to toggle selection mode
  void toggleSelectionMode() {
    selectingOrigin = !selectingOrigin;
  }
}
