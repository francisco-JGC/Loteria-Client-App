import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/create_ticket_request.dart';
import '../entities/list_tickets_query.dart';
import '../entities/ticket_receipt.dart';
import '../entities/ticket_summary.dart';

abstract interface class TicketsRepository {
  Future<Either<Failure, TicketReceipt>> create(CreateTicketRequest request);
  Future<Either<Failure, ListTicketsResult>> list(ListTicketsQuery query);
  Future<Either<Failure, TicketSummary>> voidTicket({
    required String id,
    required String reason,
  });
}
