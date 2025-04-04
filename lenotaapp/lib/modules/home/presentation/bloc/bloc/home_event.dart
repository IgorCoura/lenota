part of 'home_bloc.dart';

@immutable
sealed class HomeEvent extends Equatable {}

class InitialEvent extends HomeEvent {
  @override
  List<Object?> get props => [];
}

class FeatchNextPage extends HomeEvent {
  @override
  List<Object?> get props => [];
}
