import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/injection.dart';
import '../features/auth/presentation/auth_cubit.dart';
import '../features/catalog/presentation/catalog_cubit.dart';
import '../features/download/download_manager.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class GameHubApp extends StatelessWidget {
  const GameHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<AuthCubit>()),
        BlocProvider.value(value: getIt<CatalogCubit>()),
        BlocProvider.value(value: getIt<DownloadManager>()),
      ],
      child: MaterialApp.router(
        title: 'GameHub',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark, // Dark là mặc định (theo UI/UX doc)
        routerConfig: getIt<AppRouter>().router,
      ),
    );
  }
}