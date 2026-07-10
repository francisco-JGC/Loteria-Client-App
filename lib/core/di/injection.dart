import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/games/data/datasources/games_local_datasource.dart';
import '../../features/games/data/repositories/games_repository_impl.dart';
import '../../features/games/domain/repositories/games_repository.dart';
import '../../features/games/domain/usecases/get_authorized_games.dart';
import '../../features/printer/data/datasources/printer_bluetooth_datasource.dart';
import '../../features/printer/data/repositories/printer_repository_impl.dart';
import '../../features/printer/domain/repositories/printer_repository.dart';
import '../../features/printer/domain/usecases/connect_printer.dart';
import '../../features/printer/domain/usecases/disconnect_printer.dart';
import '../../features/printer/domain/usecases/get_paired_printers.dart';
import '../../features/printer/domain/usecases/print_test.dart';
import '../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/get_billing_method.dart';
import '../../features/settings/domain/usecases/set_billing_method.dart';
import '../network/dio_client.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerLazySingleton<Logger>(Logger.new);

  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  getIt.registerLazySingleton<DioClient>(() => DioClient(logger: getIt()));

  _registerGamesFeature();
  _registerSettingsFeature();
  _registerPrinterFeature();
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

void _registerSettingsFeature() {
  getIt
    ..registerLazySingleton<SettingsLocalDatasource>(
      () => SettingsLocalDatasourceImpl(prefs: getIt()),
    )
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(local: getIt()),
    )
    ..registerFactory<GetBillingMethod>(
      () => GetBillingMethod(repository: getIt()),
    )
    ..registerFactory<SetBillingMethod>(
      () => SetBillingMethod(repository: getIt()),
    );
}

void _registerPrinterFeature() {
  getIt
    ..registerLazySingleton<PrinterBluetoothDatasource>(
      PrinterBluetoothDatasourceImpl.new,
    )
    ..registerLazySingleton<PrinterRepository>(
      () => PrinterRepositoryImpl(datasource: getIt()),
    )
    ..registerFactory<GetPairedPrinters>(
      () => GetPairedPrinters(repository: getIt()),
    )
    ..registerFactory<ConnectPrinter>(
      () => ConnectPrinter(repository: getIt()),
    )
    ..registerFactory<DisconnectPrinter>(
      () => DisconnectPrinter(repository: getIt()),
    )
    ..registerFactory<PrintTest>(
      () => PrintTest(repository: getIt()),
    );
}
