import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'routes_page_model.dart';
export 'routes_page_model.dart';

class RoutesPageWidget extends StatefulWidget {
  const RoutesPageWidget({super.key});

  static String routeName = 'RoutesPage';
  static String routePath = '/routesPage';

  @override
  State<RoutesPageWidget> createState() => _RoutesPageWidgetState();
}

class _RoutesPageWidgetState extends State<RoutesPageWidget> {
  late RoutesPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RoutesPageModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: const Color(0xFFC98BC5),
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () async {
              context.safePop();
            },
          ),
          title: Text(
            FFLocalizations.of(context).getText(
              'fz7q13ww' /* Available Routes */,
            ),
            style: FlutterFlowTheme.of(context).headlineSmall.override(
                  font: GoogleFonts.interTight(
                    fontWeight:
                        FlutterFlowTheme.of(context).headlineSmall.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineSmall.fontStyle,
                  ),
                  color: Colors.white,
                  letterSpacing: 0.0,
                  fontWeight:
                      FlutterFlowTheme.of(context).headlineSmall.fontWeight,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineSmall.fontStyle,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            StreamBuilder<List<RoutesRecord>>(
              stream: queryRoutesRecord(
                queryBuilder: (routesRecord) => routesRecord.where(
                  'is_verified',
                  isEqualTo: true,
                ),
              ),
              builder: (context, snapshot) {
                // Customize what your widget looks like when it's loading.
                if (!snapshot.hasData) {
                  return Center(
                    child: SizedBox(
                      width: 50.0,
                      height: 50.0,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                    ),
                  );
                }
                List<RoutesRecord> listViewRoutesRecordList = snapshot.data!;

                return Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: listViewRoutesRecordList.length,
                    itemBuilder: (context, listViewIndex) {
                      final listViewRoutesRecord =
                          listViewRoutesRecordList[listViewIndex];

                      // Extract route number from route_id (e.g., "route_46" -> "46")
                      String routeNumber = listViewRoutesRecord.routeId
                          .replaceAll('route_', '')
                          .replaceAll('_', ' ')
                          .toUpperCase();

                      // Count stages
                      int stageCount = listViewRoutesRecord.stages.split(',').length;

                      return Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            context.pushNamed(
                              FaresPageWidget.routeName,
                              queryParameters: {
                                'routeID': serializeParam(
                                  listViewRoutesRecord.routeId,
                                  ParamType.String,
                                ),
                              }.withoutNulls,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 3.0,
                                  color: Color(0x1A000000),
                                  offset: Offset(0.0, 1.0),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  // Route Number Circle
                                  Container(
                                    width: 56.0,
                                    height: 56.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context).primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        routeNumber.length > 6
                                            ? routeNumber.substring(0, 6)
                                            : routeNumber,
                                        style: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .override(
                                              font: GoogleFonts.interTight(),
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: routeNumber.length > 4 ? 14.0 : 18.0,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16.0),
                                  // Route Details
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Origin → Destination
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                listViewRoutesRecord.origin,
                                                style: FlutterFlowTheme.of(context)
                                                    .bodyLarge
                                                    .override(
                                                      font: GoogleFonts.inter(),
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 16.0,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                                              child: Icon(
                                                Icons.arrow_forward,
                                                size: 16.0,
                                                color: FlutterFlowTheme.of(context).secondaryText,
                                              ),
                                            ),
                                            Flexible(
                                              child: Text(
                                                listViewRoutesRecord.destination,
                                                style: FlutterFlowTheme.of(context)
                                                    .bodyLarge
                                                    .override(
                                                      font: GoogleFonts.inter(),
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 16.0,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.0),
                                        // Stages info
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: 16.0,
                                              color: FlutterFlowTheme.of(context).secondaryText,
                                            ),
                                            SizedBox(width: 4.0),
                                            Text(
                                              '$stageCount stages',
                                              style: FlutterFlowTheme.of(context)
                                                  .bodySmall
                                                  .override(
                                                    font: GoogleFonts.inter(),
                                                    color: FlutterFlowTheme.of(context).secondaryText,
                                                  ),
                                            ),
                                            SizedBox(width: 16.0),
                                            if (listViewRoutesRecord.isVerified)
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.verified,
                                                    size: 16.0,
                                                    color: Color(0xFF00C853),
                                                  ),
                                                  SizedBox(width: 4.0),
                                                  Text(
                                                    'Verified',
                                                    style: FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .override(
                                                          font: GoogleFonts.inter(),
                                                          color: Color(0xFF00C853),
                                                        ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Arrow indicator
                                  Icon(
                                    Icons.chevron_right,
                                    size: 24.0,
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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
