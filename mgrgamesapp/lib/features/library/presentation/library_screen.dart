import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/common_widgets.dart';
import '../../catalog/data/mock_data.dart';
import '../../download/download_manager.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Thư viện')),
      body: BlocBuilder<DownloadManager, DownloadState>(
        builder: (context, state) {
          final games = mockGames()
              .where((g) => g.owned || state.installedIds.contains(g.id))
              .toList();

          if (games.isEmpty) {
            return const EmptyView(message: 'Thư viện của bạn đang trống.');
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: games.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final game = games[index];
              final installed = state.installedIds.contains(game.id);
              final task = state.tasks[game.id];

              return Card(
                child: ListTile(
                  onTap: () => context.push('/game/${game.id}'),
                  leading: const Icon(Icons.games),
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