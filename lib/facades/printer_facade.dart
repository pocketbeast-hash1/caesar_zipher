import 'package:caesar_zipher/app_logger.dart';
import 'package:caesar_zipher/main.dart';
import 'package:caesar_zipher/printer_client.dart';
import 'package:caesar_zipher/utils/codes_validator.dart';

abstract class PrinterFacade {
  static Future<void> connect(
    PrinterConfig config, {
    OnDataTriggerCallback? onDataTrigger,
  }) async {
    await PrinterClient.connect(config, onDataTrigger: onDataTrigger);
    await updateGlobalCurrentGTIN();

    globalState.setPrinterConnected(true);

    PrinterClient.enablePrintNotification().catchError((e, s) {
      AppLogger.logger.w(
        "Не удалось включить уведомления о печати по причине: $e, $s",
      );
    });
    PrinterClient.enableJobChangedNotification().catchError((e, s) {
      AppLogger.logger.w(
        "Не удалось включить уведомления об изменении задания печати по причине: $e, $s",
      );
    });
  }

  static Future<void> disconnect() async {
    await PrinterClient.disconnect();
    globalState.currentGTIN = "";
    globalState.setWorking(false);
    globalState.setPrinterConnected(false);
  }

  static Future<void> updateGlobalCurrentGTIN() async {
    Map<String, String> fields = await PrinterClient.getCurrentJobData();
    globalState.currentGTIN = fields.containsKey(PrinterClient.gtinFieldName)
        ? fields[PrinterClient.gtinFieldName]!
        : "";
  }

  static Future<bool> updateCode(String newCode) async {
    String gtin = CodesValidator.getGTIN(newCode);
    if (globalState.currentGTIN.isNotEmpty && gtin != globalState.currentGTIN) {
      AppLogger.logger.e(
        "Ошибка при обновлении кода на принтере: GTIN штрихкода ($gtin) не соответствует GTIN группы (${globalState.currentGTIN})",
      );
      globalState.setWorking(false);
      return false;
    }

    Map<String, String> newFields = {PrinterClient.barcodeFieldName: newCode};
    await PrinterClient.updateJob(newFields);

    return true;
  }
}
