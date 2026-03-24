import 'package:caesar_zipher/app_logger.dart';
import 'package:caesar_zipher/facades/queue_facade.dart';
import 'package:caesar_zipher/main.dart';
import 'package:caesar_zipher/telnet_client.dart';
import 'package:ctelnet/ctelnet.dart';

abstract class PrinterListeners {
  static Future<void> onData(Message data) async {
    try {
      if (data.text != "PRC" || !globalState.working) return;

      List<String> codes = globalState.codes;
      
      codes.removeAt(codes.length - 1);
      String code = codes.last;

      Map<String, String> newFields = {TelnetClient.barcodeFieldName: code};
      await TelnetClient.updateJob(newFields);

      await QueueFacade.loadQueue(codes, globalState);

      if (codes.isEmpty) {
        globalState.setWorking(false);
      }

    } catch (e, s) {
      AppLogger.logger.e("Ошибка при обработке данных с устройства: $e, $s");
    }
  }
}
