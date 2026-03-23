import 'package:caesar_zipher/widgets/box.dart';
import 'package:caesar_zipher/widgets/control_buttons.dart';
import 'package:caesar_zipher/widgets/remain_codes.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
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
            child: Box(
              stretch: true,
              children: [
                Text(
                  "тут будут логи",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight(700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
