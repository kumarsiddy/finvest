import 'dart:math';

import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class DateInputBox extends StatefulWidget {
  const DateInputBox(
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
  DateInputBoxState createState() => DateInputBoxState();
}

class DateInputBoxState extends State<DateInputBox> {
  var maskFormatter = MaskTextInputFormatter(
    mask: "##/##/####",
    filter: {
      "#": RegExp(r'\d+|-|/'),
    },
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
                  maxLength: 10,
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
                      contentPadding:
                          const EdgeInsets.only(right: 12, left: 12),
                      fillColor: AppTheme.notWhite,
                      hintText: widget.label,
                      // labelText: widget.label,
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
                            )),
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
