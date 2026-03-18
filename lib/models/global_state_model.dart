import 'package:flutter/material.dart';

class GlobalStateModel extends ChangeNotifier {
  bool _working = false;

  bool get working => _working;
  void setWorking(bool val) {
    _working = val;
    notifyListeners();
  }
}