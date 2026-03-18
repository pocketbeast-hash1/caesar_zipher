import 'package:caesar_zipher/styles/colors.dart';
import 'package:flutter/material.dart';

class BoolButton extends StatelessWidget {
  const BoolButton({
    super.key,
    required this.btnState,
    required this.text,
    required this.onPress,
  });

  final bool btnState;
  final String text;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPress,
      style: ElevatedButton.styleFrom(
        backgroundColor: btnState
            ? GlobalColors.goodBackground
            : GlobalColors.badBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(5),
        ),
        shadowColor: Colors.transparent,
        alignment: Alignment.center,
      ),
      child: Text("data", style: TextStyle(color: GlobalColors.textColor)),
    );
  }
}
