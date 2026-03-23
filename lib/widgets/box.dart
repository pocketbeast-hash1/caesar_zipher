import 'package:caesar_zipher/styles/colors.dart';
import 'package:flutter/material.dart';

class Box extends StatelessWidget {
  const Box({
    super.key,
    this.direction,
    this.stretch,
    this.children,
  });

  final Axis? direction;
  final bool? stretch;
  final List<Widget>? children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: GlobalColors.boxBackground,
      ),
      child: Flex(
        direction: direction == Axis.vertical ? Axis.horizontal : Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: (stretch ?? false) ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Flex(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: (stretch ?? false) ? MainAxisSize.max : MainAxisSize.min,
            spacing: 10,
            direction: direction ?? Axis.horizontal,
            children: children ?? [],
          ),
        ],
      ),
    );
  }
}
