import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../app/router/app_router.dart';
import '../../features/auth/data/auth_repository_impl.dart';
import '../../features/auth/data/mock_auth_repository.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/presentation/auth_cubit.dart';
import '../../features/catalog/data/catalog_repository_impl.dart';
import '../../features/catalog/data/mock_catalog_repository.dart';
import '../../features/catalog/domain/catalog_repository.dart';
import '../../features/catalog/presentation/catalog_cubit.dart';
import '../../features/download/download_manager.dart';
import '../constants/api_constants.dart';
import '../network/api_client.dart';
import '../storage/token_storage.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // Storage
  getIt.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage());
  getIt.registerLazySingleton<TokenStorage>(
      () => TokenStorage(getIt<FlutterSecureStorage>()));

  // Network
  getIt.registerLazySingleton<Dio>(() => createDio(getIt<TokenStorage>()));

  // Repositories (mock hoặc thật)
  if (ApiConstants.useMock) {
    getIt.registerLazySingleton<AuthRepository>(() => MockAuthRepository());
    getIt.registerLazySingleton<CatalogRepository>(
        () => MockCatalogRepository());
  } else {
    getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(getIt<Dio>(), getIt<TokenStorage>()));
    getIt.registerLazySingleton<CatalogRepository>(
        () => CatalogRepositoryImpl(getIt<Dio>()));
  }

  // State
  getIt.registerLazySingleton<AuthCubit>(
      () => AuthCubit(getIt<AuthRepository>(), getIt<TokenStorage>())
        ..bootstrap());
  getIt.registerLazySingleton<CatalogCubit>(
      () => CatalogCubit(getIt<CatalogRepository>()));
  getIt.registerLazySingleton<DownloadManager>(
      () => DownloadManager(getIt<Dio>()));

  // Router
  getIt.registerLazySingleton<AppRouter>(() => AppRouter(getIt<AuthCubit>()));
}