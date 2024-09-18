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
  Body.big({
    super.key,
    required super.text,
    Color? color,
    TextAlign? textAlign,
    TextDecoration? textDecoration,
  }) : super(
          fontWeight: FontWeight.w500,
          fontSize: 16.sp,
          color: color ?? AppColors.textPrimary,
          textDecoration: textDecoration ?? TextDecoration.none,
          textAlign: textAlign,
          maxLines: 10,
        );

  Body.medium({
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

  Body.smallBold({
    super.key,
    required super.text,
    Color? color,
    TextAlign? textAlign,
    TextDecoration? textDecoration,
  }) : super(
          fontWeight: FontWeight.w600,
          fontSize: 12.sp,
          color: color ?? AppColors.textPrimary,
          textDecoration: textDecoration ?? TextDecoration.none,
          textAlign: textAlign,
        );
}

class Header extends BaseText {
  Header.big({
    super.key,
    required super.text,
    Color? color,
    TextAlign? textAlign,
    TextDecoration? textDecoration,
  }) : super(
          fontWeight: FontWeight.w500,
          fontSize: 40.sp,
          color: color ?? AppColors.textPrimary,
          textDecoration: textDecoration ?? TextDecoration.none,
          textAlign: textAlign,
        );

  Header.medium({
    super.key,
    required super.text,
    Color? color,
    TextAlign? textAlign,
    TextDecoration? textDecoration,
  }) : super(
          fontWeight: FontWeight.w500,
          fontSize: 20.sp,
          color: color ?? AppColors.textPrimary,
          textDecoration: textDecoration ?? TextDecoration.none,
          textAlign: textAlign,
        );

  /// 18px,500Wt
  Header.small({
    super.key,
    required super.text,
    Color? color,
    TextAlign? textAlign,
    TextDecoration? textDecoration,
  }) : super(
          fontWeight: FontWeight.w500,
          fontSize: 18.sp,
          color: color ?? AppColors.textPrimary,
          textDecoration: textDecoration ?? TextDecoration.none,
          textAlign: textAlign,
        );
}

class Label extends BaseText {
  Label.medium({
    super.key,
    required super.text,
    Color? color,
    TextAlign? textAlign,
    TextDecoration? textDecoration,
  }) : super(
          fontWeight: FontWeight.w600,
          fontSize: 10.sp,
          color: color ?? AppColors.textPrimary,
          textDecoration: textDecoration ?? TextDecoration.none,
          textAlign: textAlign,
        );
}

class CurrencyDisplayText extends StatelessWidget {
  final double value;

  const CurrencyDisplayText({
    Key? key,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> parts = value.toStringAsFixed(2).split('.');
    String mainPart = '\$${parts[0]}'; // Main number part
    String decimalPart = '.${parts[1]}'; // Decimal part

    return RichText(
      textAlign: TextAlign.start,
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: <TextSpan>[
          TextSpan(
            text: mainPart,
            style: TextStyle(
              fontSize: 30.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          TextSpan(children: [
            WidgetSpan(
              child: Transform.translate(
                offset: Offset(0, -10),
                // Adjust the offset value to position the decimal part
                child: Text(
                  decimalPart,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}