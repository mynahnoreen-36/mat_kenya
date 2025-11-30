import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'fares_page_model.dart';
export 'fares_page_model.dart';

class FaresPageWidget extends StatefulWidget {
  const FaresPageWidget({
    super.key,
    required this.routeID,
  });

  final String? routeID;

  static String routeName = 'FaresPage';
  static String routePath = '/faresPage';

  @override
  State<FaresPageWidget> createState() => _FaresPageWidgetState();
}

class _FaresPageWidgetState extends State<FaresPageWidget> {
  late FaresPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  google_maps.GoogleMapController? _mapController;
  Set<google_maps.Marker> _markers = {};
  List<google_maps.LatLng> _stageCoordinates = [];
  bool _isLoadingMap = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FaresPageModel());
  }

  @override
  void dispose() {
    _model.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // Load stage coordinates from stored data (no API calls needed!)
  void _loadStageMarkers(String stages, List<LatLng> coordinates) {
    if (coordinates.isEmpty) {
      setState(() {
        _isLoadingMap = false;
      });
      return;
    }

    final stageList = stages.split(',').map((s) => s.trim()).toList();
    final googleCoordinates = <google_maps.LatLng>[];
    final markers = <google_maps.Marker>{};

    for (int i = 0; i < coordinates.length && i < stageList.length; i++) {
      final coord = google_maps.LatLng(coordinates[i].latitude, coordinates[i].longitude);
      googleCoordinates.add(coord);

      markers.add(google_maps.Marker(
        markerId: google_maps.MarkerId('stage_$i'),
        position: coord,
        icon: i == 0
            ? google_maps.BitmapDescriptor.defaultMarkerWithHue(google_maps.BitmapDescriptor.hueGreen)
            : i == stageList.length - 1
                ? google_maps.BitmapDescriptor.defaultMarkerWithHue(google_maps.BitmapDescriptor.hueRed)
                : google_maps.BitmapDescriptor.defaultMarkerWithHue(google_maps.BitmapDescriptor.hueBlue),
        infoWindow: google_maps.InfoWindow(
          title: stageList[i],
          snippet: i == 0 ? 'Origin' : i == stageList.length - 1 ? 'Destination' : 'Stage ${i + 1}',
        ),
      ));
    }

    setState(() {
      _stageCoordinates = googleCoordinates;
      _markers = markers;
      _isLoadingMap = false;
    });
  }

  // Check if currently peak hours
  bool _isPeakHour(String peakStart, String peakEnd) {
    try {
      final now = DateTime.now();
      final startParts = peakStart.split(':');
      final endParts = peakEnd.split(':');

      final startHour = int.parse(startParts[0]);
      final startMinute = int.parse(startParts[1]);
      final endHour = int.parse(endParts[0]);
      final endMinute = int.parse(endParts[1]);

      final currentMinutes = now.hour * 60 + now.minute;
      final startMinutes = startHour * 60 + startMinute;
      final endMinutes = endHour * 60 + endMinute;

      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FaresRecord>>(
      stream: queryFaresRecord(
        queryBuilder: (faresRecord) => faresRecord.where(
          'route_id',
          isEqualTo: widget.routeID,
        ),
        singleRecord: true,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }

        List<FaresRecord> faresPageFaresRecordList = snapshot.data!;

        if (snapshot.data!.isEmpty) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            appBar: AppBar(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              leading: FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 30.0,
                buttonSize: 60.0,
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 30.0,
                ),
                onPressed: () async {
                  context.pushNamed(RoutesPageWidget.routeName);
                },
              ),
              title: Text(
                'Route Not Found',
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(),
                  color: Colors.white,
                ),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: FlutterFlowTheme.of(context).error,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No fare information available',
                    style: FlutterFlowTheme.of(context).headlineSmall,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Please select a valid route',
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  ),
                  SizedBox(height: 30),
                  FFButtonWidget(
                    onPressed: () async {
                      context.pushNamed(RoutesPageWidget.routeName);
                    },
                    text: 'View Available Routes',
                    options: FFButtonOptions(
                      padding: EdgeInsetsDirectional.fromSTEB(24, 12, 24, 12),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        font: GoogleFonts.interTight(),
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final faresPageFaresRecord = faresPageFaresRecordList.first;

        return StreamBuilder<List<RoutesRecord>>(
          stream: queryRoutesRecord(
            queryBuilder: (routesRecord) => routesRecord.where(
              'route_id',
              isEqualTo: widget.routeID,
            ),
            singleRecord: true,
          ),
          builder: (context, routeSnapshot) {
            if (!routeSnapshot.hasData) {
              return Scaffold(
                backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final routeRecord = routeSnapshot.data!.isNotEmpty ? routeSnapshot.data!.first : null;

            // Load stage markers when route data is available (using stored coordinates - no API calls!)
            if (routeRecord != null && _markers.isEmpty && !_isLoadingMap) {
              _loadStageMarkers(routeRecord.stages, routeRecord.stagesCoordinates);
            }

            final isPeak = _isPeakHour(
              faresPageFaresRecord.peakHoursStarts,
              faresPageFaresRecord.peakHoursEnd,
            );
            final currentFare = isPeak
                ? (faresPageFaresRecord.standardFare * faresPageFaresRecord.peakMultiplier).round()
                : faresPageFaresRecord.standardFare;

            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: Scaffold(
                key: scaffoldKey,
                backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
                appBar: AppBar(
                  backgroundColor: FlutterFlowTheme.of(context).primary,
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
                      context.pushNamed(RoutesPageWidget.routeName);
                    },
                  ),
                  title: Text(
                    'Fare Details',
                    style: FlutterFlowTheme.of(context).headlineMedium.override(
                      font: GoogleFonts.interTight(),
                      color: Colors.white,
                      fontSize: 22.0,
                    ),
                  ),
                  centerTitle: false,
                  elevation: 2.0,
                ),
                body: SafeArea(
                  top: true,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Route Header Card
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                FlutterFlowTheme.of(context).primary,
                                FlutterFlowTheme.of(context).secondary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Origin → Destination
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'FROM',
                                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                            font: GoogleFonts.inter(),
                                            color: Colors.white70,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 4.0),
                                        Text(
                                          routeRecord?.origin ?? 'Origin',
                                          style: FlutterFlowTheme.of(context).headlineSmall.override(
                                            font: GoogleFonts.interTight(),
                                            color: Colors.white,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 32.0,
                                    ),
                                  ),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'TO',
                                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                            font: GoogleFonts.inter(),
                                            color: Colors.white70,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 4.0),
                                        Text(
                                          routeRecord?.destination ?? 'Destination',
                                          style: FlutterFlowTheme.of(context).headlineSmall.override(
                                            font: GoogleFonts.interTight(),
                                            color: Colors.white,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.right,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Current Fare Card
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(24.0),
                            decoration: BoxDecoration(
                              color: isPeak ? Color(0xFFFFEBEE) : Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 8.0,
                                  color: Color(0x1A000000),
                                  offset: Offset(0.0, 4.0),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (isPeak)
                                      Icon(Icons.trending_up, color: Color(0xFFD32F2F), size: 20.0),
                                    if (!isPeak)
                                      Icon(Icons.check_circle, color: Color(0xFF388E3C), size: 20.0),
                                    SizedBox(width: 8.0),
                                    Text(
                                      isPeak ? 'PEAK HOURS' : 'OFF-PEAK',
                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                        font: GoogleFonts.inter(),
                                        color: isPeak ? Color(0xFFD32F2F) : Color(0xFF388E3C),
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.0),
                                Text(
                                  'Current Fare',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(),
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  'KSh $currentFare',
                                  style: FlutterFlowTheme.of(context).displaySmall.override(
                                    font: GoogleFonts.interTight(),
                                    color: isPeak ? Color(0xFFD32F2F) : Color(0xFF388E3C),
                                    fontSize: 48.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (isPeak) ...[
                                  SizedBox(height: 8.0),
                                  Text(
                                    'Base fare: KSh ${faresPageFaresRecord.standardFare}',
                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.inter(),
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        // Fare Details Cards
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildInfoCard(
                                  context,
                                  'Base Fare',
                                  'KSh ${faresPageFaresRecord.standardFare}',
                                  Icons.attach_money,
                                  FlutterFlowTheme.of(context).primary,
                                ),
                              ),
                              SizedBox(width: 12.0),
                              Expanded(
                                child: _buildInfoCard(
                                  context,
                                  'Peak Multiplier',
                                  '${faresPageFaresRecord.peakMultiplier}x',
                                  Icons.trending_up,
                                  Color(0xFFFF5722),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16.0),

                        // Peak Hours Info
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 1.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.schedule, size: 20.0, color: FlutterFlowTheme.of(context).primary),
                                    SizedBox(width: 8.0),
                                    Text(
                                      'Peak Hours',
                                      style: FlutterFlowTheme.of(context).titleSmall.override(
                                        font: GoogleFonts.interTight(),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.0),
                                Text(
                                  '${faresPageFaresRecord.peakHoursStarts} - ${faresPageFaresRecord.peakHoursEnd}',
                                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                                    font: GoogleFonts.interTight(),
                                    color: FlutterFlowTheme.of(context).primary,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  'Fares increase by ${((faresPageFaresRecord.peakMultiplier - 1) * 100).toStringAsFixed(0)}% during peak hours',
                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.inter(),
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 24.0),

                        // Stage Map Section
                        if (routeRecord != null) ...[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Route Stages',
                              style: FlutterFlowTheme.of(context).titleLarge.override(
                                font: GoogleFonts.interTight(),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(height: 12.0),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              height: 300.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 8.0,
                                    color: Color(0x1A000000),
                                    offset: Offset(0.0, 4.0),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: _isLoadingMap
                                    ? Center(child: CircularProgressIndicator())
                                    : _stageCoordinates.isNotEmpty
                                        ? google_maps.GoogleMap(
                                            initialCameraPosition: google_maps.CameraPosition(
                                              target: _stageCoordinates.first,
                                              zoom: 11.0,
                                            ),
                                            markers: _markers,
                                            onMapCreated: (controller) {
                                              _mapController = controller;
                                              // Fit bounds to show all markers
                                              if (_stageCoordinates.length > 1) {
                                                double minLat = _stageCoordinates.first.latitude;
                                                double maxLat = _stageCoordinates.first.latitude;
                                                double minLng = _stageCoordinates.first.longitude;
                                                double maxLng = _stageCoordinates.first.longitude;

                                                for (var coord in _stageCoordinates) {
                                                  if (coord.latitude < minLat) minLat = coord.latitude;
                                                  if (coord.latitude > maxLat) maxLat = coord.latitude;
                                                  if (coord.longitude < minLng) minLng = coord.longitude;
                                                  if (coord.longitude > maxLng) maxLng = coord.longitude;
                                                }

                                                controller.animateCamera(
                                                  google_maps.CameraUpdate.newLatLngBounds(
                                                    google_maps.LatLngBounds(
                                                      southwest: google_maps.LatLng(minLat, minLng),
                                                      northeast: google_maps.LatLng(maxLat, maxLng),
                                                    ),
                                                    50.0,
                                                  ),
                                                );
                                              }
                                            },
                                          )
                                        : Center(
                                            child: Text(
                                              'Unable to load map',
                                              style: FlutterFlowTheme.of(context).bodyMedium,
                                            ),
                                          ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          // Stage List
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: _buildStagesList(context, routeRecord.stages),
                          ),
                        ],

                        SizedBox(height: 32.0),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.0),
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
        children: [
          Icon(icon, size: 28.0, color: color),
          SizedBox(height: 8.0),
          Text(
            title,
            style: FlutterFlowTheme.of(context).bodySmall.override(
              font: GoogleFonts.inter(),
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.0),
          Text(
            value,
            style: FlutterFlowTheme.of(context).titleMedium.override(
              font: GoogleFonts.interTight(),
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStagesList(BuildContext context, String stages) {
    final stageList = stages.split(',').map((s) => s.trim()).toList();

    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < stageList.length; i++) ...[
            Row(
              children: [
                Container(
                  width: 32.0,
                  height: 32.0,
                  decoration: BoxDecoration(
                    color: i == 0
                        ? Color(0xFF4CAF50)
                        : i == stageList.length - 1
                            ? Color(0xFFD32F2F)
                            : FlutterFlowTheme.of(context).primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.inter(),
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    stageList[i],
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(),
                      fontWeight: i == 0 || i == stageList.length - 1 ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            if (i < stageList.length - 1) ...[
              Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: Container(
                  width: 2.0,
                  height: 24.0,
                  color: FlutterFlowTheme.of(context).alternate,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
