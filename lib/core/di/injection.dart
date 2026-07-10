import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/games/data/datasources/games_local_datasource.dart';
import '../../features/games/data/repositories/games_repository_impl.dart';
import '../../features/games/domain/repositories/games_repository.dart';
import '../../features/games/domain/usecases/get_authorized_games.dart';
import '../network/dio_client.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerLazySingleton<Logger>(Logger.new);

  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  getIt.registerLazySingleton<DioClient>(() => DioClient(logger: getIt()));

  _registerGamesFeature();
}

void _registerGamesFeature() {
  getIt
    ..registerLazySingleton<GamesLocalDatasource>(
      GamesLocalDatasourceImpl.new,
    )
    ..registerLazySingleton<GamesRepository>(
      () => GamesRepositoryImpl(local: getIt()),
    )
    ..registerFactory<GetAuthorizedGames>(
      () => GetAuthorizedGames(repository: getIt()),
    );
}
