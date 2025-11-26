import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/utils/create_default_admin.dart';
import 'package:flutter/material.dart';

class SetupAdminPageWidget extends StatefulWidget {
  const SetupAdminPageWidget({super.key});

  static const String routeName = 'SetupAdminPage';
  static const String routePath = '/setupAdmin';

  @override
  State<SetupAdminPageWidget> createState() => _SetupAdminPageWidgetState();
}

class _SetupAdminPageWidgetState extends State<SetupAdminPageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  String _message = '';
  bool _success = false;

  Future<void> _createAdmin() async {
    setState(() {
      _isLoading = true;
      _message = 'Creating admin user...';
      _success = false;
    });

    try {
      final success = await CreateDefaultAdmin.createAdmin();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _success = success;
          if (success) {
            _message = 'Admin user created successfully!\n\n'
                'Email: ${CreateDefaultAdmin.defaultAdminEmail}\n'
                'Password: ${CreateDefaultAdmin.defaultAdminPassword}\n\n'
                'You can now log in with these credentials.';
          } else {
            _message =
                'Failed to create admin user. Check the console for details.';
          }
        });
      }

      // Optional: Sign out after creating admin
      if (success) {
        await Future.delayed(const Duration(seconds: 2));
        await CreateDefaultAdmin.signOut();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _success = false;
          _message = 'Error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: true,
          title: Text(
            'Setup Admin User',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Inter Tight',
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                ),
          ),
          actions: const [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    color: FlutterFlowTheme.of(context).primary,
                    size: 80.0,
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 24.0, 0.0, 0.0),
                    child: Text(
                      'Create Default Admin',
                      style: FlutterFlowTheme.of(context).headlineLarge.override(
                            fontFamily: 'Inter Tight',
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 16.0, 0.0, 0.0),
                    child: Text(
                      'This will create an admin user with:\nEmail: ${CreateDefaultAdmin.defaultAdminEmail}',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily: 'Inter',
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 32.0, 0.0, 0.0),
                    child: _buildContent(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              FlutterFlowTheme.of(context).primary,
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            'Creating admin user...',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Inter',
                  letterSpacing: 0.0,
                ),
          ),
        ],
      );
    }

    if (_message.isNotEmpty) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: _success
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: _success
                    ? FlutterFlowTheme.of(context).success
                    : FlutterFlowTheme.of(context).error,
                width: 2.0,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _success ? Icons.check_circle : Icons.error,
                  color: _success
                      ? FlutterFlowTheme.of(context).success
                      : FlutterFlowTheme.of(context).error,
                  size: 48.0,
                ),
                const SizedBox(height: 8.0),
                Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        color: _success
                            ? const Color(0xFF1B5E20)
                            : const Color(0xFFB71C1C),
                        letterSpacing: 0.0,
                      ),
                ),
              ],
            ),
          ),
          if (_success) ...[
            const SizedBox(height: 24.0),
            FFButtonWidget(
              onPressed: () {
                context.safePop();
              },
              text: 'Done',
              options: FFButtonOptions(
                height: 40.0,
                padding: const EdgeInsetsDirectional.fromSTEB(
                    16.0, 0.0, 16.0, 0.0),
                iconPadding: const EdgeInsetsDirectional.fromSTEB(
                    0.0, 0.0, 0.0, 0.0),
                color: FlutterFlowTheme.of(context).primary,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      fontFamily: 'Inter Tight',
                      color: Colors.white,
                      letterSpacing: 0.0,
                    ),
                elevation: 0.0,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ],
        ],
      );
    }

    return FFButtonWidget(
      onPressed: _createAdmin,
      text: 'Create Admin User',
      icon: const Icon(
        Icons.person_add,
        size: 20.0,
      ),
      options: FFButtonOptions(
        height: 50.0,
        padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
        iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
        color: FlutterFlowTheme.of(context).primary,
        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
              fontFamily: 'Inter Tight',
              color: Colors.white,
              fontSize: 18.0,
              letterSpacing: 0.0,
            ),
        elevation: 3.0,
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}
