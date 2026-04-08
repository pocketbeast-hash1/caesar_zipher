import 'package:caesar_zipher/facades/printer_facade.dart';
import 'package:caesar_zipher/listeners/printer_listeners.dart';
import 'package:caesar_zipher/models/global_state_model.dart';
import 'package:caesar_zipher/printer_client.dart';
import 'package:caesar_zipher/utils/settings.dart';
import 'package:caesar_zipher/widgets/bool_button.dart';
import 'package:caesar_zipher/widgets/toast_context.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConnectToPrinterButton extends StatefulWidget {
  const ConnectToPrinterButton({super.key});

  @override
  State<ConnectToPrinterButton> createState() => _ConnectToPrinterButtonState();
}

class _ConnectToPrinterButtonState extends State<ConnectToPrinterButton> {
  bool waitingResponse = false;

  Future<void> _changeConnection(GlobalStateModel state, bool val) async {
    if (waitingResponse) {
      return;
    }

    setState(() {
      waitingResponse = true;
    });

    Future<void> promise;
    var params = {
      Symbol("pending"): "",
      Symbol("success"): "",
      Symbol("error"): "",
    };

    if (val) {
      Settings settings = await Settings.getSettings();
      PrinterConfig config = PrinterConfig(
        settings.printerHost,
        settings.printerPort,
        settings.gtinField,
        settings.serialNumberField,
        settings.cryptoPartsFields,
      );
      promise = PrinterFacade.connect(
        config,
        onDataTrigger: PrinterListeners.onData,
      );

      params[Symbol("pending")] = "Подключение к принтеру...";
      params[Symbol("success")] = "Принтер подключен!";
      params[Symbol("error")] = "Ошибка подключения к принтеру!";
    } else {
      promise = PrinterFacade.disconnect();
      params[Symbol("pending")] = "Отключение от принтера...";
      params[Symbol("success")] = "Принтер отключен!";
      params[Symbol("error")] = "Ошибка отключения от принтера!";
    }

    Function.apply(ToastContext.promise, [promise], params);

    promise
        .whenComplete(() {
          setState(() {
            waitingResponse = false;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalStateModel>(
      builder: (context, state, child) {
        return BoolButton(
          btnState: state.printerConnected,
          text: state.printerConnected ? "ПОДКЛЮЧЕН" : "НЕ ПОДКЛЮЧЕН",
          onPress: () => _changeConnection(state, !state.printerConnected),
        );
      },
    );
  }
}
