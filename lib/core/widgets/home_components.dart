import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/features/students/data/models/student_model.dart';
import 'package:e_learning/features/head/domain/entities/head.dart';
import 'package:e_learning/features/auth/presentation/cubit/showcase_cubit.dart';
import 'package:e_learning/features/auth/presentation/cubit/showcase_state.dart';

class HomeShowcasePageView extends StatelessWidget {
  const HomeShowcasePageView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ShowcaseCubit>()..loadShowcase(),
      child: BlocBuilder<ShowcaseCubit, ShowcaseState>(
        builder: (context, state) {
          final screenWidth = MediaQuery.of(context).size.width;
          double viewportFraction = 0.86;
          if (screenWidth >= 1024) {
            viewportFraction = 0.35;
          } else if (screenWidth >= 600) {
            viewportFraction = 0.55;
          }

          if (state.status == ViewStateStatus.loading) {
            return _HomeShowcaseLoading(viewportFraction: viewportFraction);
          }

          if (state.status == ViewStateStatus.failure) {
            return const SizedBox.shrink();
          }

          final heads = state.heads;
          final topStudents = state.topStudents;
          final totalPages = heads.length + topStudents.length;

          if (totalPages == 0) return const SizedBox.shrink();

          final List<Widget> items = [];
          for (int i = 0; i < totalPages; i++) {
            if (i < heads.length) {
              items.add(_HeadSlide(head: heads[i]));
            } else {
              final studentIndex = i - heads.length;
              items.add(
                _TopStudentSlide(
                  student: topStudents[studentIndex],
                  rank: studentIndex + 1,
                ),
              );
            }
          }

          return _HomeShowcaseSlider(
            items: items,
            viewportFraction: viewportFraction,
            headsCount: heads.length,
          );
        },
      ),
    );
  }
}

class _HomeShowcaseLoading extends StatelessWidget {
  const _HomeShowcaseLoading({required this.viewportFraction});
  final double viewportFraction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 380,
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Get to know us',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _HomeShowcaseSlider extends StatefulWidget {
  const _HomeShowcaseSlider({
    required this.items,
    required this.viewportFraction,
    required this.headsCount,
  });
  final List<Widget> items;
  final double viewportFraction;
  final int headsCount;

  @override
  State<_HomeShowcaseSlider> createState() => _HomeShowcaseSliderState();
}

class _HomeShowcaseSliderState extends State<_HomeShowcaseSlider> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(),
        const SizedBox(height: AppSpacing.md),
        CarouselSlider(
          items: widget.items,
          options: CarouselOptions(
            height: 320,
            viewportFraction: widget.viewportFraction,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            enlargeCenterPage: true,
            enlargeFactor: 0.15,
            onPageChanged: (index, reason) {
              setState(() {
                _currentPage = index;
              });
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.items.length, (index) {
              final isActive = _currentPage == index;
              final bool isHead = index < widget.headsCount;

              Color dotColor;
              if (isActive) {
                dotColor = isHead
                    ? Theme.of(context).colorScheme.primary
                    : Colors.amber;
              } else {
                dotColor = Theme.of(context).colorScheme.outline.withAlpha(40);
              }

              return AnimatedContainer(
                duration: AppDurations.short,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  color: dotColor,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _HeadSlide extends StatelessWidget {
  const _HeadSlide({required this.head});
  final Head head;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withAlpha(isDark ? 80 : 30),
            primary.withAlpha(isDark ? 30 : 10),
          ],
        ),
        border: Border.all(color: primary.withAlpha(isDark ? 30 : 60)),
        boxShadow: [
          BoxShadow(
            color: primary.withAlpha(isDark ? 20 : 10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 56,
              backgroundImage: NetworkImage(head.imageUrl),
              backgroundColor: primary.withAlpha(20),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              head.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Description (Title) - Now centered
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: primary.withAlpha(isDark ? 50 : 20),
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Text(
                head.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopStudentSlide extends StatelessWidget {
  const _TopStudentSlide({required this.student, required this.rank});
  final StudentModel student;
  final int rank;

  Color _rankColor() {
    switch (rank) {
      case 1: return const Color(0xFFFFB300);
      case 2: return const Color(0xFF90A4AE);
      case 3: return const Color(0xFFCD7F32);
      default: return const Color(0xFF64B5F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final accent = _rankColor();
    final completionPct = (student.completionRate * 100).round();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withAlpha(isDark ? 80 : 30),
            primary.withAlpha(isDark ? 30 : 10),
          ],
        ),
        border: Border.all(color: primary.withAlpha(isDark ? 30 : 60)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 56,
              backgroundImage: student.profileImagePath != null
                  ? (kIsWeb
                      ? NetworkImage(student.profileImagePath!)
                      : FileImage(File(student.profileImagePath!)))
                  : null,
              backgroundColor: accent.withAlpha(isDark ? 40 : 20),
              child: student.profileImagePath == null
                  ? Text(
                      student.name[0],
                      style: TextStyle(color: accent, fontSize: 28),
                    )
                  : null,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              student.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Description (Rank & Completion) - Now centered
            Text(
              'Rank #$rank',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              '$completionPct% completion',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
