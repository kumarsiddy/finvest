import 'dart:math';

import 'package:finvest/presentation/application/base/base_bloc.dart';
import 'package:finvest/presentation/application/homepage/home_page_bloc.dart';
import 'package:finvest/presentation/core_app/base/base_stateless_widget.dart';
import 'package:finvest/presentation/core_app/base/size_config.dart';
import 'package:finvest/presentation/shared/app_colors.dart';
import 'package:finvest/presentation/shared/screens/double_press_to_exit.dart';
import 'package:finvest/presentation/shared/text.dart';
import 'package:finvest/presentation/shared/widgets/app_bar.dart';
import 'package:finvest/presentation/shared/widgets/common_scaffold.dart';
import 'package:finvest/presentation/shared/widgets/icon.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'graph_view.dart';
part 'home_page_widgets.dart';

class HomePageScreen extends BaseStatelessWidget<HomePageBloc> {
  @override
  Widget buildScreen(BuildContext context) {
    return BlocConsumer<HomePageBloc, BaseState>(
      builder: (context, state) {
        return _HomePageWidget();
      },
      listener: _handleState,
    );
  }

  Future<void> _handleState(
    BuildContext context,
    BaseState baseState,
  ) async {
    if (baseState is HomePageState) {}
  }
}
