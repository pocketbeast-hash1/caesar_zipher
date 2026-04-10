import 'dart:io';

import 'package:caesar_zipher/main.dart';
import 'package:caesar_zipher/utils/queue.dart';

abstract class QueueFacade {
  static Future<void> loadQueue(List<String> codes) async {
    await Queue.loadQueue(codes);
    globalState.setCodes(codes);
  }

  static Future<List<String>> getQueueFromFile(File file) async {
    List<String> codes = await Queue.getQueueFromFile(file);
    globalState.currentFile = file.path.split(r"\").lastOrNull ?? "";

    return codes;
  }
}
