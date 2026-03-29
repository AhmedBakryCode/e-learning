import 'package:e_learning/app/theme/app_colors.dart';
import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:e_learning/core/widgets/app_card.dart';
import 'package:e_learning/core/widgets/adaptive_scaffold.dart';
import 'package:e_learning/core/widgets/custom_text_field.dart';
import 'package:e_learning/core/widgets/inline_feedback_card.dart';
import 'package:e_learning/features/courses/domain/usecases/add_course_video_usecase.dart';
import 'package:e_learning/features/courses/presentation/cubit/courses_cubit.dart';
import 'package:e_learning/features/courses/presentation/cubit/courses_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class AddVideoPage extends StatelessWidget {
  const AddVideoPage({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CoursesCubit>()..loadCourseDetails(courseId),
      child: _AddVideoView(courseId: courseId),
    );
  }
}

class _AddVideoView extends StatefulWidget {
  const _AddVideoView({required this.courseId});

  final String courseId;

  @override
  State<_AddVideoView> createState() => _AddVideoViewState();
}

class _AddVideoViewState extends State<_AddVideoView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _videoUrlController = TextEditingController();
  XFile? _selectedVideo;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 10),
      );
      if (video != null) {
        setState(() {
          _selectedVideo = video;
          if (_titleController.text.isEmpty) {
            final fileName = video.name.split('.').first;
            _titleController.text = fileName;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to select video.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CoursesCubit, CoursesState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus &&
          current.actionStatus != ViewStateStatus.initial,
      listener: (context, state) {
        final isSuccess = state.actionStatus == ViewStateStatus.success;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              state.actionMessage ?? (isSuccess ? 'The video has been added successfully.' : 'Unable to add video.'),
            ),
          ),
        );

        if (isSuccess) {
          context.read<CoursesCubit>().clearActionState();
          context.pop();
          return;
        }
        context.read<CoursesCubit>().clearActionState();
      },
      builder: (context, state) {
        final isSaving = state.actionStatus == ViewStateStatus.loading;

        return AdaptiveScaffold(
          title: 'Add video',
          subtitle: 'Add the lesson content with title and description and upload the video file.',
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: _buildForm(isSaving, state),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: _buildInfoCard(state),
                      ),
                    ),
                  ],
                );
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pagePadding,
                  0,
                  AppSpacing.pagePadding,
                  AppSpacing.huge,
                ),
                children: [
                  _buildForm(isSaving, state),
                  const SizedBox(height: AppSpacing.sectionGap),
                  _buildInfoCard(state),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildForm(bool isSaving, CoursesState state) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: isSaving ? null : _pickVideo,
            borderRadius: BorderRadius.circular(AppRadii.xxl),
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.xxl),
                color: AppColors.primary.withAlpha(12),
                border: Border.all(color: AppColors.primary.withAlpha(30)),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _selectedVideo == null ? Icons.cloud_upload_outlined : Icons.video_file_outlined,
                      size: 42,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _selectedVideo == null ? 'Click to select a video from your device' : _selectedVideo!.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_selectedVideo != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'The video has been selected successfully',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary.withAlpha(180),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          CustomTextField(
            controller: _titleController,
            label: 'Video title',
          ),
          const SizedBox(height: AppSpacing.md),
          CustomTextField(
            controller: _descriptionController,
            label: 'Video description',
            maxLines: 4,
          ),
          const SizedBox(height: AppSpacing.md),
          CustomTextField(
            controller: _videoUrlController,
            label: 'External link (optional)',
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isSaving ? null : () => context.pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton(
                  onPressed: isSaving ? null : () => _submit(context),
                  child: isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Add video'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(CoursesState state) {
    return InlineFeedbackCard(
      title: 'Upload instructions',
      message: state.selectedCourse == null
          ? 'A good thumbnail and short description help raise the completion rate.'
          : 'This video will be added to "${state.selectedCourse!.title}" and the number of lessons will be updated directly.',
      color: AppColors.secondary,
      icon: Icons.tips_and_updates_outlined,
    );
  }

  void _submit(BuildContext context) {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final videoUrl = _videoUrlController.text.trim();

    if (title.isEmpty || description.isEmpty || (_selectedVideo == null && videoUrl.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title, description and video are required fields.')),
      );
      return;
    }

    context.read<CoursesCubit>().addVideo(
      AddCourseVideoParams(
        courseId: widget.courseId,
        title: title,
        description: description,
        videoUrl: _selectedVideo?.path ?? videoUrl,
      ),
    );
  }
}
