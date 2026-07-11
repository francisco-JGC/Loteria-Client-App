import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/create_ticket_request.dart';
import '../entities/ticket_receipt.dart';

abstract interface class TicketsRepository {
  Future<Either<Failure, TicketReceipt>> create(CreateTicketRequest request);
}
