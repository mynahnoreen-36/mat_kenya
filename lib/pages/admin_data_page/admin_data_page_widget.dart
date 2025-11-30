import '/backend/backend.dart';
import '/backend/admin_utils.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_data_page_model.dart';
export 'admin_data_page_model.dart';

class AdminDataPageWidget extends StatefulWidget {
  const AdminDataPageWidget({super.key});

  static String routeName = 'AdminDataPage';
  static String routePath = '/adminDataPage';

  @override
  State<AdminDataPageWidget> createState() => _AdminDataPageWidgetState();
}

class _AdminDataPageWidgetState extends State<AdminDataPageWidget> {
  late AdminDataPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminDataPageModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Mock data for routes - Updated with real Kenyan city stages (19 routes)
  final List<Map<String, dynamic>> _mockRoutes = [
    {
      "route_id": "route_1",
      "origin": "Nairobi CBD",
      "destination": "Westlands",
      "stages": "Nairobi CBD,Uhuru Highway,Museum Hill,Parklands,Sarit Centre,Westlands",
      "is_verified": true
    },
    {
      "route_id": "route_2",
      "origin": "Nairobi CBD",
      "destination": "Karen",
      "stages": "Nairobi CBD,Nyayo Stadium,Yaya Centre,Adams Arcade,Hardy,Karen",
      "is_verified": true
    },
    {
      "route_id": "route_3",
      "origin": "Nairobi CBD",
      "destination": "Ngong",
      "stages": "Nairobi CBD,Nyayo Stadium,Dagoretti Corner,Riruta,Uthiru,Karen Junction,Ngong",
      "is_verified": true
    },
    {
      "route_id": "route_4",
      "origin": "Nairobi CBD",
      "destination": "Thika",
      "stages": "Nairobi CBD,Pangani,Roysambu,Kasarani,Mwiki,Githurai 45,Ruiru,Thika",
      "is_verified": true
    },
    {
      "route_id": "route_5",
      "origin": "Nairobi CBD",
      "destination": "Embakasi",
      "stages": "Nairobi CBD,Makongeni,Kaloleni,Jericho,Donholm,Umoja,Buruburu,Embakasi",
      "is_verified": true
    },
    {
      "route_id": "route_6",
      "origin": "Mombasa Town",
      "destination": "Nyali",
      "stages": "Mombasa Town,Kizingo,Nyali Bridge,Nyali Cinemax,City Mall,Nyali",
      "is_verified": true
    },
    {
      "route_id": "route_7",
      "origin": "Mombasa Town",
      "destination": "Likoni",
      "stages": "Mombasa Town,Likoni Ferry,Shelly Beach,Tiwi Junction,Likoni",
      "is_verified": true
    },
    {
      "route_id": "route_8",
      "origin": "Mombasa Town",
      "destination": "Bamburi",
      "stages": "Mombasa Town,Mwembe Tayari,Nyali,Kongowea,Bamburi Mtambo,Bamburi",
      "is_verified": true
    },
    {
      "route_id": "route_9",
      "origin": "Nyali",
      "destination": "Bamburi",
      "stages": "Nyali,Nyali Bridge,Reef Hotel,Mamba Village,Bombolulu,Bamburi",
      "is_verified": true
    },
    {
      "route_id": "route_10",
      "origin": "Nakuru Town",
      "destination": "Free Area",
      "stages": "Nakuru Town,Kenyatta Avenue,Stadium,Pangani,Kivumbini,Free Area",
      "is_verified": true
    },
    {
      "route_id": "route_11",
      "origin": "Nakuru Town",
      "destination": "Lanet",
      "stages": "Nakuru Town,Kenyatta Avenue,London,Milimani,Lanet Barracks,Lanet",
      "is_verified": true
    },
    {
      "route_id": "route_12",
      "origin": "Nakuru Town",
      "destination": "Section 58",
      "stages": "Nakuru Town,Kenyatta Avenue,Flamingo,Mwariki,Section 7,Section 58",
      "is_verified": true
    },
    {
      "route_id": "route_13",
      "origin": "Eldoret Town",
      "destination": "Langas",
      "stages": "Eldoret Town,Rupa's Mall,Kapsoya,Huruma,Langas Estate,Langas",
      "is_verified": true
    },
    {
      "route_id": "route_14",
      "origin": "Eldoret Town",
      "destination": "Pioneer",
      "stages": "Eldoret Town,Uganda Road,Kipkaren,West Indies,Pioneer Estate,Pioneer",
      "is_verified": true
    },
    {
      "route_id": "route_15",
      "origin": "Eldoret Town",
      "destination": "Elgon View",
      "stages": "Eldoret Town,Oginga Odinga Street,Race Course,Kapseret,Elgon View Estate,Elgon View",
      "is_verified": true
    },
    {
      "route_id": "route_16",
      "origin": "Kisumu Town",
      "destination": "Kondele",
      "stages": "Kisumu Town,Kibuye Market,Jubilee Market,Kondele Roundabout,Kondele",
      "is_verified": true
    },
    {
      "route_id": "route_17",
      "origin": "Kisumu Town",
      "destination": "Mamboleo",
      "stages": "Kisumu Town,Kibuye Market,Kondele,Nyamasaria,Mamboleo Estate,Mamboleo",
      "is_verified": true
    },
    {
      "route_id": "route_18",
      "origin": "Kisumu Town",
      "destination": "Manyatta",
      "stages": "Kisumu Town,Kibuye Market,Kondele,Railway Station,Manyatta Estate,Manyatta",
      "is_verified": true
    },
    {
      "route_id": "route_19",
      "origin": "Kondele",
      "destination": "Mamboleo",
      "stages": "Kondele,Kondele Roundabout,Nyamasaria,Migosi,Mamboleo Junction,Mamboleo",
      "is_verified": true
    },
  ];

