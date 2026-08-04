import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/common_widgets.dart';
import 'catalog_cubit.dart';
import 'widgets/game_card.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});
  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<CatalogCubit>();
    if (cubit.state.games.isEmpty) cubit.loadGames();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kho game')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: context.read<CatalogCubit>().onQueryChanged,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm game...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<CatalogCubit>().onQueryChanged('');
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<CatalogCubit, CatalogState>(
              builder: (context, state) {
                switch (state.status) {
                  case CatalogStatus.initial:
                  case CatalogStatus.loading:
                    return const LoadingView();
                  case CatalogStatus.error:
                    return ErrorView(
                      message: state.errorMessage ?? 'Có lỗi xảy ra.',
                      onRetry: () =>
                          context.read<CatalogCubit>().loadGames(refresh: true),
                    );
                  case CatalogStatus.loaded:
                    if (state.games.isEmpty) {
                      return EmptyView(
                        message: state.query.isEmpty
                            ? 'Chưa có game nào.'
                            : 'Không tìm thấy “${state.query}”.',
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () =>
                          context.read<CatalogCubit>().loadGames(refresh: true),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.62,
                        ),
                        itemCount: state.games.length,
                        itemBuilder: (context, index) {
                          final game = state.games[index];
                          return GameCard(
                            game: game,
                            onTap: () => context.push('/game/${game.id}'),
                          );
                        },
                      ),
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}