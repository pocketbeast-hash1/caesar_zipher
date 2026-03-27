import 'package:caesar_zipher/app_logger.dart';
import 'package:caesar_zipher/main.dart';
import 'package:caesar_zipher/printer_client.dart';
import 'package:caesar_zipher/utils/codes_validator.dart';

abstract class PrinterFacade {
  static Future<void> connect(
    PrinterConfig config, {
    OnDataTriggerCallback? onDataTrigger,
  }) async {
    try {
      await PrinterClient.connect(config, onDataTrigger: onDataTrigger);
      await updateGlobalCurrentGTIN();

      globalState.setPrinterConnected(true);
      await setWorking(false);

      PrinterClient.enableNotification(
        PrinterNotifications.printComplete,
      ).catchError((e, s) {
        AppLogger.logger.w(
          "Не удалось включить уведомления о печати по причине: $e, $s",
        );
      });
      PrinterClient.enableNotification(
        PrinterNotifications.currentJobChanged,
      ).catchError((e, s) {
        AppLogger.logger.w(
          "Не удалось включить уведомления об изменении задания печати по причине: $e, $s",
        );
      });
    } catch (e, s) {
      AppLogger.logger.e("Ошибка при попытке подключиться к принтеру: $e, $s");
    }
  }

  static Future<void> disconnect() async {
    try {
      await setWorking(false);
      await PrinterClient.disconnect();
      globalState.currentGTIN = "";
      globalState.setPrinterConnected(false);
    } catch (e, s) {
      AppLogger.logger.e("Ошибка при попытке отключиться от принтера: $e, $s");
    }
  }

  static Future<void> setWorking(bool val) async {
    try {
      PrinterStates state = globalState.printerConnected
          ? await PrinterClient.getState()
          : PrinterStates.offline;

      if (val && state != PrinterStates.running) {
        await PrinterClient.changeState(PrinterStates.running);
      } else if (!val && state != PrinterStates.offline) {
        await PrinterClient.changeState(PrinterStates.offline);
      }

      globalState.setWorking(val);
    } catch (e, s) {
      AppLogger.logger.e("Ошибка при попытке поменять статус принтера: $e, $s");
    }
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
      await setWorking(false);
      return false;
    }

    Map<String, String> newFields = {PrinterClient.barcodeFieldName: newCode};
    try {
      await PrinterClient.updateJob(newFields);
    } catch (e, s) {
      AppLogger.logger.e("Ошибка при обновлении кода на принтере: $e, $s");
      return false;
    }

    return true;
  }
}
