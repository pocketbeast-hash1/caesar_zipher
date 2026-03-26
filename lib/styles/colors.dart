import 'package:flutter/material.dart';

abstract class GlobalColors {
  static Color softGray = const Color.fromARGB(255, 197, 197, 197);

  static Color goodBackground = Colors.greenAccent;
  static Color badBackground = const Color.fromARGB(255, 251, 134, 134);
  static Color warnBackground = const Color.fromARGB(255, 247, 253, 180);
  static Color normalBackground = const Color.fromARGB(255, 180, 228, 253);
  static Color boxBackground = const Color.fromARGB(255, 229, 229, 229);

  static Color textColor = Colors.black;
  static Color goodTextColor = const Color.fromARGB(255, 26, 134, 81);
  static Color normalTextColor = const Color.fromARGB(255, 198, 198, 52);
  static Color badTextColor = const Color.fromARGB(255, 167, 54, 54);
}