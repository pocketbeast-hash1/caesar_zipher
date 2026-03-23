import 'package:caesar_zipher/models/global_state_model.dart';
import 'package:caesar_zipher/styles/colors.dart';
import 'package:caesar_zipher/widgets/box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RemainCodes extends StatelessWidget {
  const RemainCodes({super.key});

  Color _getTextColor(int codesLength) {
    if (codesLength > 100) {
      return GlobalColors.goodTextColor;
    } else if (100 >= codesLength && codesLength >= 25) {
      return GlobalColors.normalTextColor;
    } else {
      return GlobalColors.badTextColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalStateModel>(
      builder: (context, state, child) {
        return Box(
          stretch: true,
          child:
            Text(
              state.codes.length.toString(),
              style: TextStyle(
                color: _getTextColor(state.codes.length),
                fontSize: 90,
                fontWeight: FontWeight(700),
              ),
            ),
        );
      },
    );
  }
}
