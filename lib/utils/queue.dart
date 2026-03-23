import 'dart:io';
import 'package:path_provider/path_provider.dart';

abstract class Queue {
  static Future<String> get _localPath async {
    final directory = await getApplicationCacheDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/codes.txt');
  }

  static Future<void> loadQueue(List<String> codes) async {
    File file = await _localFile;
    if (!await file.exists()) {
      await file.create();
    }

    await file.writeAsString( codes.join("\n") );
  }

  static Future<List<String>> getQueue() async {
    File file = await _localFile;
    if (!await file.exists()) {
      return [];
    }

    String content = await file.readAsString();
    return content.split("\n");
  }
}
