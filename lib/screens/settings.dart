import "package:caesar_zipher/app_logger.dart";
import "package:caesar_zipher/main.dart";
import "package:caesar_zipher/models/global_state_model.dart";
import "package:caesar_zipher/styles/colors.dart";
import "package:caesar_zipher/utils/settings.dart";
import "package:caesar_zipher/widgets/toast_context.dart";
import "package:editable/editable.dart";
import "package:flutter/material.dart";
import "package:flutter_switch/flutter_switch.dart";
import "package:provider/provider.dart";

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.settings});
  final Settings settings;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _editableKey = GlobalKey<EditableState>();

  final List _cols = [
    {"title": "Поле", "key": "field", "widthFactor": 0.1, "editable": false},
    {"title": "Значение", "key": "value", "widthFactor": 0.9},
  ];

  List<Object> _getRows(Settings settings) {
    return settings
        .toMap()
        .entries
        .map((el) => {"field": el.key, "value": el.value})
        .toList();
  }

  Future<void> _saveSettings(Settings settings) async {
    List<dynamic> rows = _editableKey.currentState!.rows!;
    List<dynamic> editedRows = _editableKey.currentState!.editedRows;

    for (int i = 0; i < editedRows.length; i++) {
      int rowIndex = editedRows[i]["row"];
      String key = rows[rowIndex]["field"];
      dynamic newValue = editedRows[i]["value"];

      settings[key] = newValue;
    }

    await settings.save();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(color: Colors.white),
      child: Stack(
        alignment: AlignmentGeometry.center,
        children: [
          SizedBox(
            width: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Editable(
                    key: _editableKey,
                    columns: _cols,
                    rows: _getRows(widget.settings),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Future<void> promise = _saveSettings(widget.settings);
                    ToastContext.promise(
                      promise,
                      pending: "Сохранение настроек...",
                      error: "Ошибка при сохранении настроек!",
                      success: "Настройки сохранены!",
                    );

                    promise.catchError((err, s) {
                      AppLogger.logger.e(
                        "Ошибка при сохранении настроек: $err, $s",
                      );
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
          ),
          Positioned(bottom: 0, right: 0, child: _DevInfo()),
          Positioned(
            top: 0,
            left: 0,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios),
            ),
          ),
        ],
      ),
    );
  }
}

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
