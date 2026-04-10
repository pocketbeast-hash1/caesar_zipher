import 'dart:io';

import 'package:caesar_zipher/app_logger.dart';
import 'package:caesar_zipher/facades/printer_facade.dart';
import 'package:caesar_zipher/facades/queue_facade.dart';
import 'package:caesar_zipher/models/global_state_model.dart';
import 'package:caesar_zipher/styles/colors.dart';
import 'package:caesar_zipher/widgets/caesar_dialog.dart';
import 'package:caesar_zipher/widgets/toast_context.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoadCodesButton extends StatelessWidget {
  const LoadCodesButton({super.key});

  Future<void> _onPress(BuildContext context, GlobalStateModel state) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["txt", "csv"],
    );

    if (result == null) {
      return;
    }

    File file = File(result.files.single.path!);
    List<String> codes = await QueueFacade.getQueueFromFile(file);

    await PrinterFacade.setWorking(false);
    await QueueFacade.loadQueue(codes);

    if (context.mounted) {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return CaesarDialog(
            title: "Удалить файл?",
            content:
                'Коды маркировки из файла успешно загружены в программу.\n'
                'Вы желаете удалить исходный файл с кодами маркировки?',
            onSubmit: () {
              file.delete().catchError((err, s) {
                ToastContext.error("Ошибка при удалении файла!");
                AppLogger.logger.w("Ошибка при удалении файла: $err, $s");
                throw err;
              });
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalStateModel>(
      builder: (BuildContext context, state, Widget? child) {
        return ElevatedButton(
          onPressed: () => _onPress(context, state),
          style: ElevatedButton.styleFrom(
            backgroundColor: GlobalColors.normalBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(5),
            ),
            shadowColor: Colors.transparent,
            alignment: Alignment.center,
          ),
          child: Text(
            "ЗАГРУЗИТЬ КОДЫ",
            style: TextStyle(color: GlobalColors.textColor),
          ),
        );
      },
    );
  }
}
