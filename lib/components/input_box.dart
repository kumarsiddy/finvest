import 'dart:math';

import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InputBox extends StatefulWidget {
  const InputBox(
      {Key? key,
      required this.controller,
      required this.enabled,
      required this.label,
      this.autofocus = false,
      this.padding = 0.1,
      this.isInputCenter = false,
      this.isNumberInput = false,
      this.focusNode,
      this.showDeleteButton = false,
      this.deleteFunction,
      this.deleteWidget,
      this.textCapitalization = false})
      : super(key: key);

  final TextEditingController controller;
  final bool enabled;
  final String label;
  final double padding;
  final bool isNumberInput;
  final bool autofocus;
  final bool isInputCenter;
  final FocusNode? focusNode;
  final bool showDeleteButton;
  final Function? deleteFunction;
  final Widget? deleteWidget;
  final bool textCapitalization;

  @override
  _InputBoxState createState() => _InputBoxState();
}

class _InputBoxState extends State<InputBox> {
  final ValueNotifier<bool> _hasText = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateHasText);
    _updateHasText();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateHasText);
    super.dispose();
  }

  void _updateHasText() {
    _hasText.value = widget.controller.text.isNotEmpty;
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
                  textCapitalization: widget.textCapitalization
                      ? TextCapitalization.sentences
                      : TextCapitalization.none,
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
                      // suffixIcon: ValueListenableBuilder<bool>(
                      //   valueListenable: _hasText,
                      //   builder: (context, hasText, _) {
                      //     return widget.showDeleteButton && hasText
                      //         ? IconButton(
                      //             icon: const Icon(Icons.clear_rounded),
                      //             focusColor: AppTheme.primary,
                      //             onPressed: () {
                      //               widget.controller.clear();
                      //               _updateHasText();
                      //             },
                      //           )
                      //         : const SizedBox.shrink();
                      //   },
                      // ),
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
