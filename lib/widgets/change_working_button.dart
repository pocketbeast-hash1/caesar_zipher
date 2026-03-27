import 'package:caesar_zipher/facades/printer_facade.dart';
import 'package:caesar_zipher/models/global_state_model.dart';
import 'package:caesar_zipher/widgets/bool_button.dart';
import 'package:caesar_zipher/widgets/toast_context.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangeWorkingButton extends StatelessWidget {
  const ChangeWorkingButton({super.key});

  Future<void> _changeWorking(GlobalStateModel state, bool val) async {
    if (val && !state.printerConnected) {
      ToastContext.error("Принтер не подключен!");
      return;
    }

    if (val && state.codes.isEmpty) {
      ToastContext.error("Нет загруженных штрихкодов!");
      return;
    }

    Future<void> promise = PrinterFacade.setWorking(val);
    ToastContext.promise(
      promise,
      pending: val ? "Запуск..." : "Остановка",
      error: "Ошибка при работе с принтером!",
    );
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
