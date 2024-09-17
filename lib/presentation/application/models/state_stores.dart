import 'package:finvest/presentation/application/base/base_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'state_stores.freezed.dart';

@freezed
class HomePageStore extends BaseStateStore with _$HomePageStore {
  const factory HomePageStore({
    required String name,
    required int age,
  }) = _HomePageStore;
}
