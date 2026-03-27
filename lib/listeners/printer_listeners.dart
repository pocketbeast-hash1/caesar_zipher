import 'package:caesar_zipher/facades/printer_facade.dart';
import 'package:caesar_zipher/facades/queue_facade.dart';
import 'package:caesar_zipher/main.dart';
import 'package:caesar_zipher/printer_client.dart';

abstract class PrinterListeners {
  static void onData(String data) {
    if (data == PrinterNotifications.printComplete.value &&
        globalState.working) {
      _handlePRC();
    } else if (data == PrinterNotifications.currentJobChanged.value &&
        globalState.working) {
      _handleJOB();
    }
  }

  static Future<void> _handlePRC() async {
    List<String> codes = globalState.codes;

    codes.removeAt(codes.length - 1);

    bool success = true;
    if (codes.isEmpty) {
      success = false;
    } else {
      String code = codes.last;
      success = await PrinterFacade.updateCode(code);
    }

    if (!success) {
      await PrinterFacade.setWorking(false);
      return;
    }

    await QueueFacade.loadQueue(codes);
  }

  static Future<void> _handleJOB() async {
    await PrinterFacade.updateGlobalCurrentGTIN();
  }
}
