import 'package:caesar_zipher/styles/colors.dart';
import 'package:flutter/material.dart';

class Box extends StatelessWidget {
  const Box({super.key, required this.direction, required this.children});
  final BoxDirection direction;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: GlobalColors.boxBackground,
      ),
      child: _Line(direction: direction, children: children),
    );
  }
}

enum BoxDirection { vertical, horizontal }

class _Line extends StatelessWidget {
  const _Line({required this.direction, required this.children});
  final BoxDirection direction;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    Map<Symbol, dynamic> lineContent = {
      Symbol("crossAxisAlignment"): CrossAxisAlignment.center,
      Symbol("mainAxisAlignment"): MainAxisAlignment.center,
      Symbol("mainAxisSize"): MainAxisSize.min,
      Symbol("spacing"): 10.0,
      Symbol("children"): children,
    };

    if (direction == BoxDirection.horizontal) {
      return Function.apply(Row.new, [], lineContent);
    } else if (direction == BoxDirection.vertical) {
      return Function.apply(Column.new, [], lineContent);
    } else {
      return Function.apply(Column.new, [], lineContent);
    }
  }
}
