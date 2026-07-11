import 'package:equatable/equatable.dart';

class SalePoint extends Equatable {
  const SalePoint({
    required this.id,
    required this.name,
    required this.code,
    required this.ownerId,
    required this.isActive,
  });

  final String id;
  final String name;
  final String code;
  final String ownerId;
  final bool isActive;

  @override
  List<Object?> get props => [id, name, code, ownerId, isActive];
}
