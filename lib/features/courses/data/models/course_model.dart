import 'package:e_learning/features/courses/domain/entities/course.dart';

class CourseModel extends Course {
  const CourseModel({
    required super.id,
    required super.title,
    required super.description,
    required super.instructorName,
    required super.category,
    required super.level,
    required super.duration,
    required super.totalLessons,
    required super.enrolledCount,
    required super.rating,
    required super.completionPercent,
    required super.isFeatured,
    required super.isPublished,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      instructorName: json['instructorName'] as String,
      category: json['category'] as String,
      level: json['level'] as String,
      duration: json['duration'] as String,
      totalLessons: json['totalLessons'] as int,
      enrolledCount: json['enrolledCount'] as int,
      rating: (json['rating'] as num).toDouble(),
      completionPercent: (json['completionPercent'] as num).toDouble(),
      isFeatured: json['isFeatured'] as bool,
      isPublished: json['isPublished'] as bool,
    );
  }

  @override
  CourseModel copyWith({
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
  }) {
    return CourseModel(
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'instructorName': instructorName,
      'category': category,
      'level': level,
      'duration': duration,
      'totalLessons': totalLessons,
      'enrolledCount': enrolledCount,
      'rating': rating,
      'completionPercent': completionPercent,
      'isFeatured': isFeatured,
      'isPublished': isPublished,
    };
  }
}
