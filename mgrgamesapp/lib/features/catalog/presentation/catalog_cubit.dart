import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/app_exception.dart';
import '../domain/catalog_repository.dart';
import '../domain/game.dart';

enum CatalogStatus { initial, loading, loaded, error }

class CatalogState extends Equatable {
  const CatalogState({
    this.status = CatalogStatus.initial,
    this.games = const [],
    this.query = '',
    this.errorMessage,
  });

  final CatalogStatus status;
  final List<Game> games;
  final String query;
  final String? errorMessage;

  CatalogState copyWith({
    CatalogStatus? status,
    List<Game>? games,
    String? query,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CatalogState(
      status: status ?? this.status,
      games: games ?? this.games,
      query: query ?? this.query,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, games, query, errorMessage];
}

class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit(this._repository) : super(const CatalogState());

  final CatalogRepository _repository;
  Timer? _debounce;

  Future<void> loadGames({bool refresh = false}) async {
    if (state.status == CatalogStatus.loading && !refresh) return;
    emit(state.copyWith(status: CatalogStatus.loading, clearError: true));
    try {
      final games = await _repository.getGames(
        query: state.query.isEmpty ? null : state.query,
      );
      emit(state.copyWith(status: CatalogStatus.loaded, games: games));
    } on AppException catch (e) {
      emit(state.copyWith(status: CatalogStatus.error, errorMessage: e.message));
    }
  }

  /// Debounce 400ms theo SRS-CAT-02
  void onQueryChanged(String query) {
    emit(state.copyWith(query: query));
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      loadGames(refresh: true);
    });
  }
}