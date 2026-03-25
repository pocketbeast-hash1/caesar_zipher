import 'package:caesar_zipher/models/global_state_model.dart';
import 'package:caesar_zipher/styles/colors.dart';
import 'package:caesar_zipher/widgets/box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Map<String, Color> _logColors = {
  "[T]": Colors.transparent,
  "[D]": Colors.transparent,
  "[I]": GlobalColors.normalBackground,
  "[W]": GlobalColors.warnBackground,
  "[E]": GlobalColors.badBackground,
  "[F]": Colors.transparent,
};

class Logs extends StatefulWidget {
  const Logs({super.key});

  @override
  State<Logs> createState() => _LogsState();
}

class _LogsState extends State<Logs> {
  Color _getLogColor(String log) {
    String prefix = log.substring(0, 3);
    if (_logColors.containsKey(prefix)) {
      return _logColors[prefix]!;
    } else {
      return Colors.transparent;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalStateModel>(
      builder: (context, state, child) {
        return BoxContainer(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.logs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: _getLogColor(state.logs[index]),
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        child: Text("> ${state.logs[index]}"),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
