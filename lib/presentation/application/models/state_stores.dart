import 'package:fl_chart/fl_chart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'state_stores.freezed.dart';

@freezed
class HomePageStore with _$HomePageStore {
  const factory HomePageStore({
    required List<FlSpot> dataList,
  }) = _HomePageStore;
}

@freezed
class CommonStore with _$CommonStore {
  const factory CommonStore({
    required Map<String, dynamic>? args,
  }) = _CommonStore;
}
