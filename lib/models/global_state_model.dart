import 'package:caesar_zipher/utils/queue.dart';
import 'package:flutter/material.dart';

class GlobalStateModel extends ChangeNotifier {
  bool _working = false;
  bool _printerConnected = false;
  List<String> _codes = [];

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

  Future<void> _asyncInit() async {
    _codes = await Queue.getQueue();
    notifyListeners();
  }

  GlobalStateModel() {
    _asyncInit();
  }
}