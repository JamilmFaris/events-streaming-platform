import 'package:events_streaming_platform/design/tw_colors.dart';
import 'package:flutter/material.dart';

import '../design/styles.dart';
import 'helper.dart';

class EventArguments {
  static const TextStyle talkStatusTextStyle = TextStyle(
    fontSize: 12,
    color: TwColors.lightBlue,
  );
  static const Size accountImageMaxSize = Size(128.0, 128.0);
  static const double circular = 20.0;
  static const OutlineInputBorder outlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(circular),
    ),
  );
  static Widget createTextField({
    bool autofocus = false,
    required TextEditingController controller,
    required String textType,
    String label = "",
    bool obscureText = false,
    TextInputType textInputType = TextInputType.text,
    TextInputAction? textInputAction,
  }) {
    if (label.isEmpty) {
      label = textType;
    }
    label = Helper.capitalize(label);
    return Column(children: [
      TextField(
        obscureText: obscureText,
        autofocus: autofocus,
        controller: controller,
        decoration: InputDecoration(
          hintText: "input event's $textType",
          border: outlineInputBorder,
          hintStyle: Styles.hintStyle,
        ),
        keyboardType: textInputType,
        textInputAction: textInputAction,
      ),
    ]);
  }

  static EventFilledButton({
    required Function() onPressed,
    required Widget child,
  }) {
    return FilledButton(
      onPressed: onPressed,
      child: child,
    );
  }
}
