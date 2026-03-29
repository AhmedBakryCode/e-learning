import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/core/widgets/status_chip.dart';
import 'package:e_learning/features/courses/data/datasources/courses_data_source.dart';
import 'package:e_learning/features/courses/domain/entities/course_video.dart';
import 'package:flutter/material.dart';

List<CourseVideo> courseVideosForCourse(String courseId) {
  return MockCoursesDataSource.videosForCourse(courseId);
}

CourseVideo? findCourseVideo(String courseId, String videoId) {
  return MockCoursesDataSource.findVideo(courseId, videoId);
}

class CourseVideoTile extends StatelessWidget {
  const CourseVideoTile({
    super.key,
    required this.video,
    this.onTap,
    this.trailing,
    this.isHighlighted = false,
    this.highlightLabel,
  });

  final CourseVideo video;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isHighlighted;
  final String? highlightLabel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(
              color: isHighlighted
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                  : Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.14),
            ),
            color: isHighlighted
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.04)
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        Text(
                          video.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (video.isPreview)
                          const StatusChip(
                            label: 'Preview',
                            color: Color(0xFF3B82F6),
                            icon: Icons.remove_red_eye_outlined,
                          ),
                        if (isHighlighted)
                          StatusChip(
                            label: highlightLabel ?? 'Last seen',
                            color: Theme.of(context).colorScheme.primary,
                            icon: Icons.history_rounded,
                          ),
                        if (!video.isUploaded)
                          const StatusChip(
                            label: 'In process',
                            color: Color(0xFFF59E0B),
                            icon: Icons.cloud_upload_outlined,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      video.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Text(
                          video.duration,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                            child: LinearProgressIndicator(
                              value: video.progress,
                              minHeight: 7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.md),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
