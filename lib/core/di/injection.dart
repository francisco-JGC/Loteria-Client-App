import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/load_session.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/games/data/datasources/games_local_datasource.dart';
import '../../features/games/data/datasources/games_remote_datasource.dart';
import '../../features/games/data/repositories/games_repository_impl.dart';
import '../../features/games/domain/repositories/games_repository.dart';
import '../../features/games/domain/usecases/get_authorized_games.dart';
import '../../features/printer/data/datasources/printer_bluetooth_datasource.dart';
import '../../features/printer/data/datasources/printer_local_datasource.dart';
import '../../features/printer/data/repositories/printer_repository_impl.dart';
import '../../features/printer/domain/repositories/printer_repository.dart';
import '../../features/printer/domain/usecases/connect_printer.dart';
import '../../features/printer/domain/usecases/disconnect_printer.dart';
import '../../features/printer/domain/usecases/get_paired_printers.dart';
import '../../features/printer/domain/usecases/print_test.dart';
import '../../features/printer/domain/usecases/print_ticket.dart';
import '../../features/sale_points/data/datasources/sale_points_local_datasource.dart';
import '../../features/sale_points/data/datasources/sale_points_remote_datasource.dart';
import '../../features/sale_points/data/repositories/sale_points_repository_impl.dart';
import '../../features/sale_points/domain/repositories/sale_points_repository.dart';
import '../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/get_billing_method.dart';
import '../../features/settings/domain/usecases/set_billing_method.dart';
import '../../features/tickets/data/datasources/tickets_remote_datasource.dart';
import '../../features/tickets/data/repositories/tickets_repository_impl.dart';
import '../../features/tickets/domain/repositories/tickets_repository.dart';
import '../../features/tickets/domain/usecases/create_ticket.dart';
import '../network/dio_client.dart';
import '../network/session_events.dart';
import '../network/token_store.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerLazySingleton<Logger>(Logger.new);

  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  getIt.registerLazySingleton<TokenStore>(TokenStore.new);
  getIt.registerLazySingleton<SessionEvents>(SessionEvents.new);

  getIt.registerLazySingleton<DioClient>(
    () => DioClient(
      tokenStore: getIt(),
      logger: getIt(),
      onUnauthorized: () => getIt<SessionEvents>().emitExpired(),
    ),
  );

  _registerAuthFeature();
  _registerGamesFeature();
  _registerSalePointsFeature();
  _registerTicketsFeature();
  _registerSettingsFeature();
  _registerPrinterFeature();
}

void _registerAuthFeature() {
  getIt
    ..registerLazySingleton<AuthRemoteDatasource>(
      () => AuthRemoteDatasourceImpl(client: getIt()),
    )
    ..registerLazySingleton<AuthLocalDatasource>(
      () => AuthLocalDatasourceImpl(storage: getIt()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remote: getIt(),
        local: getIt(),
        tokenStore: getIt(),
      ),
    )
    ..registerFactory<Login>(() => Login(repository: getIt()))
    ..registerFactory<Logout>(() => Logout(repository: getIt()))
    ..registerFactory<LoadSession>(() => LoadSession(repository: getIt()));
}

void _registerGamesFeature() {
  getIt
    ..registerLazySingleton<GamesRemoteDatasource>(
      () => GamesRemoteDatasourceImpl(client: getIt()),
    )
    ..registerLazySingleton<GamesLocalDatasource>(
      () => GamesLocalDatasourceImpl(prefs: getIt()),
    )
    ..registerLazySingleton<GamesRepository>(
      () => GamesRepositoryImpl(remote: getIt(), local: getIt()),
    )
    ..registerFactory<GetAuthorizedGames>(
      () => GetAuthorizedGames(repository: getIt()),
    );
}

void _registerSalePointsFeature() {
  getIt
    ..registerLazySingleton<SalePointsRemoteDatasource>(
      () => SalePointsRemoteDatasourceImpl(client: getIt()),
    )
    ..registerLazySingleton<SalePointsLocalDatasource>(
      () => SalePointsLocalDatasourceImpl(prefs: getIt()),
    )
    ..registerLazySingleton<SalePointsRepository>(
      () => SalePointsRepositoryImpl(remote: getIt(), local: getIt()),
    );
}

void _registerTicketsFeature() {
  getIt
    ..registerLazySingleton<TicketsRemoteDatasource>(
      () => TicketsRemoteDatasourceImpl(client: getIt()),
    )
    ..registerLazySingleton<TicketsRepository>(
      () => TicketsRepositoryImpl(remote: getIt()),
    )
    ..registerFactory<CreateTicket>(
      () => CreateTicket(repository: getIt()),
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
    ..registerLazySingleton<PrinterLocalDatasource>(
      () => PrinterLocalDatasourceImpl(prefs: getIt()),
    )
    ..registerLazySingleton<PrinterRepository>(
      () => PrinterRepositoryImpl(datasource: getIt(), local: getIt()),
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
    )
    ..registerFactory<PrintTicket>(
      () => PrintTicket(repository: getIt()),
    );
}
