part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {}

class InitialEvent extends HomeEvent {
  @override
  List<Object?> get props => [];
}

class FeatchNextPage extends HomeEvent {
  @override
  List<Object?> get props => [];
}

class EditItensEvent extends HomeEvent {
  @override
  List<Object?> get props => [];
}

class RemoveItensEvent extends HomeEvent {
  final String id;
  RemoveItensEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class ChangeSharedParamsEvent extends HomeEvent {
  final bool? isAllData;

  ChangeSharedParamsEvent(this.isAllData);

  @override
  List<Object?> get props => [isAllData];
}

class ShareEvent extends HomeEvent {
  final String startDate;
  final String endDate;
  ShareEvent(this.startDate, this.endDate);
  @override
  List<Object?> get props => [startDate, endDate];
}
