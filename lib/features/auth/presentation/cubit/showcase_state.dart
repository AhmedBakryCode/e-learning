import 'package:equatable/equatable.dart';
import 'package:e_learning/features/head/domain/entities/head.dart';
import 'package:e_learning/features/students/data/models/student_model.dart';
import 'package:e_learning/core/constants/view_state_status.dart';

class ShowcaseState extends Equatable {
  const ShowcaseState({
    this.status = ViewStateStatus.initial,
    this.heads = const [],
    this.topStudents = const [],
    this.errorMessage,
  });

  final ViewStateStatus status;
  final List<Head> heads;
  final List<StudentModel> topStudents;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, heads, topStudents, errorMessage];

  ShowcaseState copyWith({
    ViewStateStatus? status,
    List<Head>? heads,
    List<StudentModel>? topStudents,
    String? errorMessage,
  }) {
    return ShowcaseState(
      status: status ?? this.status,
      heads: heads ?? this.heads,
      topStudents: topStudents ?? this.topStudents,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
