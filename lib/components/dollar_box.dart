import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DollarBox extends StatefulWidget {
  const DollarBox({
    Key? key,
    required this.controller,
    required this.enabled,
    required this.label,
    this.autofocus = false,
    this.padding = 0.02,
    this.isInputCenter = false,
    this.isNumberInput = false,
    this.focusNode,
  }) : super(key: key);

  final TextEditingController controller;
  final bool enabled;
  final String label;
  final double padding;
  final bool isNumberInput;
  final bool autofocus;
  final bool isInputCenter;
  final FocusNode? focusNode;

  @override
  DollarBoxState createState() => DollarBoxState();
}

class DollarBoxState extends State<DollarBox> {
  late Color prefixColor;

  @override
  void initState() {
    super.initState();
    prefixColor = AppTheme.inputBoxGrey;
    widget.controller.addListener(() {
      setState(() {
        prefixColor = widget.controller.text.isEmpty
            ? AppTheme.inputBoxGrey
            : AppTheme.secondary;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * widget.padding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    WidgetSpan(
                      child: Transform.translate(
                        offset: const Offset(0, -4),
                        child: Text(
                          "\$",
                          style: GoogleFonts.poppins(
                              fontSize: 30, color: prefixColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: TextField(
                  focusNode: widget.focusNode,
                  cursorColor: AppTheme.primary,
                  autofocus: widget.autofocus,
                  textAlign:
                      widget.isInputCenter ? TextAlign.center : TextAlign.left,
                  textAlignVertical: TextAlignVertical.center,
                  keyboardType: widget.isNumberInput
                      ? const TextInputType.numberWithOptions(decimal: true)
                      : TextInputType.text,
                  style: GoogleFonts.poppins(
                      fontSize: 40, color: AppTheme.secondary),
                  controller: widget.controller,
                  readOnly: !widget.enabled,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(right: 12, left: 0),
                    fillColor: Colors.transparent,
                    hintText: widget.label,
                    hintStyle: GoogleFonts.poppins(
                      color: AppTheme.inputBoxGrey,
                      fontSize: 30,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    alignLabelWithHint: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
