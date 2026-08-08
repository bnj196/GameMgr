import 'dart:async';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/constants/api_constants.dart';
import '../catalog/domain/catalog_repository.dart';
import '../catalog/domain/game.dart';

enum DownloadStatus { queued, downloading, paused, completed, failed }

class DownloadTask {
  DownloadTask({required this.gameId, required this.title});

  final String gameId;
  final String title;
  DownloadStatus status = DownloadStatus.queued;
  double progress = 0;
}

class DownloadState extends Equatable {
  const DownloadState({this.tasks = const {}, this.installedIds = const {}});

  final Map<String, DownloadTask> tasks;
  final Set<String> installedIds;

  @override
  List<Object?> get props => [tasks, installedIds];
}

class DownloadManager extends Cubit<DownloadState> {
  DownloadManager(this._catalogRepository) : super(const DownloadState());

  final CatalogRepository _catalogRepository;

  /// Dio riêng cho CDN: không gắn baseUrl/Authorization của backend
  final Dio _downloadDio = Dio();
  final Map<String, Timer> _mockTimers = {};

  Future<void> start(Game game) async {
    if (state.tasks.containsKey(game.id)) return;

    final task = DownloadTask(gameId: game.id, title: game.name);
    _emit(tasks: {...state.tasks, game.id: task});

    if (ApiConstants.useMock) {
      _simulate(task);
      return;
    }

    try {
      // 1. Lấy link tải từ server (SRS-DL-01)
      final url = await _catalogRepository.getDownloadUrl(game.id);

      // 2. Tải về (SRS-DL-02)
      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/${game.id}.pkg';
      task.status = DownloadStatus.downloading;
      _emit();

      await _downloadDio.download(url, savePath,
          onReceiveProgress: (received, total) {
        if (total > 0) {
          task.progress = received / total;
          _emit();
        }
      });

      // 3. Hoàn tất -> coi như đã cài (SRS-DL-04)
      task.status = DownloadStatus.completed;
      task.progress = 1;
      _emit(markInstalled: game.id);
    } catch (_) {
      task.status = DownloadStatus.failed;
      _emit();
    }
  }

  void _simulate(DownloadTask task) {
    task.status = DownloadStatus.downloading;
    _emit();
    _mockTimers[task.gameId] =
        Timer.periodic(const Duration(milliseconds: 200), (timer) {
      task.progress = (task.progress + 0.05).clamp(0.0, 1.0);
      if (task.progress >= 1) {
        timer.cancel();
        task.status = DownloadStatus.completed;
        _emit(markInstalled: task.gameId);
      } else {
        _emit();
      }
    });
  }

  void cancel(String gameId) {
    _mockTimers[gameId]?.cancel();
    final tasks = {...state.tasks}..remove(gameId);
    _emit(tasks: tasks);
  }

  void _emit({Map<String, DownloadTask>? tasks, String? markInstalled}) {
    final installed = markInstalled != null
        ? {...state.installedIds, markInstalled}
        : state.installedIds;
    emit(DownloadState(
      tasks: tasks ?? {...state.tasks},
      installedIds: installed,
    ));
  }

  @override
  Future<void> close() {
    for (final t in _mockTimers.values) {
      t.cancel();
    }
    return super.close();
  }
}