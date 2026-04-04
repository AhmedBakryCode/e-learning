import 'dart:io';

import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:e_learning/features/students/data/models/student_model.dart';
import 'package:e_learning/features/students/domain/usecases/get_top_students_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:carousel_slider/carousel_slider.dart';

/// A single unified Carousel that shows:
///   - Page 0: Founder card
///   - Page 1: Co-Founder card
///   - Page 2+: Top students by completion rate from API
class HomeShowcasePageView extends StatefulWidget {
  const HomeShowcasePageView({super.key});

  @override
  State<HomeShowcasePageView> createState() => _HomeShowcasePageViewState();
}

class _HomeShowcasePageViewState extends State<HomeShowcasePageView> {
  int _currentPage = 0;
  List<StudentModel> _topStudents = [];
  bool _isLoading = true;

  static const List<Map<String, String>> _founders = [
    {
      'name': 'Mohamed Gomaa',
      'role': 'Founder & CEO',
      'bio':
          'An expert in developing cloud educational systems with more than 10 years of experience in the field of e-learning and artificial intelligence.',
      'image': 'assets/images/founder.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchTopStudents();
  }

  Future<void> _fetchTopStudents() async {
    try {
      final getTopStudentsUseCase = sl<GetTopStudentsUseCase>();
      final students = await getTopStudentsUseCase.call(
        const GetTopStudentsParams(limit: 5),
      );

      if (mounted) {
        setState(() {
          _topStudents = students
              .map(
                (s) => StudentModel(
                  id: s.id,
                  name: s.name,
                  email: s.email,
                  activeCourses: s.activeCourses,
                  completionRate: s.completionRate,
                  phoneNumber: s.phoneNumber,
                  parentPhoneNumber: s.parentPhoneNumber,
                  profileImageUrl: s.profileImageUrl,
                ),
              )
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Log error - could show a snackbar or other UI indicator
        debugPrint('Failed to load top students: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    final totalPages = _founders.length + _topStudents.length;

    // Build the items
    final List<Widget> items = [];
    for (int i = 0; i < totalPages; i++) {
      if (i < _founders.length) {
        items.add(_FounderSlide(founder: _founders[i]));
      } else {
        final studentIndex = i - _founders.length;
        items.add(
          _TopStudentSlide(
            student: _topStudents[studentIndex],
            rank: studentIndex + 1,
          ),
        );
      }
    }

    final screenWidth = MediaQuery.of(context).size.width;
    double viewportFraction = 0.88;
    if (screenWidth >= 1024) {
      viewportFraction = 0.33; // Details: desktop
    } else if (screenWidth >= 600) {
      viewportFraction = 0.5; // Details: tablet
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
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
        ),
        const SizedBox(height: AppSpacing.md),

        // Carousel Slider
        CarouselSlider(
          items: items,
          options: CarouselOptions(
            height: 380,
            viewportFraction: viewportFraction,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true, // auto play enabled
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
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

        // Page indicators
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(totalPages, (index) {
              final isActive = _currentPage == index;
              final bool isFounder = index < _founders.length;

              Color dotColor;
              if (isActive) {
                dotColor = isFounder
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

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
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
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 380,
          child: Center(child: CircularProgressIndicator()),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(4, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  color: Theme.of(context).colorScheme.outline.withAlpha(40),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Founder / Co-Founder slide
// ---------------------------------------------------------------------------
class _FounderSlide extends StatelessWidget {
  const _FounderSlide({required this.founder});

  final Map<String, String> founder;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    // Use primary color consistently for background per user request
    final List<Color> gradientColors = [
      primary.withAlpha(isDark ? 80 : 30),
      primary.withAlpha(isDark ? 30 : 10),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar with glow
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primary.withAlpha(isDark ? 40 : 25),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 56,
                backgroundImage: AssetImage(founder['image']!),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Info
            // Role badge
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
                founder['role']!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              founder['name']!,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              founder['bio']!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top student slide
// ---------------------------------------------------------------------------
class _TopStudentSlide extends StatelessWidget {
  const _TopStudentSlide({required this.student, required this.rank});

  final StudentModel student;
  final int rank;

  Color _rankColor() {
    switch (rank) {
      case 1:
        return const Color(0xFFFFB300); // gold
      case 2:
        return const Color(0xFF90A4AE); // silver
      case 3:
        return const Color(0xFFCD7F32); // bronze
      default:
        return const Color(0xFF64B5F6); // blue
    }
  }

  IconData _rankIcon() {
    switch (rank) {
      case 1:
        return Icons.emoji_events_rounded;
      case 2:
        return Icons.military_tech_rounded;
      case 3:
        return Icons.workspace_premium_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final accent = _rankColor();
    final completionPct = (student.completionRate * 100).round();

    // Use primary color consistently for background per user request
    final List<Color> gradientColors = [
      primary.withAlpha(isDark ? 80 : 30),
      primary.withAlpha(isDark ? 30 : 10),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Student avatar with progress ring
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: student.completionRate,
                    strokeWidth: 4,
                    backgroundColor: accent.withAlpha(25),
                    valueColor: AlwaysStoppedAnimation(accent),
                  ),
                ),
                student.profileImagePath != null
                    ? ClipOval(
                        child: kIsWeb
                            ? Image.network(
                                student.profileImagePath!,
                                width: 82,
                                height: 82,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.person, size: 40),
                              )
                            : Image.file(
                                File(student.profileImagePath!),
                                width: 82,
                                height: 82,
                                fit: BoxFit.cover,
                              ),
                      )
                    : CircleAvatar(
                        radius: 41,
                        backgroundColor: accent.withAlpha(isDark ? 40 : 20),
                        child: Text(
                          student.name.isNotEmpty ? student.name[0] : '?',
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                      ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Rank badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: accent.withAlpha(isDark ? 50 : 25),
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_rankIcon(), size: 14, color: accent),
                  const SizedBox(width: 4),
                  Text(
                    'Center #$rank',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Info
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: accent.withAlpha(isDark ? 40 : 15),
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Text(
                'Top Student',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              student.name,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              student.email,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Stats row
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              alignment: WrapAlignment.center,
              children: [
                _StatChip(
                  icon: Icons.trending_up_rounded,
                  label: '$completionPct% completion',
                  color: accent,
                  isDark: isDark,
                ),
                _StatChip(
                  icon: Icons.menu_book_rounded,
                  label: '${student.activeCourses} Course',
                  color: primary,
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 30 : 12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
