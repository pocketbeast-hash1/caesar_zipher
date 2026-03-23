import "package:caesar_zipher/app_logger.dart";
import "package:caesar_zipher/styles/colors.dart";
import "package:caesar_zipher/utils/settings.dart";
import "package:caesar_zipher/widgets/toast_context.dart";
import "package:editable/editable.dart";
import "package:flutter/material.dart";

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key, required this.settings});
  final Settings settings;

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  final _editableKey = GlobalKey<EditableState>();

  final List _cols = [
    {"title": "Поле", "key": "field", "widthFactor": 0.1, "editable": false},
    {"title": "Значение", "key": "value"},
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
      width: double.infinity,
      padding: EdgeInsets.all(50),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
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
                AppLogger.logger.e("Ошибка при сохранении настроек: $err, $s");
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
