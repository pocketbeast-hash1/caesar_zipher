import 'package:caesar_zipher/facades/printer_facade.dart';
import 'package:caesar_zipher/main.dart';
import 'package:caesar_zipher/utils/queue.dart';

abstract class QueueFacade {
  static Future<void> loadQueue(List<String> codes) async {
    await PrinterFacade.setWorking(false);
    await Queue.loadQueue(codes);
    globalState.setCodes(codes);
  }
}
