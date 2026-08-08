import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/injection.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../download/download_manager.dart';
import '../../library/domain/library_repository.dart';
import '../domain/catalog_repository.dart';
import '../domain/game.dart';

class GameDetailScreen extends StatefulWidget {
  const GameDetailScreen({super.key, required this.id});
  final String id;

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  late Future<Game> _future;

  @override
  void initState() {
    super.initState();
    _future = getIt<CatalogRepository>().getGameDetail(widget.id);
  }

  void _reload() {
    setState(() {
      _future = getIt<CatalogRepository>().getGameDetail(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Game>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: LoadingView());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          final error = snapshot.error;
          return Scaffold(
            appBar: AppBar(),
            body: ErrorView(
              message: error is AppException
                  ? error.message
                  : 'Không tải được game.',
              code: error is AppException ? error.code : null,
              onRetry: _reload,
            ),
          );
        }
        return _DetailBody(game: snapshot.data!, onLibraryChanged: _reload);
      },
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.game, required this.onLibraryChanged});
  final Game game;
  final VoidCallback onLibraryChanged;

  Future<void> _addToLibrary(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await getIt<LibraryRepository>().addToLibrary(game.id);
      messenger.showSnackBar(
        const SnackBar(content: Text('Đã thêm vào thư viện.')),
      );
      onLibraryChanged();
    } on AppException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _play(BuildContext context) async {
    // Mobile: khởi chạy game bằng deep link (SRS-DL-08)
    final uri = Uri.parse('gamehub://play/${game.id}');
    try {
      await launchUrl(uri);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chưa cài game hoặc không mở được game.')),
        );
      }
    }
  }

  Widget _buildCta(BuildContext context) {
    final dm = context.watch<DownloadManager>();
    final task = dm.state.tasks[game.id];
    final installed = dm.state.installedIds.contains(game.id);

    if (task != null && task.status == DownloadStatus.downloading) {
      return Column(
        children: [
          LinearProgressIndicator(value: task.progress),
          const SizedBox(height: 8),
          Text('Đang tải ${(task.progress * 100).toInt()}%...'),
        ],
      );
    }

    if (installed) {
      return FilledButton.icon(
        onPressed: () => _play(context),
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Chơi'),
      );
    }

    if (!game.owned && game.priceType == PriceType.free) {
      return FilledButton.icon(
        onPressed: () => _addToLibrary(context),
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        icon: const Icon(Icons.library_add_outlined),
        label: const Text('Thêm vào thư viện'),
      );
    }

    if (game.owned) {
      return FilledButton.icon(
        onPressed: () => dm.start(game),
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        icon: const Icon(Icons.download),
        label: Text('Tải xuống${game.sizeGb != null ? ' – ${game.sizeGb!.toStringAsFixed(1)} GB' : ''}'),
      );
    }

    return FilledButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thanh toán sẽ tích hợp ở giai đoạn 2.')),
        );
      },
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
      child: Text('Mua – ${game.priceLabel}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: game.banner != null
                  ? CachedNetworkImage(
                      imageUrl: game.banner!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          Container(color: theme.colorScheme.surface),
                    )
                  : Container(color: theme.colorScheme.surface),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(game.name, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...game.genres.map((g) => Chip(label: Text(g))),
                      ...game.platforms.map((p) => InputChip(label: Text(p))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildCta(context),
                  const SizedBox(height: 24),
                  Text('Giới thiệu', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(game.shortDescription,
                      style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}