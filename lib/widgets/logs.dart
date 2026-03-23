import 'package:caesar_zipher/models/global_state_model.dart';
import 'package:caesar_zipher/widgets/box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Logs extends StatefulWidget {
  const Logs({super.key});

  @override
  State<Logs> createState() => _LogsState();
}

class _LogsState extends State<Logs> {
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
                    return ListTile(title: Text("> ${state.logs[index]}"));
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
