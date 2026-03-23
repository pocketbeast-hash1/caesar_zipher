import 'package:caesar_zipher/models/global_state_model.dart';
import 'package:caesar_zipher/widgets/bool_button.dart';
import 'package:caesar_zipher/widgets/toast_context.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangeWorkingButton extends StatelessWidget {
  const ChangeWorkingButton({super.key});

  void _changeWorking(GlobalStateModel state, bool val) {
    if (val && !state.printerConnected) {
      ToastContext.error("Невозможно установить рабочий режим без подключения к принтеру!");
      return;
    }

    state.setWorking(val);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalStateModel>(
      builder: (context, state, child) {
        return BoolButton(
          btnState: state.working,
          text: state.working
              ? "РАБОТА"
              : "ОСТАНОВЛЕН",
          onPress: () => _changeWorking(state, !state.working),
        );
      },
    );
  }
}
