import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/features/students/domain/entities/student.dart';
import 'package:equatable/equatable.dart';

class StudentsState extends Equatable {
  const StudentsState({
    this.status = ViewStateStatus.initial,
    this.actionStatus = ViewStateStatus.initial,
    this.students = const [],
    this.selectedStudent,
    this.errorMessage,
    this.actionMessage,
    this.searchQuery = '',
  });

  final ViewStateStatus status;
  final ViewStateStatus actionStatus;
  final List<Student> students;
  final Student? selectedStudent;
  final String? errorMessage;
  final String? actionMessage;
  final String searchQuery;

  StudentsState copyWith({
    ViewStateStatus? status,
    ViewStateStatus? actionStatus,
    List<Student>? students,
    Student? selectedStudent,
    String? errorMessage,
    String? actionMessage,
    String? searchQuery,
    bool clearErrorMessage = false,
    bool clearActionMessage = false,
    bool clearSelectedStudent = false,
  }) {
    return StudentsState(
      status: status ?? this.status,
      actionStatus: actionStatus ?? this.actionStatus,
      students: students ?? this.students,
      selectedStudent: clearSelectedStudent
          ? null
          : selectedStudent ?? this.selectedStudent,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      actionMessage: clearActionMessage
          ? null
          : actionMessage ?? this.actionMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    status,
    actionStatus,
    students,
    selectedStudent,
    errorMessage,
    actionMessage,
    searchQuery,
  ];
}
