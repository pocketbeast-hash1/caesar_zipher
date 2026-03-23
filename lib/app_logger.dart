import "package:caesar_zipher/main.dart";
import "package:flutter/foundation.dart";
import "package:logger/logger.dart";

abstract class AppLogger {
  static Logger logger = Logger(
    printer: SimplePrinter(printTime: true, colors: false),
    output: _StateOutput(),
  );
}

class _StateOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    globalState.addLogs(event.lines);
    if (kDebugMode) {
      for (var line in event.lines) {
        print(line);
      }
    }
  }
}
