import 'package:flutter/material.dart';
import '/utils/create_default_admin.dart';

/// Debug page to create the default admin user
/// This page should only be used during initial setup
class SetupAdminPage extends StatefulWidget {
  const SetupAdminPage({Key? key}) : super(key: key);

  @override
  State<SetupAdminPage> createState() => _SetupAdminPageState();
}

class _SetupAdminPageState extends State<SetupAdminPage> {
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

      setState(() {
        _isLoading = false;
        _success = success;
        if (success) {
          _message = 'Admin user created successfully!\n\n'
              'Email: ${CreateDefaultAdmin.defaultAdminEmail}\n'
              'Password: ${CreateDefaultAdmin.defaultAdminPassword}\n\n'
              'You can now log in with these credentials.';
        } else {
          _message = 'Failed to create admin user. Check the console for details.';
        }
      });

      // Optional: Sign out after creating admin
      if (success) {
        await Future.delayed(const Duration(seconds: 2));
        await CreateDefaultAdmin.signOut();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _success = false;
        _message = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Admin User'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.admin_panel_settings,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Create Default Admin',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'This will create an admin user with:\n'
                'Email: ${CreateDefaultAdmin.defaultAdminEmail}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Creating admin user...'),
                  ],
                )
              else if (_message.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _success ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _success ? Colors.green : Colors.red,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _success ? Icons.check_circle : Icons.error,
                        color: _success ? Colors.green : Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _success ? Colors.green.shade900 : Colors.red.shade900,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: _createAdmin,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Create Admin User'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              const SizedBox(height: 24),
              if (_message.isNotEmpty && _success)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Done'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
