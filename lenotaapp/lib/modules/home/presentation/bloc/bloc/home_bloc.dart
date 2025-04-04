import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lenotaapp/modules/home/domain/note.dart';
import 'package:meta/meta.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final int _pageSize = 15;

  HomeBloc() : super(const HomeState()) {
    on<InitialEvent>(_onInitialEvent);
    on<FeatchNextPage>(_onFeatchNextPage);
  }

  _onInitialEvent(InitialEvent event, Emitter<HomeState> emit) {
    emit(state.copyWith(
        pagingState: PagingState<int, Note>(isLoading: false, error: null)));
  }

  Future _onFeatchNextPage(
      FeatchNextPage event, Emitter<HomeState> emit) async {
    if (state.pagingState == null) {
      return;
    }

    if (state.pagingState!.isLoading) return;

    emit(state.copyWith(
        pagingState:
            state.pagingState!.copyWith(isLoading: true, error: null)));

    try {
      final List<Note> newItems = List.generate(
        _pageSize,
        (index) => Note(
          id: ((state.pagingState?.keys?.last ?? 0) + index + 1).toString(),
          title: 'Note ${(state.pagingState?.keys?.last ?? 0) + index + 1}',
          content:
              'Content for note ${(state.pagingState?.keys?.last ?? 0) + index + 1}',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      final isLastPage = newItems.length < _pageSize;
      final newKey = (state.pagingState!.keys?.last ?? 0) + _pageSize;
      emit(
        state.copyWith(
          pagingState: state.pagingState!.copyWith(
            isLoading: false,
            error: null,
            pages: [...?state.pagingState!.pages, newItems],
            keys: [...?state.pagingState!.keys, newKey],
            hasNextPage: !isLastPage,
          ),
        ),
      );
    } catch (ex, stacktrace) {
      //TODO: Implementar o tratamento de erro
    }
  }
}
