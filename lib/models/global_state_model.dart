import 'package:caesar_zipher/utils/queue.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalStateModel extends ChangeNotifier {
  String appVersion = "???";
  String currentGTIN = "";
  bool keepAliveProcessing = false;

  String _currentFile = "";
  bool _working = false;
  bool _printerConnected = false;
  List<String> _codes = [];

  final List<String> _logs = [];
  final int _logsMaxLength = 100;

  bool _debugMode = false;

  String get currentFile => _currentFile;
  set currentFile(String newVal) {
    _currentFile = newVal;

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("currentFile", _currentFile);
    });

    notifyListeners();
  }

  bool get working => _working;
  void setWorking(bool val) {
    _working = val;
    notifyListeners();
  }

  bool get printerConnected => _printerConnected;
  void setPrinterConnected(bool val) {
    _printerConnected = val;
    notifyListeners();
  }

  List<String> get codes => _codes;
  void setCodes(List<String> newCodes) {
    _codes = newCodes;
    notifyListeners();
  }

  List<String> get logs => _logs;
  void addLogs(List<String> newLogs) {
    while (_logs.length + newLogs.length > _logsMaxLength) {
      _logs.removeAt(0);
    }

    _logs.addAll(newLogs);
    notifyListeners();
  }

  bool get debugMode => _debugMode;
  set debugMode(bool val) {
    _debugMode = val;
    notifyListeners();
  }

  Future<void> _asyncInit() async {
    _codes = await Queue.getQueue();
    _currentFile =
        (await SharedPreferences.getInstance()).getString("currentFile") ?? "";

    notifyListeners();
  }

  GlobalStateModel() {
    _asyncInit();
  }
}
