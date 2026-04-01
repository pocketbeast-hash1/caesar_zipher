import 'package:caesar_zipher/facades/printer_facade.dart';
import 'package:caesar_zipher/facades/queue_facade.dart';
import 'package:caesar_zipher/main.dart';
import 'package:caesar_zipher/printer_client.dart';

abstract class PrinterListeners {
  static PrinterNotifications? getNotificationType(String data) {
    if (data == PrinterNotifications.printComplete.value) {
      return PrinterNotifications.printComplete;
    } else if (data.contains(RegExp(r"^JOB\|"))) {
      return PrinterNotifications.currentJobChanged;
    } else if (data.contains(RegExp(r"^STS\|\d\|$"))) {
      return PrinterNotifications.stateChange;
    }

    return null;
  }

  static void onData(String data) {
    PrinterNotifications? type = getNotificationType(data);
    if (type == PrinterNotifications.printComplete && globalState.working) {
      _handlePRC();
    } else if (type == PrinterNotifications.currentJobChanged) {
      _handleJOB();
    } else if (type == PrinterNotifications.stateChange) {
      List<String> parts = data.split("|");
      String strState = parts[1];
      int intState = int.parse(strState);
      _handleStateChange(PrinterStates.findByValue(intState));
    }
  }

  static Future<void> _handlePRC() async {
    List<String> codes = globalState.codes;

    codes.removeAt(codes.length - 1);

    if (codes.isNotEmpty) {
      String code = codes.last;
      await PrinterFacade.updateCode(code);
    } else {
      PrinterFacade.setWorking(false);
    }

    await QueueFacade.loadQueue(codes);
  }

  static Future<void> _handleJOB() async {
    await PrinterFacade.setWorking(false);
    await PrinterFacade.updateGlobalCurrentGTIN();
  }

  static void _handleStateChange(PrinterStates state) {
    bool val = state == PrinterStates.running;

    if (val) {
      List<String> codes = globalState.codes;
      String code = codes.last;
      PrinterFacade.updateCode(code);
    }

    globalState.setWorking(val);
  }
}
