import 'dart:math';

import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class PhoneNumberBox extends StatefulWidget {
  PhoneNumberBox({
    super.key,
    required this.controller,
    required this.unmaskedController,
    required this.enabled,
    required this.label,
    this.autofocus = false,
    this.padding = 0.1,
    this.isInputCenter = false,
    this.focusNode,
    this.showDeleteButton = false,
    this.deleteFunction,
    this.deleteWidget,
  });

  final TextEditingController controller;
  final bool enabled;
  final String label;
  final double padding;
  final bool autofocus;
  final bool isInputCenter;
  final FocusNode? focusNode;
  final bool showDeleteButton;
  final Function? deleteFunction;
  final Widget? deleteWidget;
  TextEditingController unmaskedController;

  @override
  PhoneNumberBoxState createState() => PhoneNumberBoxState();
}

class PhoneNumberBoxState extends State<PhoneNumberBox> {
  late MaskTextInputFormatter maskFormatter;
  String unmaskedText = "";

  @override
  void initState() {
    super.initState();
    maskFormatter = MaskTextInputFormatter(
        mask: '(###) ###-####', filter: {"#": RegExp(r'[0-9]')});

    widget.controller.addListener(updateUnmaskedText);
  }

  void updateUnmaskedText() {
    widget.unmaskedController.text = maskFormatter.getUnmaskedText();
  }

  @override
  void dispose() {
    widget.controller.removeListener(updateUnmaskedText);
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
                  textAlign:
                      widget.isInputCenter ? TextAlign.center : TextAlign.left,
                  textAlignVertical: TextAlignVertical.center,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.poppins(
                    fontSize:
                        max(15, MediaQuery.of(context).size.height * 0.0175),
                  ),
                  controller: widget.controller,
                  readOnly: !widget.enabled,
                  decoration: InputDecoration(
                      filled: true,
                      contentPadding:
                          const EdgeInsets.only(right: 12, left: 12),
                      fillColor: AppTheme.notWhite,
                      hintText: widget.label,
                      hintStyle: GoogleFonts.poppins(
                          color: AppTheme.inputBoxGrey,
                          fontSize: max(
                              15, MediaQuery.of(context).size.height * 0.0169)),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      alignLabelWithHint: true,
                      prefixText: '+1   ',
                      prefixStyle: GoogleFonts.poppins(
                          color: AppTheme.secondary,
                          fontWeight: FontWeight.normal,
                          fontSize: max(
                              15, MediaQuery.of(context).size.height * 0.0175)),
                      suffixIcon: widget.showDeleteButton
                          ? IconButton(
                              icon: widget.deleteWidget != null
                                  ? widget.deleteWidget!
                                  : const Icon(Icons.clear_rounded),
                              onPressed: widget.deleteFunction != null
                                  ? () => widget.deleteFunction!()
                                  : () {
                                      widget.controller.clear();
                                    },
                            )
                          : null,
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
