import 'package:finvest/presentation/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class BaseText extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextOverflow? textOverflow;
  final int? maxLines;
  final double? height;
  final TextDecoration? textDecoration;

  const BaseText({
    Key? key,
    required this.text,
    this.textAlign = TextAlign.left,
    this.fontSize,
    this.fontWeight = FontWeight.w400,
    this.color,
    this.textOverflow = TextOverflow.ellipsis,
    this.maxLines,
    this.height,
    this.textDecoration = TextDecoration.none,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      key: key,
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        overflow: textOverflow,
        height: height,
        decoration: textDecoration,
      ),
    );
  }
}

class Body extends BaseText {
  Body({
    super.key,
    required super.text,
    Color? color,
    TextAlign? textAlign,
    TextDecoration? textDecoration,
  }) : super(
          fontWeight: FontWeight.w400,
          fontSize: 16.sp,
          color: color ?? AppColors.textPrimary,
          textDecoration: textDecoration ?? TextDecoration.none,
          textAlign: textAlign,
          maxLines: 10,
        );

  Body.semiBold({
    super.key,
    required super.text,
    Color? color,
    TextAlign? textAlign,
    TextDecoration? textDecoration,
  }) : super(
          fontWeight: FontWeight.w600,
          fontSize: 16.sp,
          color: color ?? AppColors.textPrimary,
          textDecoration: textDecoration ?? TextDecoration.none,
          textAlign: textAlign,
        );

  Body.bold({
    super.key,
    required super.text,
    Color? color,
    TextAlign? textAlign,
    TextDecoration? textDecoration,
  }) : super(
          fontWeight: FontWeight.w600,
          fontSize: 20.sp,
          color: color ?? AppColors.textPrimary,
          textDecoration: textDecoration ?? TextDecoration.none,
          textAlign: textAlign,
        );

  Body.small({
    super.key,
    required super.text,
    Color? color,
    TextAlign? textAlign,
    TextDecoration? textDecoration,
  }) : super(
          fontWeight: FontWeight.w400,
          fontSize: 12.sp,
          color: color ?? AppColors.textPrimary,
          textDecoration: textDecoration ?? TextDecoration.none,
          textAlign: textAlign,
        );
}

class Header extends BaseText {
  Header({
    super.key,
    required super.text,
    Color? color,
    TextAlign? textAlign,
    TextDecoration? textDecoration,
  }) : super(
          fontWeight: FontWeight.w400,
          fontSize: 24.sp,
          color: color ?? AppColors.textPrimary,
          textDecoration: textDecoration ?? TextDecoration.none,
          textAlign: textAlign,
        );

  Header.bold({
    super.key,
    required super.text,
    Color? color,
    TextAlign? textAlign,
    TextDecoration? textDecoration,
  }) : super(
          fontWeight: FontWeight.w600,
          fontSize: 32.sp,
          color: color ?? AppColors.textPrimary,
          textDecoration: textDecoration ?? TextDecoration.none,
          textAlign: textAlign,
        );

  Header.big({
    super.key,
    required super.text,
    Color? color,
    TextAlign? textAlign,
    TextDecoration? textDecoration,
  }) : super(
          fontWeight: FontWeight.w700,
          fontSize: 60.sp,
          color: color ?? AppColors.textPrimary,
          textDecoration: textDecoration ?? TextDecoration.none,
          textAlign: textAlign,
        );
}

class SmallText extends BaseText {
  SmallText({
    super.key,
    required super.text,
    Color? color,
    TextAlign? textAlign,
    TextDecoration? textDecoration,
  }) : super(
          fontWeight: FontWeight.w400,
          fontSize: 14.sp,
          color: color ?? AppColors.textPrimary,
          textDecoration: textDecoration ?? TextDecoration.none,
          textAlign: textAlign,
        );
}
