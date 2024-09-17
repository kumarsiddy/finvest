import 'package:finvest/presentation/shared/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class CommonScaffold extends StatelessWidget {
  final Widget child;

  const CommonScaffold({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Credit cards',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}
