import 'package:caesar_zipher/models/global_state_model.dart';
import 'package:caesar_zipher/styles/colors.dart';
import 'package:caesar_zipher/widgets/box.dart';
import 'package:caesar_zipher/widgets/caesar_dialog.dart';
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
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Color _getLogColor(String log) {
    String prefix = log.substring(0, 3);
    if (_logColors.containsKey(prefix)) {
      return _logColors[prefix]!;
    } else {
      return Colors.transparent;
    }
  }

  void _clearLogs(BuildContext context, GlobalStateModel state) {
    if (context.mounted) {
      showDialog<void>(context: context, builder: (BuildContext context) {
        return CaesarDialog(
          title: "Очистить логи?",
          onSubmit: state.clearLogs,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalStateModel>(
      builder: (context, state, child) {
        if (state.autoScroll) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            _scrollToBottom();
          });
        }

        return BoxContainer(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      shrinkWrap: true,
                      itemCount: state.logs.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: _getLogColor(state.logs[index]),
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                            child: Text("> ${state.logs[index]}"),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  onPressed: () => _clearLogs(context, state),
                  icon: Icon(Icons.clear_all_outlined),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
