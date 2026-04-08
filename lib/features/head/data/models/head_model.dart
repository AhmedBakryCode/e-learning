import 'package:e_learning/features/head/domain/entities/head.dart';

class HeadModel extends Head {
  const HeadModel({
    required super.id,
    required super.title,
    required super.name,
    required super.imageUrl,
    required super.createdAt,
    required super.updatedAt,
  });

  factory HeadModel.fromJson(Map<String, dynamic> json) {
    return HeadModel(
      id: json['id'] as String,
      title: json['title'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'name': name,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
