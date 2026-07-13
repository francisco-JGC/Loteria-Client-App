import 'package:equatable/equatable.dart';

class MovementsSummary extends Equatable {
  const MovementsSummary({
    required this.billed,
    required this.collected,
    required this.paidPrize,
    required this.expenses,
    required this.salary,
  });

  final int billed;
  final int collected;
  final int paidPrize;
  final int expenses;
  final int salary;

  int get remaining => collected - paidPrize - expenses - salary;

  MovementsSummary copyWith({
    int? billed,
    int? collected,
    int? paidPrize,
    int? expenses,
    int? salary,
  }) {
    return MovementsSummary(
      billed: billed ?? this.billed,
      collected: collected ?? this.collected,
      paidPrize: paidPrize ?? this.paidPrize,
      expenses: expenses ?? this.expenses,
      salary: salary ?? this.salary,
    );
  }

  static const empty =
      MovementsSummary(billed: 0, collected: 0, paidPrize: 0, expenses: 0, salary: 0);

  @override
  List<Object?> get props => [billed, collected, paidPrize, expenses, salary];
}
