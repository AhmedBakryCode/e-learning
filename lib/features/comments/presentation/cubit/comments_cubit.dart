import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/features/comments/domain/usecases/add_comment_usecase.dart';
import 'package:e_learning/features/comments/domain/usecases/get_comments_usecase.dart';
import 'package:e_learning/features/comments/presentation/cubit/comments_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommentsCubit extends Cubit<CommentsState> {
  CommentsCubit({
    required GetCommentsUseCase getComments,
    required AddCommentUseCase addComment,
  }) : _getComments = getComments,
       _addComment = addComment,
       super(const CommentsState());

  final GetCommentsUseCase _getComments;
  final AddCommentUseCase _addComment;

  Future<void> loadComments({required String courseId, String? videoId}) async {
    emit(
      state.copyWith(
        status: ViewStateStatus.loading,
        clearErrorMessage: true,
        courseId: courseId,
        videoId: videoId,
      ),
    );

    try {
      final comments = await _getComments(
        GetCommentsParams(courseId: courseId, videoId: videoId),
      );
      emit(state.copyWith(status: ViewStateStatus.success, comments: comments));
    } catch (_) {
      emit(
        state.copyWith(
          status: ViewStateStatus.failure,
          errorMessage: 'Unable to load comments right now.',
        ),
      );
    }
  }

  Future<void> addComment(AddCommentParams params) async {
    emit(
      state.copyWith(
        actionStatus: ViewStateStatus.loading,
        clearActionMessage: true,
      ),
    );

    try {
      final comment = await _addComment(params);
      emit(
        state.copyWith(
          actionStatus: ViewStateStatus.success,
          actionMessage: 'Comment posted successfully.',
          comments: [comment, ...state.comments],
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          actionStatus: ViewStateStatus.failure,
          actionMessage: 'Unable to post this comment right now.',
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
