import 'package:finvest/presentation/application/base/base_bloc.dart';
import 'package:finvest/presentation/application/homepage/home_page_bloc.dart';
import 'package:finvest/presentation/core_app/base/base_stateless_widget.dart';
import 'package:finvest/presentation/shared/widgets/common_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_page_widgets.dart';

class HomePageScreen extends BaseStatelessWidget<HomePageBloc> {
  @override
  Widget buildScreen(BuildContext context) {
    return BlocConsumer<HomePageBloc, BaseState>(
      builder: (context, state) {
        return HomePageWidget();
      },
      listener: _handleState,
    );
    return Scaffold();
  }

  Future<void> _handleState(
    BuildContext context,
    BaseState baseState,
  ) async {
    if (baseState is HomePageState) {}
  }
}
