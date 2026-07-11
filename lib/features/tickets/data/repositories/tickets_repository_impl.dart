import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/create_ticket_request.dart';
import '../../domain/entities/ticket_receipt.dart';
import '../../domain/repositories/tickets_repository.dart';
import '../datasources/tickets_remote_datasource.dart';

class TicketsRepositoryImpl implements TicketsRepository {
  const TicketsRepositoryImpl({required this.remote});

  final TicketsRemoteDatasource remote;

  @override
  Future<Either<Failure, TicketReceipt>> create(
    CreateTicketRequest request,
  ) async {
    try {
      final receipt = await remote.create(request);
      return Right(receipt);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
