import 'dart:io';

import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/features/students/domain/entities/student.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class StudentCard extends StatelessWidget {
  const StudentCard({
    super.key,
    required this.student,
    this.onTap,
    this.trailing,
  });

  final Student student;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isPremium = MediaQuery.of(context).size.width < 1024;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: Container(
        padding: EdgeInsets.all(
          MediaQuery.of(context).size.width < 600
              ? AppSpacing.md
              : AppSpacing.xl,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          gradient: isPremium
              ? const LinearGradient(
                  colors: [Color(0xFF10B981), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isPremium ? null : Theme.of(context).colorScheme.surface,
          boxShadow: AppShadows.card,
          border: isPremium
              ? null
              : Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.1),
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isPremium
                      ? Colors.white.withValues(alpha: 0.1)
                      : Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                  backgroundImage: (student.profileImageUrl?.isNotEmpty ?? false)
                      ? NetworkImage(student.profileImageUrl!) as ImageProvider
                      : student.profileImagePath != null
                          ? (kIsWeb
                              ? NetworkImage(student.profileImagePath!) as ImageProvider
                              : FileImage(File(student.profileImagePath!)))
                          : null,
                  child: ((student.profileImageUrl?.isEmpty ?? true) && student.profileImagePath == null)
                      ? Text(
                          student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: isPremium
                                ? Colors.black
                                : Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const Spacer(),
                if (trailing != null)
                  Theme(
                    data: Theme.of(context).copyWith(
                      iconTheme: IconThemeData(
                        color: isPremium ? Colors.black : null,
                      ),
                    ),
                    child: trailing!,
                  ),
              ],
            ),
            SizedBox(height: isPremium ? AppSpacing.sm : AppSpacing.md),
            Text(
              student.name,
              style:
                  (isPremium
                          ? Theme.of(context).textTheme.titleSmall
                          : Theme.of(context).textTheme.titleMedium)
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isPremium ? Colors.black : null,
                      ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              student.email,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isPremium ? Colors.black.withValues(alpha: 0.7) : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isPremium ? AppSpacing.md : AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                _StatusPill(
                  label: '${student.activeCourses} Courses',
                  color: Colors.black,
                  isPremium: isPremium,
                ),
                _StatusPill(
                  label: '${(student.completionRate * 100).round()}% complete',
                  color: const Color(0xFF10B981),
                  isPremium: isPremium,
                ),
              ],
            ),
            SizedBox(height: isPremium ? AppSpacing.sm : AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.pill),
              child: LinearProgressIndicator(
                value: student.completionRate,
                minHeight: 6,
                backgroundColor: isPremium
                    ? Colors.black.withValues(alpha: 0.1)
                    : Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.08),
                valueColor: isPremium
                    ? const AlwaysStoppedAnimation(Colors.white)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.color,
    this.isPremium = false,
  });

  final String label;
  final Color color;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: isPremium
            ? Colors.black.withValues(alpha: 0.1)
            : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: isPremium ? Colors.black : color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
