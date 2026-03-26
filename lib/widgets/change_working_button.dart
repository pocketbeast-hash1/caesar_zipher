import 'package:caesar_zipher/facades/printer_facade.dart';
import 'package:caesar_zipher/models/global_state_model.dart';
import 'package:caesar_zipher/utils/queue.dart';
import 'package:caesar_zipher/widgets/bool_button.dart';
import 'package:caesar_zipher/widgets/toast_context.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangeWorkingButton extends StatelessWidget {
  const ChangeWorkingButton({super.key});

  Future<bool> _updateJob() async {
    List<String> codes = await Queue.getQueue();
    String code = codes.last;
    return await PrinterFacade.updateCode(code);
  }

  Future<void> _changeWorking(GlobalStateModel state, bool val) async {
    if (val && !state.printerConnected) {
      ToastContext.error("Принтер не подключен!");
      return;
    }

    if (val && state.codes.isEmpty) {
      ToastContext.error("Нет загруженных штрихкодов!");
      return;
    }

    if (val) {
      bool success = await _updateJob();
      if (!success) {
        return;
      }
    }

    PrinterFacade.setWorking(val);
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
