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

      List<PrinterNotifications> notificationsToEnable = [
        PrinterNotifications.printComplete,
        PrinterNotifications.currentJobChanged,
        PrinterNotifications.stateChange,
      ];
      for (PrinterNotifications notification in notificationsToEnable) {
        PrinterClient.enableNotification(notification).catchError((e, s) {
          AppLogger.logger.w(
            "Не удалось включить уведомление $notification по причине: $e, $s",
          );
        });

        // небольшая задержка, чтобы ответы не приходили одновременно,
        // и клиент принтера мог их нормально обработать
        await Future.delayed(Duration(milliseconds: 100));
      }
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

  static Future<void> updateCode(String newCode) async {
    String gtin = "";
    try {
      gtin = CodesValidator.getGTIN(newCode);
    } catch (e, s) {
      AppLogger.logger.w("Ошибка при попытке получить GTIN кода маркировки: $e, $s");
    }
    
    if (globalState.currentGTIN.isNotEmpty && gtin != globalState.currentGTIN) {
      AppLogger.logger.e(
        "Ошибка при обновлении кода на принтере: GTIN штрихкода ($gtin) не соответствует GTIN группы (${globalState.currentGTIN})",
      );
      await setWorking(false);
      return;
    }

    String nonShielded = CodesValidator.getCodeWithNonShieldedSeparatorGS1(newCode);
    Map<String, String> newFields = {PrinterClient.barcodeFieldName: nonShielded};
    try {
      await PrinterClient.updateJob(newFields);
    } catch (e, s) {
      AppLogger.logger.e("Ошибка при обновлении кода на принтере: $e, $s");
      await setWorking(false);
    }
  }
}
