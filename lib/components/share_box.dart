import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShareBox extends StatefulWidget {
  const ShareBox({
    Key? key,
    required this.controller,
    required this.enabled,
    required this.label,
    this.autofocus = false,
    this.focusNode,
  }) : super(key: key);

  final TextEditingController controller;
  final bool enabled;
  final String label;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  ShareBoxState createState() => ShareBoxState();
}

class ShareBoxState extends State<ShareBox> {
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
    return TextField(
      focusNode: widget.focusNode,
      cursorColor: AppTheme.primary,
      autofocus: widget.autofocus,
      textAlign: TextAlign.right,
      textAlignVertical: TextAlignVertical.center,
      keyboardType: TextInputType.number,
      style: AppTheme.bodyNormal,
      controller: widget.controller,
      readOnly: !widget.enabled,
      decoration: InputDecoration(
        //contentPadding: const EdgeInsets.symmetric(vertical: 0),
        fillColor: Colors.transparent,
        hintText: widget.label,
        hintStyle: GoogleFonts.poppins(
          color: AppTheme.inputBoxGrey,
          fontSize: 16,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        alignLabelWithHint: true,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    );
  }
}
