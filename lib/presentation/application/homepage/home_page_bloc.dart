import 'package:finvest/presentation/application/base/base_bloc.dart';
import 'package:finvest/presentation/application/base/common_bloc.dart';
import 'package:finvest/presentation/application/models/state_stores.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'home_page_event.dart';
part 'home_page_state.dart';

@injectable
class HomePageBloc extends BaseBloc<HomePageEvent, HomePageState> {
  HomePageBloc(
    CommonBloc commonBloc,
  ) : super(
          commonBloc,
          InitialState(HomePageStore(dataList: _dataList4)),
        );

  @override
  void handleEvents() {
    on<ChangeGraphDataEvent>(_onGraphDataChanged);
  }

  Future<void> _onGraphDataChanged(
    ChangeGraphDataEvent event,
    Emitter<HomePageState> emit,
  ) async {
    showLoader();
    await Future.delayed(
      Duration(seconds: 1),
      () {
        hideLoader();
      },
    );
    emit(
      GraphDataChangedState(
        state.store.copyWith(
          dataList: _dataListOfList[event.index],
        ),
      ),
    );
  }

  void changeDataSet(int index) {
    add(ChangeGraphDataEvent(index: index));
  }
}

final _dataListOfList = [
  _dataList1,
  _dataList2,
  _dataList3,
  _dataList4,
  _dataList5,
  _dataList6,
  _dataList7,
];

final _dataList1 = [
  FlSpot(0, 1),
  FlSpot(1, 2.5),
  FlSpot(2, 3),
  FlSpot(3, 3.8),
  FlSpot(3.5, 4),
  FlSpot(4, 3.2),
  FlSpot(5, 2.5),
  FlSpot(6, 2.8),
  FlSpot(7, 3),
  FlSpot(8, 3.5),
  FlSpot(9, 2.8),
  FlSpot(10, 2),
  FlSpot(11, 2.5),
];

final _dataList2 = [
  FlSpot(0, 2),
  FlSpot(0.5, 2.2),
  FlSpot(1, 2.8),
  FlSpot(1.5, 2.5),
  FlSpot(2, 3.2),
  FlSpot(3, 4.5),
  FlSpot(4, 4.2),
  FlSpot(5, 3.5),
  FlSpot(5.5, 3),
  FlSpot(6, 4.8),
  FlSpot(6.5, 5),
  FlSpot(7, 4.2),
  FlSpot(8, 4),
  FlSpot(9, 3.5),
  FlSpot(10, 3),
];

final _dataList3 = [
  FlSpot(0, 4),
  FlSpot(1, 4.2),
  FlSpot(2.5, 3),
  FlSpot(3.5, 5),
  FlSpot(4, 5.5),
  FlSpot(5, 5.2),
  FlSpot(6, 4),
  FlSpot(7, 4.5),
  FlSpot(8, 2.5),
  FlSpot(9, 2.8),
  FlSpot(9.5, 3),
  FlSpot(10, 4.5),
  FlSpot(11, 4.2),
];

final _dataList4 = [
  FlSpot(0, 1.5),
  FlSpot(0.8, 2.5),
  FlSpot(1.2, 3.5),
  FlSpot(2, 3.2),
  FlSpot(3.8, 3),
  FlSpot(4.5, 3.5),
  FlSpot(5, 4.2),
  FlSpot(6, 3.8),
  FlSpot(7, 2.8),
  FlSpot(8, 3.5),
  FlSpot(9, 4),
  FlSpot(10, 3.2),
  FlSpot(11, 3.5),
];

final _dataList5 = [
  FlSpot(0, 3),
  FlSpot(1, 3.5),
  FlSpot(1.5, 4.5),
  FlSpot(2, 4.8),
  FlSpot(3, 2),
  FlSpot(4, 3),
  FlSpot(5, 4),
  FlSpot(6, 3.5),
  FlSpot(7, 3),
  FlSpot(8, 2.5),
  FlSpot(8.5, 2.5),
  FlSpot(9.5, 2.8),
  FlSpot(10.5, 3),
];

final _dataList6 = [
  FlSpot(0, 2.5),
  FlSpot(1.5, 3.5),
  FlSpot(2, 4),
  FlSpot(2.8, 3.2),
  FlSpot(3.5, 3),
  FlSpot(4.2, 3.5),
  FlSpot(5, 4.5),
  FlSpot(6, 5),
  FlSpot(7, 4.2),
  FlSpot(8, 3.5),
  FlSpot(9, 3),
  FlSpot(10, 2.8),
  FlSpot(11, 4),
];

final _dataList7 = [
  FlSpot(0, 2),
  FlSpot(0.5, 3),
  FlSpot(1.5, 4),
  FlSpot(2.5, 3.8),
  FlSpot(3, 3.5),
  FlSpot(4, 4.2),
  FlSpot(5, 2.2),
  FlSpot(6, 4.8),
  FlSpot(6.5, 5),
  FlSpot(7.5, 3.2),
  FlSpot(8.5, 3.8),
  FlSpot(9.5, 4.2),
  FlSpot(10.5, 4.5),
];
