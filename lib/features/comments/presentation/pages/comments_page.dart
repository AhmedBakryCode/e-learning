import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:e_learning/core/widgets/app_card.dart';
import 'package:e_learning/core/widgets/adaptive_scaffold.dart';
import 'package:e_learning/core/widgets/custom_text_field.dart';
import 'package:e_learning/core/widgets/empty_state_widget.dart';
import 'package:e_learning/core/widgets/skeleton_box.dart';
import 'package:e_learning/features/auth/domain/entities/app_user.dart';
import 'package:e_learning/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:e_learning/features/comments/domain/usecases/add_comment_usecase.dart';
import 'package:e_learning/features/comments/presentation/cubit/comments_cubit.dart';
import 'package:e_learning/features/comments/presentation/cubit/comments_state.dart';
import 'package:e_learning/features/courses/data/datasources/courses_data_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommentsPage extends StatefulWidget {
  const CommentsPage({
    super.key,
    required this.role,
    required this.courseId,
    this.videoId,
  });

  final UserRole role;
  final String courseId;
  final String? videoId;

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final course = MockCoursesDataSource.findCourse(widget.courseId);
    final video = widget.videoId == null
        ? null
        : MockCoursesDataSource.findVideo(widget.courseId, widget.videoId!);

    return BlocProvider(
      create: (_) => sl<CommentsCubit>()
        ..loadComments(courseId: widget.courseId, videoId: widget.videoId),
      child: BlocConsumer<CommentsCubit, CommentsState>(
        listenWhen: (previous, current) =>
            previous.actionStatus != current.actionStatus &&
            current.actionStatus != ViewStateStatus.initial,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.actionMessage ??
                    (state.actionStatus == ViewStateStatus.success ? 'Comment posted.' : 'The comment could not be posted.'),
              ),
            ),
          );

          if (state.actionStatus == ViewStateStatus.success) {
            _controller.clear();
          }

          context.read<CommentsCubit>().clearActionState();
        },
        builder: (context, state) {
          return AdaptiveScaffold(
            title: 'Comments and discussions',
            subtitle: video != null
                ? 'Discuss about "${video.title}"'
                : 'Discuss the Course with your colleagues.',
            body: switch (state.status) {
              ViewStateStatus.loading => const _CommentsLoading(),
              ViewStateStatus.failure => EmptyStateWidget(
                  title: 'Unable to load comments',
                  message: state.errorMessage ?? 'Try again shortly.',
                  icon: Icons.forum_outlined,
                ),
              _ => Column(
                  children: [
                    Expanded(
                      child: state.comments.isEmpty
                          ? const EmptyStateWidget(
                              title: 'There are no comments yet',
                              message: 'Start a discussion and your message will appear here.',
                              icon: Icons.chat_bubble_outline_rounded,
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.pagePadding,
                                0,
                                AppSpacing.pagePadding,
                                AppSpacing.lg,
                              ),
                              itemCount: state.comments.length,
                              itemBuilder: (context, index) {
                                final comment = state.comments[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                                  child: AppCard(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          child: Text(comment.authorName[0]),
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                comment.authorName,
                                                style: Theme.of(context).textTheme.titleMedium,
                                              ),
                                              const SizedBox(height: AppSpacing.xs),
                                              Text(
                                                '${comment.courseTitle} - ${comment.timeLabel}',
                                                style: Theme.of(context).textTheme.bodySmall,
                                              ),
                                              const SizedBox(height: AppSpacing.md),
                                              Text(comment.message),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    SafeArea(
                      top: false,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          border: Border(
                            top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _controller,
                                hintText: video != null ? 'Add a comment to the video...' : 'Add a comment and ask...',
                                prefixIcon: const Icon(Icons.edit_outlined),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            FilledButton(
                              onPressed: () => _submitComment(
                                context,
                                courseTitle: course?.title ?? 'Course',
                                videoId: widget.videoId ??
                                    MockCoursesDataSource.videosForCourse(widget.courseId).first.id,
                              ),
                              style: FilledButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(AppSpacing.md),
                              ),
                              child: const Icon(Icons.send_rounded),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            },
          );
        },
      ),
    );
  }

  void _submitComment(BuildContext context, {required String courseTitle, required String videoId}) {
    final message = _controller.text.trim();
    final user = context.read<AuthCubit>().state.user;

    if (message.isEmpty || user == null) return;

    context.read<CommentsCubit>().addComment(
      AddCommentParams(
        courseId: widget.courseId,
        videoId: videoId,
        authorName: user.name,
        courseTitle: courseTitle,
        message: message,
      ),
    );
  }
}

class _CommentsLoading extends StatelessWidget {
  const _CommentsLoading();
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      itemCount: 3,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.lg),
          child: SkeletonBox(height: 120, radius: AppRadii.xl),
        );
      },
    );
  }
}
