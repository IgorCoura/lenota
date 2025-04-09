import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lenotaapp/modules/home/domain/note.dart';
import 'package:lenotaapp/modules/home/service/home_service.dart';
import 'package:share_plus/share_plus.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final int _pageSize = 15;
  final HomeService homeService;

  HomeBloc(this.homeService) : super(const HomeState()) {
    on<InitialEvent>(_onInitialEvent);
    on<FeatchNextPage>(_onFeatchNextPage);
    on<EditItensEvent>(_onEditItensEvent);
    on<RemoveItensEvent>(_onRemoveItensEvent);
    on<ChangeSharedParamsEvent>(_onChangeSharedParamsEvent);
    on<ShareEvent>(_onShareEvent);
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
      final List<Note> newItems = await homeService.getScanners(
        _pageSize,
        state.pagingState!.keys?.last ?? 0,
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

  Future _onEditItensEvent(
      EditItensEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(isEditing: !state.isEditing));
  }

  Future _onRemoveItensEvent(
      RemoveItensEvent event, Emitter<HomeState> emit) async {
    homeService.removeScannerById(event.id);
    add(FeatchNextPage());
  }

  Future _onChangeSharedParamsEvent(
      ChangeSharedParamsEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(isAllData: event.isAllData));
  }

  Future _onShareEvent(ShareEvent event, Emitter<HomeState> emit) async {
    if (!state.isAllData &&
        (event.startDate.isEmpty || event.endDate.isEmpty)) {
      return;
    }

    var text = "";

    if (state.isAllData) {
      final List<Note> notes = await homeService.getScanners(0, 0);
      text = Note.listToCsv(notes);
    } else {
      var startDate =
          DateTime.parse(event.startDate.split('/').reversed.join('-'));
      var endDate = DateTime.parse(event.endDate.split('/').reversed.join('-'));
      final List<Note> notes =
          await homeService.getScannersByDateRange(startDate, endDate);
      text = Note.listToCsv(notes);
    }

    Share.shareXFiles(
        [XFile.fromData(utf8.encode(text), mimeType: 'text/plain')],
        fileNameOverrides: ['dados.csv']);
  }
}
