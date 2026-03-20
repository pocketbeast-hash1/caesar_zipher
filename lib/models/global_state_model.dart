import 'package:flutter/material.dart';

class GlobalStateModel extends ChangeNotifier {
  bool _working = false;
  bool _printerConnected = false;

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
}