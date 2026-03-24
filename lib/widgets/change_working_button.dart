import 'package:caesar_zipher/app_logger.dart';
import 'package:caesar_zipher/models/global_state_model.dart';
import 'package:caesar_zipher/telnet_client.dart';
import 'package:caesar_zipher/utils/queue.dart';
import 'package:caesar_zipher/utils/settings.dart';
import 'package:caesar_zipher/widgets/bool_button.dart';
import 'package:caesar_zipher/widgets/toast_context.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangeWorkingButton extends StatelessWidget {
  const ChangeWorkingButton({super.key});

  Future<void> _updateJob() async {
    try {
      Settings settings = await Settings.getSettings();
      List<String> codes = await Queue.getQueue();
      String code = codes.last;

      Map<String, String> newFields = {settings.barcodeFieldName: code};
      await TelnetClient.updateJob(newFields);
      
    } catch (e, s) {
      AppLogger.logger.w("Ошибка при обновлении задания: $e, $s");
    }
  }

  Future<void> _changeWorking(GlobalStateModel state, bool val) async {
    if (val && !state.printerConnected) {
      ToastContext.error(
        "Невозможно установить рабочий режим без подключения к принтеру!",
      );
      return;
    }

    if (val && state.codes.isEmpty) {
      ToastContext.error(
        "Невозможно установить рабочий режим без загруженных штрихкодов!",
      );
      return;
    }

    if (val) {
      await _updateJob();
    }

    state.setWorking(val);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalStateModel>(
      builder: (context, state, child) {
        return BoolButton(
          btnState: state.working,
          text: state.working ? "РАБОТА" : "ОСТАНОВЛЕН",
          onPress: () => _changeWorking(state, !state.working),
        );
      },
    );
  }
}
