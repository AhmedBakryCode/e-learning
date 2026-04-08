import 'package:equatable/equatable.dart';

class Course extends Equatable {
  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructorName,
    required this.category,
    required this.level,
    required this.duration,
    required this.totalLessons,
    required this.enrolledCount,
    required this.rating,
    required this.completionPercent,
    required this.isFeatured,
    required this.isPublished,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String description;
  final String instructorName;
  final String category;
  final String level;
  final String duration;
  final int totalLessons;
  final int enrolledCount;
  final double rating;
  final double completionPercent;
  final bool isFeatured;
  final bool isPublished;
  final String? imageUrl;

  Course copyWith({
    String? id,
    String? title,
    String? description,
    String? instructorName,
    String? category,
    String? level,
    String? duration,
    int? totalLessons,
    int? enrolledCount,
    double? rating,
    double? completionPercent,
    bool? isFeatured,
    bool? isPublished,
    String? imageUrl,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      instructorName: instructorName ?? this.instructorName,
      category: category ?? this.category,
      level: level ?? this.level,
      duration: duration ?? this.duration,
      totalLessons: totalLessons ?? this.totalLessons,
      enrolledCount: enrolledCount ?? this.enrolledCount,
      rating: rating ?? this.rating,
      completionPercent: completionPercent ?? this.completionPercent,
      isFeatured: isFeatured ?? this.isFeatured,
      isPublished: isPublished ?? this.isPublished,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    instructorName,
    category,
    level,
    duration,
    totalLessons,
    enrolledCount,
    rating,
    completionPercent,
    isFeatured,
    isPublished,
    imageUrl,
  ];
}
