import 'package:flutter_test/flutter_test.dart';
import 'package:loteria_client_app/core/errors/failures.dart';
import 'package:loteria_client_app/features/games/data/datasources/games_local_datasource.dart';
import 'package:loteria_client_app/features/games/data/models/game_model.dart';
import 'package:loteria_client_app/features/games/data/repositories/games_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class _MockDatasource extends Mock implements GamesLocalDatasource {}

void main() {
  late _MockDatasource datasource;
  late GamesRepositoryImpl repository;

  setUp(() {
    datasource = _MockDatasource();
    repository = GamesRepositoryImpl(local: datasource);
  });

  test('returns Right with games from datasource', () async {
    const games = [GameModel(id: 'diaria', name: 'Diaria')];
    when(() => datasource.getAuthorizedGames())
        .thenAnswer((_) async => games);

    final result = await repository.getAuthorizedGames();

    expect(result.isRight(), isTrue);
    result.match(
      (_) => fail('expected Right'),
      (list) => expect(list, games),
    );
  });

  test('returns Left(UnexpectedFailure) when datasource throws', () async {
    when(() => datasource.getAuthorizedGames()).thenThrow(Exception('boom'));

    final result = await repository.getAuthorizedGames();

    expect(result.isLeft(), isTrue);
    result.match(
      (f) => expect(f, isA<UnexpectedFailure>()),
      (_) => fail('expected Left'),
    );
  });
}
