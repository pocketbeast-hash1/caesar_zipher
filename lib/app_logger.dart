import "package:caesar_zipher/main.dart";
import "package:logger/logger.dart";

abstract class AppLogger {
  static Logger logger = Logger(
    filter: ReleaseFilter(),
    printer: SimplePrinter(printTime: true, colors: false),
    output: _StateOutput(),
  );
}

class ReleaseFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (globalState.debugMode) return true;
    return event.level > Level.debug;
  }
}

class _StateOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    globalState.addLogs(event.lines);
    if (globalState.debugMode) {
      for (var line in event.lines) {
        // ignore: avoid_print
        print(line);
      }
    }
  }
}
