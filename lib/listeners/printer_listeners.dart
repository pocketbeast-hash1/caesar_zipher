import 'package:caesar_zipher/app_logger.dart';
import 'package:caesar_zipher/telnet_client.dart';
import 'package:caesar_zipher/utils/queue.dart';
import 'package:caesar_zipher/utils/settings.dart';
import 'package:ctelnet/ctelnet.dart';

abstract class PrinterListeners {
  static Future<void> onData(Message data) async {
    try {
      if (data.text != "PRC") return;

      Settings settings = await Settings.getSettings();
      List<String> codes = await Queue.getQueue();
      codes.removeAt(codes.length - 1);

      String code = codes[codes.length - 1];

      Map<String, String> newFields = {settings.barcodeFieldName: code};
      await TelnetClient.updateJob(newFields);

      await Queue.loadQueue(codes);

    } catch (e, s) {
      AppLogger.logger.e("Ошибка при обработке данных с устройства: $e, $s");
    }
  }
}
