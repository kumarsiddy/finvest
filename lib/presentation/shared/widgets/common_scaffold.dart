import 'package:finvest/presentation/shared/app_colors.dart';
import 'package:finvest/presentation/shared/widgets/app_bar.dart';
import 'package:finvest/presentation/shared/widgets/icon.dart';
import 'package:flutter/material.dart';

class CommonScaffold extends StatefulWidget {
  final Widget child;

  const CommonScaffold({
    super.key,
    required this.child,
  });

  @override
  State<CommonScaffold> createState() => _CommonScaffoldState();
}

class _CommonScaffoldState extends State<CommonScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        title: 'Credit cards',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.child,
      ),
    );
  }


}
