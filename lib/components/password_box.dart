import 'dart:math';

import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordBox extends StatefulWidget {
  const PasswordBox(
      {Key? key,
      required this.controller,
      required this.enabled,
      required this.label,
      this.padding = 0.1,
      this.isInputCenter = false,
      this.autofocus = false,
      this.isNumberInput = false,
      this.focusNode})
      : super(key: key);

  final TextEditingController controller;
  final bool enabled;
  final String label;
  final double padding;
  final bool isNumberInput;
  final bool isInputCenter;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  State<PasswordBox> createState() => _PasswordBoxState();
}

class _PasswordBoxState extends State<PasswordBox> {
  bool passwordVisible = false;

  @override
  void initState() {
    super.initState();
    passwordVisible = true;
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
                  focusNode: widget.focusNode,
                  cursorColor: AppTheme.primary,
                  autofocus: widget.autofocus,
                  obscureText: passwordVisible,
                  enableSuggestions: false,
                  autocorrect: false,
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
                    contentPadding: const EdgeInsets.only(right: 12, left: 12),
                    fillColor: AppTheme.notWhite,
                    // fillColor: enabled
                    //     ? ShipperAppTheme.nearlyWhite
                    //     : Colors.grey[100]!,
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
