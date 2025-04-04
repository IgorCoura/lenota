part of 'home_bloc.dart';

class HomeState extends Equatable {
  final PagingState<int, Note>? pagingState;

  const HomeState({
    this.pagingState,
  });

  HomeState copyWith({
    PagingState<int, Note>? pagingState,
  }) {
    return HomeState(
      pagingState: pagingState ?? this.pagingState,
    );
  }

  @override
  List<Object?> get props => [pagingState.hashCode];
}
