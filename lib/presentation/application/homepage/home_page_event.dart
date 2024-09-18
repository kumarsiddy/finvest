part of 'home_page_bloc.dart';

sealed class HomePageEvent {}

final class ChangeGraphDataEvent extends HomePageEvent {
  final int index;

  ChangeGraphDataEvent({
    required this.index,
  });
}