import 'package:equatable/equatable.dart';

class CreateTicketLine extends Equatable {
  const CreateTicketLine({
    required this.label,
    required this.amount,
    required this.prize,
    this.subGameId,
    this.subGameName,
  });

  final String label;
  final int amount;
  final int prize;
  final String? subGameId;
  final String? subGameName;

  Map<String, dynamic> toJson() => {
        'label': label,
        'amount': amount,
        'prize': prize,
        if (subGameId != null) 'subGameId': subGameId,
        if (subGameName != null) 'subGameName': subGameName,
      };

  @override
  List<Object?> get props => [label, amount, prize, subGameId, subGameName];
}

class CreateTicketRequest extends Equatable {
  const CreateTicketRequest({
    required this.gameId,
    required this.salePointId,
    required this.lines,
    this.client,
    this.drawAt,
  });

  final String gameId;
  final String salePointId;
  final List<CreateTicketLine> lines;
  final String? client;
  final DateTime? drawAt;

  Map<String, dynamic> toJson() => {
        'gameId': gameId,
        'salePointId': salePointId,
        if (client != null) 'client': client,
        'lines': lines.map((l) => l.toJson()).toList(),
        if (drawAt != null) 'drawAt': drawAt!.toUtc().toIso8601String(),
      };

  @override
  List<Object?> get props => [gameId, salePointId, lines, client, drawAt];
}
