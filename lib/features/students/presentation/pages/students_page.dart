import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:e_learning/core/widgets/adaptive_scaffold.dart';
import 'package:e_learning/core/widgets/empty_state_widget.dart';
import 'package:e_learning/core/widgets/section_header.dart';
import 'package:e_learning/core/widgets/skeleton_box.dart';
import 'package:e_learning/core/widgets/responsive_grid.dart';
import 'package:e_learning/features/students/presentation/widgets/student_card.dart';
import 'package:e_learning/features/students/presentation/cubit/students_cubit.dart';
import 'package:e_learning/features/students/presentation/cubit/students_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StudentsCubit>()..loadStudents(),
      child: BlocConsumer<StudentsCubit, StudentsState>(
        listenWhen: (previous, current) =>
            previous.actionStatus != current.actionStatus &&
            current.actionStatus != ViewStateStatus.initial,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.actionMessage ??
                    (state.actionStatus == ViewStateStatus.success
                        ? 'The procedure was performed on the student successfully.'
                        : 'The action failed on the student.'),
              ),
            ),
          );
          context.read<StudentsCubit>().clearActionState();
        },
        builder: (context, state) {
          return AdaptiveScaffold(
            title: 'Students',
            subtitle: 'Follow students\' status, edit their data, and see their progress easily.',
            selectedIndex: 2,
            onNavigationChanged: (index) => _onNavChanged(context, index),
            navigationDestinations: _getNavigationDestinations(),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => context.push('/admin/students/add'),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Add a student'),
            ),
            body: AnimatedSwitcher(
              duration: AppDurations.medium,
              child: switch (state.status) {
                ViewStateStatus.loading => const _StudentsLoading(),
                ViewStateStatus.failure => EmptyStateWidget(
                    title: 'Unable to load student data',
                    message: state.errorMessage ?? 'Try again shortly.',
                    icon: Icons.groups_rounded,
                    action: FilledButton(
                      onPressed: () => context.read<StudentsCubit>().loadStudents(),
                      child: const Text('Retry'),
                    ),
                  ),
                _ => RefreshIndicator(
                    onRefresh: () async {
                      await context.read<StudentsCubit>().loadStudents();
                    },
                    child: ListView(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.pagePadding,
                          0,
                          AppSpacing.pagePadding,
                          AppSpacing.huge,
                        ),
                        children: [
                          const SectionHeader(
                            title: 'Overview',
                            subtitle: 'Add, edit, delete students or review their details from one list.',
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          if (state.students.isEmpty)
                            const EmptyStateWidget(
                              title: 'There are no students yet',
                              message: 'Create your first student to start managing students.',
                              icon: Icons.person_search_rounded,
                            )
                          else
                            ResponsiveGrid(
                              mobileCrossAxisCount: 2,
                              tabletCrossAxisCount: 2,
                              desktopCrossAxisCount: 3,
                              children: state.students.map((student) {
                                return StudentCard(
                                  onTap: () => context.push('/admin/students/${student.id}'),
                                  student: student,
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        context.push('/admin/students/${student.id}/edit');
                                      }
                                      if (value == 'delete') {
                                        final confirmed = await _confirmDeleteStudent(
                                          context,
                                          student.name,
                                        );
                                        if (confirmed && context.mounted) {
                                          await context.read<StudentsCubit>().deleteStudent(student.id);
                                        }
                                      }
                                    },
                                    itemBuilder: (context) => const [
                                      PopupMenuItem(value: 'edit', child: Text('Edit Student')),
                                      PopupMenuDivider(),
                                      PopupMenuItem(value: 'delete', child: Text('Delete student')),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                  ),
              },
            ),
          );
        },
      ),
    );
  }

  void _onNavChanged(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/admin');
        break;
      case 1:
        context.go('/admin/courses');
        break;
      case 2:
        context.go('/admin/students');
        break;
      case 3:
        context.go('/admin/notifications/send');
        break;
    }
  }

  List<NavigationDestination> _getNavigationDestinations() {
    return const [
      NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard_rounded),
        label: 'Dashboard',
      ),
      NavigationDestination(
        icon: Icon(Icons.menu_book_outlined),
        selectedIcon: Icon(Icons.menu_book_rounded),
        label: 'Courses',
      ),
      NavigationDestination(
        icon: Icon(Icons.groups_outlined),
        selectedIcon: Icon(Icons.groups_rounded),
        label: 'Students',
      ),
      NavigationDestination(
        icon: Icon(Icons.send_outlined),
        selectedIcon: Icon(Icons.send_rounded),
        label: 'Send',
      ),
    ];
  }

  Future<bool> _confirmDeleteStudent(BuildContext context, String studentName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete student?'),
          content: Text('Do you want to delete $studentName from Control Panel? This step cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}

class _StudentsLoading extends StatelessWidget {
  const _StudentsLoading();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: List.generate(
        4,
        (_) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.lg),
          child: SkeletonBox(height: 156, radius: AppRadii.xl),
        ),
      ),
    );
  }
}
