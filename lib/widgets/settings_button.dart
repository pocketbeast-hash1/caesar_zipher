import 'package:caesar_zipher/styles/colors.dart';
import 'package:caesar_zipher/utils/settings.dart';
import 'package:caesar_zipher/screens/settings.dart';
import 'package:flutter/material.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  void _openSettings(BuildContext context, Settings settings) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(settings: settings),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        Settings settings = await Settings.getSettings();
        if (context.mounted) _openSettings(context, settings);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: GlobalColors.normalBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(5),
        ),
        shadowColor: Colors.transparent,
        alignment: Alignment.center,
      ),
      child: Text("#", style: TextStyle(color: GlobalColors.textColor)),
    );
  }
}
