import "dart:io";

import "package:caesar_zipher/main.dart";
import "package:logger/logger.dart";
import "package:path_provider/path_provider.dart";

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
    for (var line in event.lines) {
      _LogWriter.writeLog(line);
      if (globalState.debugMode) {
        // ignore: avoid_print
        print(line);
      }
    }
  }
}

abstract class _LogWriter {
  static Future<String> get _localPath async {
    final directory = await getApplicationCacheDirectory();
    return "${directory.path}/logs";
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/${DateTimeFormat.onlyDate(DateTime.now())}.txt');
  }

  static Future<void> _clearFolder() async {
    final String path = await _localPath;
    final Directory dir = Directory(path);

    final List<FileSystemEntity> entities = await dir.list().toList();
    entities.sort((a, b) => b.path.compareTo(a.path));

    while (entities.length > 5) {
      final FileSystemEntity lastFile = entities.last;
      
      entities.remove(lastFile);
      await lastFile.delete();
    }
  }

  static Future<void> writeLog(String log) async {
    final File file = await _localFile;

    if (!(await file.exists())) {
      await file.create(recursive: true);
    }

    await file.writeAsString("$log\n", mode: FileMode.append);
    await _clearFolder();
  }
}
