import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/game.dart';
import '../../domain/repositories/games_repository.dart';
import '../datasources/games_local_datasource.dart';

class GamesRepositoryImpl implements GamesRepository {
  const GamesRepositoryImpl({required this.local});

  final GamesLocalDatasource local;

  @override
  Future<Either<Failure, List<Game>>> getAuthorizedGames() async {
    try {
      final games = await local.getAuthorizedGames();
      return Right(games);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
