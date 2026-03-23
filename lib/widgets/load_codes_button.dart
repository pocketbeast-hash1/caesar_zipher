import 'dart:io';

import 'package:caesar_zipher/models/global_state_model.dart';
import 'package:caesar_zipher/styles/colors.dart';
import 'package:caesar_zipher/utils/queue.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoadCodesButton extends StatelessWidget {
  const LoadCodesButton({super.key});

  Future<void> _onPress(GlobalStateModel state) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["txt"],
    );

    if (result == null) {
      return;
    }

    File file = File(result.files.single.path!);
    String content = await file.readAsString();
    List<String> codes = content.split("\n");

    await Queue.loadQueue(codes);
    state.setCodes(codes);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalStateModel>(
      builder: (BuildContext context, state, Widget? child) {
        return ElevatedButton(
          onPressed: () => _onPress(state),
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
