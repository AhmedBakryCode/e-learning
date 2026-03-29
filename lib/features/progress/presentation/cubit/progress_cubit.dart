import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/features/progress/domain/usecases/enroll_in_course_usecase.dart';
import 'package:e_learning/features/progress/domain/usecases/get_progress_usecase.dart';
import 'package:e_learning/features/progress/domain/usecases/update_progress_usecase.dart';
import 'package:e_learning/features/progress/presentation/cubit/progress_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProgressCubit extends Cubit<ProgressState> {
  ProgressCubit({
    required GetProgressUseCase getProgress,
    required UpdateProgressUseCase updateProgress,
    required EnrollInCourseUseCase enrollInCourse,
  }) : _getProgress = getProgress,
       _updateProgress = updateProgress,
       _enrollInCourse = enrollInCourse,
       super(const ProgressState());

  final GetProgressUseCase _getProgress;
  final UpdateProgressUseCase _updateProgress;
  final EnrollInCourseUseCase _enrollInCourse;

  Future<void> loadProgress({String? studentId}) async {
    emit(
      state.copyWith(
        status: ViewStateStatus.loading,
        clearErrorMessage: true,
        studentIdFilter: studentId,
      ),
    );

    try {
      final progressItems = await _getProgress(
        GetProgressParams(studentId: studentId),
      );
      emit(
        state.copyWith(
          status: ViewStateStatus.success,
          progressItems: progressItems,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ViewStateStatus.failure,
          errorMessage: 'Unable to load progress right now.',
        ),
      );
    }
  }

  Future<void> updateProgress(UpdateProgressParams params) async {
    emit(
      state.copyWith(
        actionStatus: ViewStateStatus.loading,
        clearActionMessage: true,
      ),
    );

    try {
      final updatedProgress = await _updateProgress(params);
      final updatedItems = state.progressItems.map((item) {
        if (item.id != updatedProgress.id) {
          return item;
        }

        return updatedProgress;
      }).toList();

      emit(
        state.copyWith(
          actionStatus: ViewStateStatus.success,
          actionMessage: 'Student progress updated successfully.',
          progressItems: updatedItems,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          actionStatus: ViewStateStatus.failure,
          actionMessage: 'Unable to update progress right now.',
        ),
      );
    }
  }

  Future<void> enrollStudent(EnrollInCourseParams params) async {
    emit(
      state.copyWith(
        actionStatus: ViewStateStatus.loading,
        clearActionMessage: true,
      ),
    );

    try {
      final newProgress = await _enrollInCourse(params);
      final updatedItems = [newProgress, ...state.progressItems];

      emit(
        state.copyWith(
          actionStatus: ViewStateStatus.success,
          actionMessage: 'Student enrolled in course successfully.',
          progressItems: updatedItems,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          actionStatus: ViewStateStatus.failure,
          actionMessage: 'Unable to enroll student in course right now.',
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
}
