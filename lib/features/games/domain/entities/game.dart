import 'package:equatable/equatable.dart';

class Game extends Equatable {
  const Game({
    required this.id,
    required this.name,
    this.imagePath,
    this.isEnabled = true,
  });

  final String id;
  final String name;
  final String? imagePath;
  final bool isEnabled;

  @override
  List<Object?> get props => [id, name, imagePath, isEnabled];
}
