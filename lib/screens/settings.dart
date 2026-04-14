import "dart:io";

import "package:caesar_zipher/app_logger.dart";
import "package:caesar_zipher/main.dart";
import "package:caesar_zipher/models/global_state_model.dart";
import "package:caesar_zipher/styles/colors.dart";
import "package:caesar_zipher/utils/settings.dart";
import "package:caesar_zipher/widgets/toast_context.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_switch/flutter_switch.dart";
import "package:provider/provider.dart";

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.settings});
  final Settings settings;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(color: Colors.white),
      child: Stack(
        alignment: AlignmentGeometry.center,
        children: [
          _SettingsInput(settings: widget.settings),
          Positioned(bottom: 0, right: 0, child: _DevInfo()),
          Positioned(
            top: 0,
            left: 0,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_outlined),
            ),
          ),
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////////

class _SettingsInput extends StatefulWidget {
  const _SettingsInput({required this.settings});
  final Settings settings;

  @override
  _SettingsInputState createState() => _SettingsInputState();
}

class _SettingsInputState extends State<_SettingsInput> {
  TextInputType _getTextInputTypeByValue(dynamic value) {
    if (value.runtimeType == String) {
      return TextInputType.text;
    } else if (value.runtimeType == int) {
      return TextInputType.number;
    } else {
      return TextInputType.text;
    }
  }

  List<TextInputFormatter> _getTextInputFormatterByValue(dynamic value) {
    if (value.runtimeType == String) {
      return [];
    } else if (value.runtimeType == int) {
      return [FilteringTextInputFormatter.digitsOnly];
    } else {
      return [];
    }
  }

  List<Widget> _getInputFields() {
    List<Widget> widgets = [];

    widget.settings.toMap().forEach((key, value) {
      String initValue = value.toString().replaceAll(
        RegExp(r"[\[\]]"),
        "",
      ); // убрать квадратные скобки массива

      widgets.add(
        Material(
          child: TextFormField(
            initialValue: initValue,
            keyboardType: _getTextInputTypeByValue(value),
            inputFormatters: _getTextInputFormatterByValue(value),
            decoration: InputDecoration(
              labelText: key,
              labelStyle: TextStyle(color: GlobalColors.textColor),
              filled: true,
              fillColor: Colors.white,
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: GlobalColors.textColor),
              ),
            ),
            style: TextStyle(color: GlobalColors.textColor),
            cursorColor: GlobalColors.textColor,
            onChanged: (changedValue) {
              setState(() {
                widget.settings[key] = changedValue;
              });
            },
          ),
        ),
      );
    });

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ..._getInputFields(),
          Expanded(child: SizedBox()),
          ElevatedButton(
            onPressed: () {
              Future<File> promise = widget.settings.save();
              ToastContext.promise(promise, pending: "Сохранение настроек...");

              promise.then((value) {
                ToastContext.success(
                  "Настройки сохранены: ${value.path}",
                  duration: Duration(seconds: 5),
                );
              });
              promise.catchError((err, s) {
                AppLogger.logger.e("Ошибка при сохранении настроек: $err, $s");
                throw err;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: GlobalColors.goodBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(5),
              ),
              shadowColor: Colors.transparent,
              alignment: Alignment.center,
            ),
            child: Text(
              "СОХРАНИТЬ",
              style: TextStyle(color: GlobalColors.textColor),
            ),
          ),
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////////

class _DevInfo extends StatelessWidget {
  _DevInfo();

  final double _fontSize = 20;
  final FontWeight _fontWeight = FontWeight(700);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        DefaultTextStyle(
          style: TextStyle(
            color: GlobalColors.softGray,
            fontSize: _fontSize,
            fontWeight: _fontWeight,
          ),
          child: Text("Версия: ${globalState.appVersion}"),
        ),
        Consumer<GlobalStateModel>(
          builder: (context, state, children) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 10,
              children: [
                DefaultTextStyle(
                  style: TextStyle(
                    color: GlobalColors.softGray,
                    fontSize: _fontSize,
                    fontWeight: _fontWeight,
                  ),
                  child: Text("Отладка"),
                ),
                FlutterSwitch(
                  value: state.debugMode,
                  inactiveColor: GlobalColors.boxBackground,
                  activeColor: GlobalColors.goodBackground,
                  toggleColor: GlobalColors.softGray,
                  height: _fontSize,
                  width: _fontSize * 3,
                  onToggle: (bool value) {
                    state.debugMode = value;
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
