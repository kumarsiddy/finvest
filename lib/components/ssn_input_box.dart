import 'dart:math';

import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class SSNInputBox extends StatefulWidget {
  const SSNInputBox(
      {Key? key,
      required this.controller,
      required this.enabled,
      required this.label,
      this.autofocus = false,
      this.padding = 0.1,
      this.isInputCenter = false,
      this.isNumberInput = false,
      this.focusNode})
      : super(key: key);

  final TextEditingController controller;
  final bool enabled;
  final String label;
  final double padding;
  final bool isNumberInput;
  final bool autofocus;
  final bool isInputCenter;
  final FocusNode? focusNode;

  @override
  SSNInputBoxState createState() => SSNInputBoxState();
}

class SSNInputBoxState extends State<SSNInputBox> {
  late TextEditingController _controller;
  String _previousText = "";
  bool passwordVisible = false;

  var maskFormatter = MaskTextInputFormatter(
    mask: "###-##-####",
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    passwordVisible = true;
    //_controller = widget.controller;
    // _controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    // _controller.removeListener(_handleTextChange);
    super.dispose();
  }

  void _handleTextChange() {
    String text = _controller.text;
    bool isDeletion = text.length < _previousText.length;

    if (isDeletion) {
      int cursorPos = _controller.selection.start;
      if ((cursorPos == 3 || cursorPos == 6) &&
          text.length > 1 &&
          text[cursorPos - 1] != '-') {
        text = text.substring(0, cursorPos - 1) + text.substring(cursorPos);
        _controller.text = text;
        _controller.selection = TextSelection.collapsed(offset: cursorPos - 1);
        _previousText = text;
        return;
      }
    }

    if (text.length == 3 || text.length == 6) {
      if (text[text.length - 1] != '-') {
        text = text.insert(text.length, '-');
        _controller.text = text;
        _controller.selection = TextSelection.collapsed(offset: text.length);
      }
    }
    _previousText = text;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
            padding: EdgeInsets.only(bottom: 50 * widget.padding),
            child: SizedBox(
                height: 50,
                child: TextField(
                  inputFormatters: [maskFormatter],
                  focusNode: widget.focusNode,
                  cursorColor: AppTheme.primary,
                  autofocus: widget.autofocus,
                  obscureText: passwordVisible,
                  maxLength: 11,
                  textAlign:
                      widget.isInputCenter ? TextAlign.center : TextAlign.left,
                  textAlignVertical: TextAlignVertical.center,
                  keyboardType: (widget.isNumberInput)
                      ? TextInputType.number
                      : TextInputType.text,
                  style: GoogleFonts.poppins(
                    fontSize:
                        max(15, MediaQuery.of(context).size.height * 0.0175),
                  ),
                  controller: widget.controller,
                  readOnly: !widget.enabled,
                  decoration: InputDecoration(
                    filled: true,
                    counterText: '',
                    contentPadding: const EdgeInsets.only(right: 12, left: 12),
                    fillColor: AppTheme.notWhite,
                    hintText: widget.label,
                    hintStyle: GoogleFonts.poppins(
                        color: AppTheme.inputBoxGrey,
                        fontSize: max(
                            15, MediaQuery.of(context).size.height * 0.0169)),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    alignLabelWithHint: true,
                    enabledBorder: OutlineInputBorder(
                      // borderRadius:
                      //     const BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: widget.enabled
                        ? const OutlineInputBorder(
                            // borderRadius:
                            //     const BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: AppTheme.primary),
                          )
                        : OutlineInputBorder(
                            // borderRadius:
                            //     const BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                    suffixIcon: IconButton(
                      icon: Icon(passwordVisible
                          ? Icons.visibility_off
                          : Icons.visibility),
                      focusColor: AppTheme.primary,
                      onPressed: () {
                        setState(
                          () {
                            passwordVisible = !passwordVisible;
                          },
                        );
                      },
                    ),
                  ),
                ))),
      ],
    );
  }
}

extension InsertStringX on String {
  String insert(int index, String other) {
    return substring(0, index) + other + substring(index);
  }
}
