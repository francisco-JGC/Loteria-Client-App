import '../../domain/entities/tickets_summary.dart';

class TicketsSummaryModel extends TicketsSummary {
  const TicketsSummaryModel({
    required super.ticketCount,
    required super.voidedCount,
    required super.paidCount,
    required super.billed,
    required super.paidPrize,
  });

  factory TicketsSummaryModel.fromJson(Map<String, dynamic> json) {
    return TicketsSummaryModel(
      ticketCount: (json['ticketCount'] as num).toInt(),
      voidedCount: (json['voidedCount'] as num).toInt(),
      paidCount: (json['paidCount'] as num).toInt(),
      billed: (json['billed'] as num).toInt(),
      paidPrize: (json['paidPrize'] as num).toInt(),
    );
  }
}
