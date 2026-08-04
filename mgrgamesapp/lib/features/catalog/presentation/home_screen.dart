import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/common_widgets.dart';
import 'catalog_cubit.dart';
import 'widgets/game_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<CatalogCubit>();
    if (cubit.state.games.isEmpty) cubit.loadGames();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('GameHub')),
      body: BlocBuilder<CatalogCubit, CatalogState>(
        builder: (context, state) {
          switch (state.status) {
            case CatalogStatus.initial:
            case CatalogStatus.loading:
              return const LoadingView();
            case CatalogStatus.error:
              return ErrorView(
                message: state.errorMessage ?? 'Có lỗi xảy ra.',
                onRetry: () => context.read<CatalogCubit>().loadGames(refresh: true),
              );
            case CatalogStatus.loaded:
              final games = state.games;
              return ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Nổi bật', style: theme.textTheme.titleLarge),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 260,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: games.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final game = games[index];
                        return SizedBox(
                          width: 160,
                          child: GameCard(
                            game: game,
                            onTap: () => context.push('/game/${game.id}'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
          }
        },
      ),
    );
  }
}