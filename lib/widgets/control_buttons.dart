import 'package:caesar_zipher/widgets/change_working_button.dart';
import 'package:caesar_zipher/widgets/connect_to_printer_button.dart';
import 'package:caesar_zipher/widgets/load_codes_button.dart';
import 'package:flutter/material.dart';

class ControlButtons extends StatelessWidget {
  const ControlButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      spacing: 5,
      children: [
        Expanded(child: ChangeWorkingButton()),
        Expanded(child: ConnectToPrinterButton()),
        Expanded(child: LoadCodesButton()),
      ],
    );
  }
}
