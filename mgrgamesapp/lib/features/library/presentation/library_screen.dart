import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../catalog/domain/game.dart';
import '../../download/download_manager.dart';
import '../domain/library_repository.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late final LibraryRepository _libraryRepo;
  List<Game>? _games;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _libraryRepo = getIt<LibraryRepository>();
    _loadLibrary();
  }

  Future<void> _loadLibrary() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final games = await _libraryRepo.getMyLibrary();
      setState(() {
        _games = games;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thư viện'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLibrary,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Lỗi: $_error'))
              : _games == null || _games!.isEmpty
                  ? const EmptyView(message: 'Thư viện của bạn đang trống.')
                  : BlocBuilder<DownloadManager, DownloadState>(
                      builder: (context, state) {
                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _games!.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final game = _games![index];
                            final installed = state.installedIds.contains(game.id);
                            final task = state.tasks[game.id];

                            return Card(
                              child: ListTile(
                                onTap: () => context.push('/game/${game.id}'),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    game.thumbnail ?? '',
                                    width: 60,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.games, size: 40),
                                  ),
                                ),
                                title: Text(game.name),
                                subtitle: task != null &&
                                        task.status == DownloadStatus.downloading
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          LinearProgressIndicator(value: task.progress),
                                          const SizedBox(height: 4),
                                          Text('Đang tải ${(task.progress * 100).toInt()}%'),
                                        ],
                                      )
                                    : Text(installed ? 'Đã cài' : 'Chưa cài'),
                                trailing: installed
                                    ? FilledButton.tonal(
                                        onPressed: () {},
                                        child: const Text('Chơi'),
                                      )
                                    : FilledButton(
                                        onPressed: () =>
                                            context.read<DownloadManager>().start(game),
                                        child: const Text('Tải'),
                                      ),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}