part of 'home_bloc.dart';

class HomeState extends Equatable {
  final PagingState<int, Note>? pagingState;
  final bool isEditing;
  final bool isAllData;

  const HomeState({
    this.pagingState,
    this.isEditing = false,
    this.isAllData = false,
  });

  HomeState copyWith({
    PagingState<int, Note>? pagingState,
    bool? isEditing,
    bool? isAllData,
  }) {
    return HomeState(
      pagingState: pagingState ?? this.pagingState,
      isEditing: isEditing ?? this.isEditing,
      isAllData: isAllData ?? this.isAllData,
    );
  }

  @override
  List<Object?> get props => [pagingState.hashCode, isEditing, isAllData];
}
