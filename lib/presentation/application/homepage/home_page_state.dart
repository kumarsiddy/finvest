part of 'home_page_bloc.dart';

sealed class HomePageState {
  final HomePageStore store;

  HomePageState(this.store);
}

final class InitialState extends HomePageState {
  InitialState(super.store);
}

final class GraphDataChangedState extends HomePageState {
  GraphDataChangedState(super.store);
}
