import 'package:caesar_zipher/widgets/control_buttons.dart';
import 'package:caesar_zipher/widgets/logs.dart';
import 'package:caesar_zipher/widgets/remain_codes.dart';
import 'package:caesar_zipher/widgets/selected_file.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Flex(
        spacing: 5,
        direction: Axis.vertical,
        children: [
          Flexible(
            flex: 10,
            child: Flex(
              direction: Axis.horizontal,
              spacing: 5,
              children: [
                Flexible(
                  flex: 2,
                  child: Flex(
                    direction: Axis.vertical,
                    spacing: 5,
                    children: [
                      ControlButtons(),
                      Flexible(flex: 5, child: RemainCodes()),
                    ],
                  ),
                ),
                Flexible(
                  child: Logs(),
                ),
              ],
            ),
          ),
          Flexible(child: SelectedFile())
        ],
      ),
    );
  }
}