  // Mock data for fares - Realistic 70-100 Ksh fares
  final List<Map<String, dynamic>> _mockFares = [
    {
      "route_id": "route_1",
      "standard_fare": 80,
      "peak_multiplier": 1.34,
      "peak_hours_starts": "07:00",
      "peak_hours_end": "09:00"
    },
    {
      "route_id": "route_2",
      "standard_fare": 80,
      "peak_multiplier": 1.28,
      "peak_hours_starts": "07:00",
      "peak_hours_end": "09:00"
    },
    {
      "route_id": "route_3",
      "standard_fare": 80,
      "peak_multiplier": 1.38,
      "peak_hours_starts": "07:00",
      "peak_hours_end": "09:00"
    },
    {
      "route_id": "route_4",
      "standard_fare": 100,
      "peak_multiplier": 1.45,
      "peak_hours_starts": "07:00",
      "peak_hours_end": "09:00"
    },
    {
      "route_id": "route_5",
      "standard_fare": 100,
      "peak_multiplier": 1.23,
      "peak_hours_starts": "07:00",
      "peak_hours_end": "09:00"
    },
    {
      "route_id": "route_6",
      "standard_fare": 80,
      "peak_multiplier": 1.2,
      "peak_hours_starts": "07:00",
      "peak_hours_end": "09:00"
    },
    {
      "route_id": "route_7",
      "standard_fare": 70,
      "peak_multiplier": 1.4,
      "peak_hours_starts": "07:00",
      "peak_hours_end": "09:00"
    },
    {
      "route_id": "route_8",
      "standard_fare": 80,
      "peak_multiplier": 1.38,
      "peak_hours_starts": "07:00",
      "peak_hours_end": "09:00"
    },
    {
      "route_id": "route_9",
      "standard_fare": 80,
      "peak_multiplier": 1.38,
      "peak_hours_starts": "07:00",
      "peak_hours_end": "09:00"
    },
    {
      "route_id": "route_10",
      "standard_fare": 80,
      "peak_multiplier": 1.4,
      "peak_hours_starts": "07:00",
      "peak_hours_end": "09:00"
    },
    {
      "route_id": "route_11",
      "standard_fare": 80,
      "peak_multiplier": 1.46,
      "peak_hours_starts": "07:00",
      "peak_hours_end": "09:00"
    },
    {
      "route_id": "route_12",
      "standard_fare": 80,
      "peak_multiplier": 1.23,
      "peak_hours_starts": "07:00",
      "peak_hours_end": "09:00"
    },
    {
      "route_id": "route_13",
      "standard_fare": 80,
      "peak_multiplier": 1.34,
      "peak_hours_starts": "07:00",
      "peak_hours_end": "09:00"
    },
    {
      "route_id": "route_14",
      "standard_fare": 80,
      "peak_multiplier": 1.35,
      "peak_hours_starts": "07:00",
      "peak_hours_end": "09:00"
    },
    {
      "route_id": "route_15",
      "standard_fare": 80,
      "peak_multiplier": 1.22,
      "peak_hours_starts": "07:00",
      "peak_hours_end": "09:00"
    },
    {
      "route_id": "route_16",
      "standard_fare": 70,
      "peak_multiplier": 1.45,
      "peak_hours_starts": "07:00",
      "peak_hours_end": "09:00"
    },
    {
      "route_id": "route_17",
      "standard_fare": 80,
      "peak_multiplier": 1.22,
      "peak_hours_starts": "07:00",
      "peak_hours_end": "09:00"
    },
    {
      "route_id": "route_18",
      "standard_fare": 80,
      "peak_multiplier": 1.45,
      "peak_hours_starts": "07:00",
      "peak_hours_end": "09:00"
    },
    {
      "route_id": "route_19",
      "standard_fare": 80,
      "peak_multiplier": 1.31,
      "peak_hours_starts": "07:00",
      "peak_hours_end": "09:00"
    },
  ];


