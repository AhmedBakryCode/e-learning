import 'package:equatable/equatable.dart';

class Head extends Equatable {
  final String id;
  final String title;
  final String name;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Head({
    required this.id,
    required this.title,
    required this.name,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, title, name, imageUrl, createdAt, updatedAt];
}
