import 'package:caesar_zipher/styles/colors.dart';
import 'package:flutter/material.dart';

class CaesarDialog extends StatefulWidget {
  const CaesarDialog({super.key, this.title, this.content, this.onSubmitBtnText, this.onDeclineBtnText, this.onSubmit, this.onDecline});

  final String? title;
  final String? content;
  final String? onSubmitBtnText;
  final String? onDeclineBtnText;
  final VoidCallback? onSubmit;
  final VoidCallback? onDecline;

  @override
  State<CaesarDialog> createState() => _CaesarDialogState();
}

class _CaesarDialogState extends State<CaesarDialog> {
  TextStyle textStyle = TextStyle(color: GlobalColors.textColor);
  Map<Symbol, dynamic> buttonStyle = {
    Symbol("shape"): RoundedRectangleBorder(
      borderRadius: BorderRadiusGeometry.circular(5),
    ),
    Symbol("shadowColor"): Colors.transparent,
    Symbol("alignment"): Alignment.center,
  };
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: GlobalColors.boxBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: widget.title != null ? Text(widget.title!) : null,
      content: widget.content != null ? Text(widget.content!) : null,
      actions: [
        ElevatedButton(
          style: Function.apply(ElevatedButton.styleFrom, [], {
            ...buttonStyle,
            Symbol("backgroundColor"): GlobalColors.goodBackground,
          }),
          onPressed: () {
            widget.onSubmit?.call();
            Navigator.of(context).pop();
          },
          child: Text(widget.onSubmitBtnText ?? "Да", style: textStyle),
        ),
        ElevatedButton(
          style: Function.apply(ElevatedButton.styleFrom, [], {
            ...buttonStyle,
            Symbol("backgroundColor"): GlobalColors.badBackground,
          }),
          onPressed: () {
            widget.onDecline?.call();
            Navigator.of(context).pop();
          },
          child: Text(widget.onDeclineBtnText ?? "Нет", style: textStyle),
        ),
      ],
    );
  }
}
