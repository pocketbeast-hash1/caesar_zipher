import 'package:caesar_zipher/models/global_state_model.dart';
import 'package:caesar_zipher/widgets/box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectedFile extends StatelessWidget {
  const SelectedFile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalStateModel>(
      builder: (context, state, child) {
        return Box(
          stretch: true,
          child: Text(
            "Выбранный файл: ${state.currentFile}",
            style: TextStyle(fontWeight: FontWeight(650)),
          ),
        );
      },
    );
  }
}
