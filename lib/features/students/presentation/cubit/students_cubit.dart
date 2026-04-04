import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/students/domain/entities/student.dart';
import 'package:e_learning/features/students/domain/usecases/add_student_course_usecase.dart';
import 'package:e_learning/features/students/domain/usecases/add_student_usecase.dart';
import 'package:e_learning/features/students/domain/usecases/delete_student_usecase.dart';
import 'package:e_learning/features/students/domain/usecases/get_student_by_id_usecase.dart';
import 'package:e_learning/features/students/domain/usecases/get_students_usecase.dart';
import 'package:e_learning/features/students/domain/usecases/get_top_students_usecase.dart';
import 'package:e_learning/features/students/domain/usecases/update_student_usecase.dart';
import 'package:e_learning/features/students/presentation/cubit/students_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentsCubit extends Cubit<StudentsState> {
  StudentsCubit({
    required GetStudentsUseCase getStudents,
    required GetStudentByIdUseCase getStudentById,
    required AddStudentUseCase addStudent,
    required UpdateStudentUseCase updateStudent,
    required DeleteStudentUseCase deleteStudent,
    required AddStudentCourseUseCase addStudentCourse,
    required GetTopStudentsUseCase getTopStudents,
  }) : _getStudents = getStudents,
       _getStudentById = getStudentById,
       _addStudent = addStudent,
       _updateStudent = updateStudent,
       _deleteStudent = deleteStudent,
       _addStudentCourse = addStudentCourse,
       _getTopStudents = getTopStudents,
       super(const StudentsState());

  final GetStudentsUseCase _getStudents;
  final GetStudentByIdUseCase _getStudentById;
  final AddStudentUseCase _addStudent;
  final UpdateStudentUseCase _updateStudent;
  final DeleteStudentUseCase _deleteStudent;
  final AddStudentCourseUseCase _addStudentCourse;
  final GetTopStudentsUseCase _getTopStudents;

  Future<void> loadStudents() async {
    emit(
      state.copyWith(status: ViewStateStatus.loading, clearErrorMessage: true),
    );

    try {
      final students = await _getStudents(const NoParams());
      emit(state.copyWith(status: ViewStateStatus.success, students: students));
    } catch (_) {
      emit(
        state.copyWith(
          status: ViewStateStatus.failure,
          errorMessage: 'Unable to load students right now.',
        ),
      );
    }
  }

  Future<void> loadStudentDetails(String id) async {
    emit(
      state.copyWith(
        status: ViewStateStatus.loading,
        clearErrorMessage: true,
        clearSelectedStudent: true,
      ),
    );

    try {
      final student = await _getStudentById(GetStudentByIdParams(id));
      if (student == null) {
        throw StateError('Student not found');
      }

      emit(
        state.copyWith(
          status: ViewStateStatus.success,
          selectedStudent: student,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ViewStateStatus.failure,
          errorMessage: 'Unable to load student details right now.',
          clearSelectedStudent: true,
        ),
      );
    }
  }

  Future<void> addStudent(AddStudentParams params) async {
    emit(
      state.copyWith(
        actionStatus: ViewStateStatus.loading,
        clearActionMessage: true,
      ),
    );

    try {
      final student = await _addStudent(params);
      emit(
        state.copyWith(
          actionStatus: ViewStateStatus.success,
          actionMessage: 'Student added successfully.',
          selectedStudent: student,
          students: [student, ...state.students],
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          actionStatus: ViewStateStatus.failure,
          actionMessage: 'Unable to add this student right now.',
        ),
      );
    }
  }

  Future<void> updateStudent(UpdateStudentParams params) async {
    emit(
      state.copyWith(
        actionStatus: ViewStateStatus.loading,
        clearActionMessage: true,
      ),
    );

    try {
      final student = await _updateStudent(params);
      emit(
        state.copyWith(
          actionStatus: ViewStateStatus.success,
          actionMessage: 'Student updated successfully.',
          selectedStudent: student,
          students: _replaceStudent(state.students, student),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          actionStatus: ViewStateStatus.failure,
          actionMessage: 'Unable to update this student right now.',
        ),
      );
    }
  }

  Future<void> deleteStudent(String id) async {
    emit(
      state.copyWith(
        actionStatus: ViewStateStatus.loading,
        clearActionMessage: true,
      ),
    );

    try {
      await _deleteStudent(DeleteStudentParams(id));
      emit(
        state.copyWith(
          actionStatus: ViewStateStatus.success,
          actionMessage: 'Student deleted successfully.',
          students: state.students
              .where((student) => student.id != id)
              .toList(),
          clearSelectedStudent: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          actionStatus: ViewStateStatus.failure,
          actionMessage: 'Unable to delete this student right now.',
        ),
      );
    }
  }

  void clearActionState() {
    emit(
      state.copyWith(
        actionStatus: ViewStateStatus.initial,
        clearActionMessage: true,
      ),
    );
  }

  Future<void> addStudentCourse({
    required String studentId,
    required String courseId,
  }) async {
    emit(
      state.copyWith(
        actionStatus: ViewStateStatus.loading,
        clearActionMessage: true,
      ),
    );

    try {
      await _addStudentCourse(
        AddStudentCourseParams(studentId: studentId, courseId: courseId),
      );
      emit(
        state.copyWith(
          actionStatus: ViewStateStatus.success,
          actionMessage: 'Course added to student successfully.',
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          actionStatus: ViewStateStatus.failure,
          actionMessage: 'Unable to add course to this student right now.',
        ),
      );
    }
  }

  Future<void> loadTopStudents({int limit = 5}) async {
    emit(
      state.copyWith(status: ViewStateStatus.loading, clearErrorMessage: true),
    );

    try {
      final students = await _getTopStudents(
        GetTopStudentsParams(limit: limit),
      );
      emit(state.copyWith(status: ViewStateStatus.success, students: students));
    } catch (_) {
      emit(
        state.copyWith(
          status: ViewStateStatus.failure,
          errorMessage: 'Unable to load top students right now.',
        ),
      );
    }
  }

  List<Student> _replaceStudent(
    List<Student> students,
    Student updatedStudent,
  ) {
    final index = students.indexWhere(
      (student) => student.id == updatedStudent.id,
    );
    if (index == -1) {
      return students;
    }

    return [
      ...students.take(index),
      updatedStudent,
      ...students.skip(index + 1),
    ];
  }
}
