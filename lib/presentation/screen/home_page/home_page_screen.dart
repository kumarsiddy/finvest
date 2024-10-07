import 'package:finvest/presentation/application/homepage/home_page_bloc.dart';
import 'package:finvest/presentation/application/models/credit_card_item.dart';
import 'package:finvest/presentation/application/models/spend_item.dart';
import 'package:finvest/presentation/application/models/txn_item.dart';
import 'package:finvest/presentation/core_app/base/base_state.dart';
import 'package:finvest/presentation/core_app/base/size_config.dart';
import 'package:finvest/presentation/screen/home_page/home_page_view_controller.dart';
import 'package:finvest/presentation/shared/app_colors.dart';
import 'package:finvest/presentation/shared/screens/double_press_to_exit.dart';
import 'package:finvest/presentation/shared/text.dart';
import 'package:finvest/presentation/shared/widgets/app_bar.dart';
import 'package:finvest/presentation/shared/widgets/icon.dart';
import 'package:finvest/utils/extensions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_page_widgets.dart';

class HomePageScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageScreenState();
}

class HomePageScreenState
    extends BaseState<HomePageScreen, HomePageViewController, HomePageBloc> {
  @override
  Widget buildWidget(BuildContext context) {
    return BlocConsumer<HomePageBloc, HomePageState>(
      builder: (context, state) {
        return _HomePageWidget(viewController!);
      },
      listener: _handleState,
    );
  }

  Future<void> _handleState(
    BuildContext context,
    HomePageState state,
  ) async {}
}
