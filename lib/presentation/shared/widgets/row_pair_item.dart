import 'package:finvest/presentation/core_app/design_library/text.dart';
import 'package:flutter/material.dart';

class RowPairItem extends StatelessWidget {
  final String title;
  final String value;

  const RowPairItem({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Body.semiBold(text: title),
        Body(text: value),
      ],
    );
  }
}
