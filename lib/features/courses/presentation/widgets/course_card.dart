import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/core/utils/arabic_mapper.dart';
import 'package:e_learning/features/auth/domain/entities/app_user.dart';
import 'package:e_learning/features/courses/domain/entities/course.dart';
import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    required this.role,
    this.onTap,
    this.actionLabel,
  });

  final Course course;
  final UserRole role;
  final VoidCallback? onTap;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final roleLabel = role == UserRole.admin
        ? ArabicMapper.publishedState(course.isPublished)
        : '${(course.completionPercent * 100).round()}% complete';

    final accentColor = _categoryColor(course.category);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.12),
          ),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Image
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadii.xl),
                ),
                image: course.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(course.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: course.imageUrl == null
                  ? Center(
                      child: Icon(
                        _categoryIcon(course.category),
                        color: accentColor,
                        size: 40,
                      ),
                    )
                  : null,
            ),
            Padding(
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.width < 600
                    ? AppSpacing.md
                    : AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadii.md),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _categoryIcon(course.category),
                              color: accentColor,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              course.category,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: (isDark ? colorScheme.primary : accentColor)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                        child: Text(
                          roleLabel,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: isDark ? colorScheme.primary : accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    course.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (MediaQuery.of(context).size.width >= 400) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      course.description,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      if (MediaQuery.of(context).size.width >= 420)
                        _InfoChip(
                          icon: Icons.person_outline_rounded,
                          label: course.instructorName,
                        ),
                      _InfoChip(
                        icon: Icons.play_lesson_rounded,
                        label: '${course.totalLessons}',
                      ),
                      if (MediaQuery.of(context).size.width >= 450)
                        _InfoChip(
                          icon: Icons.schedule_rounded,
                          label: course.duration,
                        ),
                      _InfoChip(
                        icon: Icons.star_rounded,
                        label: course.rating.toStringAsFixed(1),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    child: LinearProgressIndicator(
                      value: role == UserRole.admin
                          ? (course.isPublished ? 1 : 0.55)
                          : course.completionPercent,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    role == UserRole.admin
                        ? '${course.enrolledCount} student'
                        : 'Keep learning',
                    style: theme.textTheme.labelSmall,
                  ),
                  if (actionLabel != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            actionLabel!,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: colorScheme.primary,
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Development':
        return Icons.code_rounded;
      case 'Design':
        return Icons.palette_outlined;
      case 'Analytics':
        return Icons.analytics_outlined;
      case 'AI':
        return Icons.auto_awesome_rounded;
      case 'Teaching':
        return Icons.school_outlined;
      default:
        return Icons.menu_book_rounded;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Development':
        return const Color(0xFF3B82F6);
      case 'Design':
        return const Color(0xFFEC4899);
      case 'Analytics':
        return const Color(0xFFF59E0B);
      case 'AI':
        return const Color(0xFF8B5CF6);
      case 'Teaching':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF1C1E22);
    }
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
