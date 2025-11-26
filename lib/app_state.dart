import 'package:flutter/material.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  String _selectedTime = '';
  String get selectedTime => _selectedTime;
  set selectedTime(String value) {
    _selectedTime = value;
    notifyListeners();
  }

  String _selectedTraffic = '';
  String get selectedTraffic => _selectedTraffic;
  set selectedTraffic(String value) {
    _selectedTraffic = value;
    notifyListeners();
  }

  String _selectedOrigin = '';
  String get selectedOrigin => _selectedOrigin;
  set selectedOrigin(String value) {
    _selectedOrigin = value;
    notifyListeners();
  }

  String _selectedDestination = '';
  String get selectedDestination => _selectedDestination;
  set selectedDestination(String value) {
    _selectedDestination = value;
    notifyListeners();
  }
}