  Future<void> _uploadMockData() async {
    // Check if user is admin
    final isAdmin = await AdminUtils.isCurrentUserAdmin();
    if (!isAdmin) {
      _showError('Only administrators can upload data');
      return;
    }

    setState(() {
      _model.isUploading = true;
      _model.uploadStatus = 'Starting upload...';
      _model.routesUploaded = 0;
      _model.faresUploaded = 0;
    });

    try {
      final db = FirebaseFirestore.instance;

      // Upload Routes
      setState(() {
        _model.uploadStatus = 'Uploading routes...';
      });

      for (final route in _mockRoutes) {
        try {
          // Check if route already exists
          final existing = await db
              .collection('Routes')
              .where('route_id', isEqualTo: route['route_id'])
              .limit(1)
              .get();

          if (existing.docs.isEmpty) {
            await db.collection('Routes').add(route);
            setState(() {
              _model.routesUploaded++;
              _model.uploadStatus =
                  'Uploaded route: ${route['route_id']} (${route['origin']} → ${route['destination']})';
            });
          } else {
            setState(() {
              _model.uploadStatus =
                  'Skipped route: ${route['route_id']} (already exists)';
            });
          }

          // Small delay to show progress
          await Future.delayed(Duration(milliseconds: 300));
        } catch (e) {
          debugPrint('Error uploading route ${route['route_id']}: $e');
        }
      }

      // Upload Fares
      setState(() {
        _model.uploadStatus = 'Uploading fares...';
      });

      for (final fare in _mockFares) {
        try {
          // Check if fare already exists
          final existing = await db
              .collection('Fares')
              .where('route_id', isEqualTo: fare['route_id'])
              .limit(1)
              .get();

          if (existing.docs.isEmpty) {
            await db.collection('Fares').add(fare);
            setState(() {
              _model.faresUploaded++;
              _model.uploadStatus =
                  'Uploaded fare: ${fare['route_id']} (Ksh ${fare['standard_fare']})';
            });
          } else {
            setState(() {
              _model.uploadStatus =
                  'Skipped fare: ${fare['route_id']} (already exists)';
            });
          }

          // Small delay to show progress
          await Future.delayed(Duration(milliseconds: 300));
        } catch (e) {
          debugPrint('Error uploading fare ${fare['route_id']}: $e');
        }
      }

      setState(() {
        _model.uploadStatus =
            'Upload complete! Routes: ${_model.routesUploaded}, Fares: ${_model.faresUploaded}';
        _model.isUploading = false;
      });

      _showSuccess(
          'Successfully uploaded ${_model.routesUploaded} routes and ${_model.faresUploaded} fares');
    } catch (e) {
      debugPrint('Upload error: $e');
      setState(() {
        _model.uploadStatus = 'Upload failed: $e';
        _model.isUploading = false;
      });
      _showError('Upload failed. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: FlutterFlowTheme.of(context).error,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFF4CAF50),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AdminUtils.isCurrentUserAdmin(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.data!) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            appBar: AppBar(
              title: Text('Access Denied'),
              backgroundColor: FlutterFlowTheme.of(context).error,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.block, size: 80, color: FlutterFlowTheme.of(context).error),
                  SizedBox(height: 20),
                  Text(
                    'Administrator Access Required',
                    style: FlutterFlowTheme.of(context).headlineSmall,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Only administrators can access this page',
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  ),
                  SizedBox(height: 30),
                  FFButtonWidget(
                    onPressed: () => context.pushNamed(HomePageWidget.routeName),
                    text: 'Go to Home',
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
                  context.pushNamed(HomePageWidget.routeName);
                },
              ),
              title: Text(
                'Admin Data Management',
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
                padding: EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Card
                    Card(
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.admin_panel_settings,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 32.0,
                                ),
                                SizedBox(width: 12.0),
                                Text(
                                  'Mock Data Upload',
                                  style: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .override(
                                        font: GoogleFonts.interTight(),
                                      ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.0),
                            Text(
                              'Upload sample route and fare data to Firestore for testing.',
                              style: FlutterFlowTheme.of(context).bodyMedium,
                            ),
                            SizedBox(height: 12.0),
                            Divider(),
                            SizedBox(height: 12.0),
                            Row(
                              children: [
                                Icon(Icons.route,
                                    size: 20.0,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText),
                                SizedBox(width: 8.0),
                                Text(
                                  '19 Routes: Nairobi, Mombasa, Nakuru, Eldoret, Kisumu',
                                  style:
                                      FlutterFlowTheme.of(context).bodySmall,
                                ),
                              ],
                            ),
                            SizedBox(height: 8.0),
                            Row(
                              children: [
                                Icon(Icons.attach_money,
                                    size: 20.0,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText),
                                SizedBox(width: 8.0),
                                Text(
                                  '19 Fares: Ksh 70-100 with peak pricing',
                                  style:
                                      FlutterFlowTheme.of(context).bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24.0),

                    // Upload Button
                    FFButtonWidget(
                      onPressed: _model.isUploading ? null : _uploadMockData,
                      text: _model.isUploading
                          ? 'Uploading...'
                          : 'Upload Mock Data',
                      icon: Icon(
                        _model.isUploading
                            ? Icons.hourglass_empty
                            : Icons.cloud_upload,
                        size: 20.0,
                      ),
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 50.0,
                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                        color: FlutterFlowTheme.of(context).primary,
                        textStyle: FlutterFlowTheme.of(context)
                            .titleSmall
                            .override(
                              font: GoogleFonts.interTight(),
                              color: Colors.white,
                            ),
                        elevation: 3.0,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    SizedBox(height: 24.0),

                    // Progress Card
                    if (_model.uploadStatus.isNotEmpty)
                      Card(
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (_model.isUploading)
                                    SizedBox(
                                      width: 20.0,
                                      height: 20.0,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          FlutterFlowTheme.of(context).primary,
                                        ),
                                      ),
                                    ),
                                  if (!_model.isUploading)
                                    Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF4CAF50),
                                      size: 20.0,
                                    ),
                                  SizedBox(width: 12.0),
                                  Expanded(
                                    child: Text(
                                      _model.uploadStatus,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                              if (_model.routesUploaded > 0 ||
                                  _model.faresUploaded > 0) ...[
                                SizedBox(height: 16.0),
                                Divider(),
                                SizedBox(height: 12.0),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          '${_model.routesUploaded}',
                                          style: FlutterFlowTheme.of(context)
                                              .headlineMedium
                                              .override(
                                                font: GoogleFonts.interTight(),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                              ),
                                        ),
                                        Text(
                                          'Routes',
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall,
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          '${_model.faresUploaded}',
                                          style: FlutterFlowTheme.of(context)
                                              .headlineMedium
                                              .override(
                                                font: GoogleFonts.interTight(),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                              ),
                                        ),
                                        Text(
                                          'Fares',
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 24.0),

                    // Data Preview
                    Text(
                      'Data Preview',
                      style: FlutterFlowTheme.of(context).headlineSmall,
                    ),
                    SizedBox(height: 12.0),
                    ...List.generate(_mockRoutes.length, (index) {
                      final route = _mockRoutes[index];
                      final fare = _mockFares[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12.0),
                        elevation: 1.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(
                            color: FlutterFlowTheme.of(context).alternate,
                            width: 1.0,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${route['origin']} → ${route['destination']}',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyLarge
                                        .override(
                                          font: GoogleFonts.inter(),
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Text(
                                    'Ksh ${fare['standard_fare']}',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(),
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                'Stages: ${route['stages']}',
                                style:
                                    FlutterFlowTheme.of(context).bodySmall,
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                'Peak: ${fare['peak_hours_starts']}-${fare['peak_hours_end']} (${fare['peak_multiplier']}x)',
                                style: FlutterFlowTheme.of(context)
                                    .bodySmall
                                    .override(
                                      font: GoogleFonts.inter(),
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
