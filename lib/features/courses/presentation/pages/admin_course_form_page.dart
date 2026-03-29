import 'package:e_learning/app/theme/app_colors.dart';
import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:e_learning/core/utils/arabic_mapper.dart';
import 'package:e_learning/core/widgets/app_card.dart';
import 'package:e_learning/core/widgets/adaptive_scaffold.dart';
import 'package:e_learning/core/widgets/custom_text_field.dart';
import 'package:e_learning/core/widgets/section_header.dart';
import 'package:e_learning/features/courses/data/datasources/courses_data_source.dart';
import 'package:e_learning/features/courses/domain/usecases/create_course_usecase.dart';
import 'package:e_learning/features/courses/domain/usecases/update_course_usecase.dart';
import 'package:e_learning/features/courses/presentation/cubit/courses_cubit.dart';
import 'package:e_learning/features/courses/presentation/cubit/courses_state.dart';
import 'package:e_learning/core/widgets/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AdminCourseFormPage extends StatelessWidget {
  const AdminCourseFormPage({super.key, this.courseId});

  final String? courseId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CoursesCubit>(),
      child: _AdminCourseFormView(courseId: courseId),
    );
  }
}

class _AdminCourseFormView extends StatefulWidget {
  const _AdminCourseFormView({required this.courseId});

  final String? courseId;

  @override
  State<_AdminCourseFormView> createState() => _AdminCourseFormViewState();
}

class _AdminCourseFormViewState extends State<_AdminCourseFormView> {
  late final TextEditingController _titleController;
  late final TextEditingController _instructorController;
  late final TextEditingController _descriptionController;
  String _level = 'Intermediate';
  String _category = 'Development';
  bool _isPublished = false;

  bool get _isEdit => widget.courseId != null;

  @override
  void initState() {
    super.initState();
    final course = widget.courseId == null
        ? null
        : MockCoursesDataSource.findCourse(widget.courseId!);

    _titleController = TextEditingController(text: course?.title ?? '');
    _instructorController = TextEditingController(text: course?.instructorName ?? 'Ahmed Mohamed');
    _descriptionController = TextEditingController(text: course?.description ?? '');
    _level = course?.level ?? _level;
    _category = course?.category ?? _category;
    _isPublished = course?.isPublished ?? false;

    _titleController.addListener(_refresh);
    _descriptionController.addListener(_refresh);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _instructorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CoursesCubit, CoursesState>(
      listener: (context, state) {
        if (state.actionStatus == ViewStateStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('The Course has been saved successfully.')),
          );
          context.pop();
        }
      },
      builder: (context, state) {
        final isSaving = state.actionStatus == ViewStateStatus.loading;

        return AdaptiveScaffold(
          title: _isEdit ? 'Edit the chorus' : 'New Course',
          subtitle: 'Add basic data, images, and publishing details.',
          selectedIndex: 1,
          onNavigationChanged: (index) => _onNavChanged(context, index),
          navigationDestinations: _getDestinations(),
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
                        child: _buildForm(isSaving),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildPreview(),
                            const SizedBox(height: AppSpacing.sectionGap),
                            _buildGuidelinesCard(),
                          ],
                        ),
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
                  _buildForm(isSaving),
                  const SizedBox(height: AppSpacing.sectionGap),
                  _buildPreview(),
                  const SizedBox(height: AppSpacing.sectionGap),
                  _buildGuidelinesCard(),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildForm(bool isSaving) {
    return Column(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Course information',
                subtitle: 'Start with basic information for the student.',
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildImagePlaceholder(),
              const SizedBox(height: AppSpacing.lg),
              CustomTextField(
                controller: _titleController,
                label: 'Title',
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                controller: _instructorController,
                label: 'Instructor',
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _category,
                      isExpanded: true,
                      items: _categories.entries.map((e) => 
                        DropdownMenuItem(value: e.key, child: Text(e.value))
                      ).toList(),
                      onChanged: (v) => setState(() => _category = v!),
                      decoration: const InputDecoration(labelText: 'Classification'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _level,
                      isExpanded: true,
                      items: _levels.entries.map((e) => 
                        DropdownMenuItem(value: e.key, child: Text(e.value))
                      ).toList(),
                      onChanged: (v) => setState(() => _level = v!),
                      decoration: const InputDecoration(labelText: 'Level'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 4,
              ),
              const SizedBox(height: AppSpacing.md),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _isPublished,
                onChanged: (v) => setState(() => _isPublished = v),
                title: const Text('Instant publishing'),
                subtitle: const Text('The Course will appear to students immediately after saving if it is activated.'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FilledButton(
                onPressed: isSaving ? null : () => _submit(context),
                child: isSaving 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_isEdit ? 'Save modifications' : 'Create the Course'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return AppCard(
      title: 'Live preview',
      subtitle: 'This is how your students will see it in the Course list.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(AppRadii.xl),
              image: const DecorationImage(
                image: AssetImage('assets/images/course_placeholder.png'),
                fit: BoxFit.cover,
                scale: 1,
              ),
            ),
            child: _titleController.text.isEmpty 
                ? const Center(child: Icon(Icons.image_outlined, size: 32, color: AppColors.primary))
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _titleController.text.isEmpty ? 'The Course title appears here' : _titleController.text,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _instructorController.text.isEmpty ? 'Instructor' : 'By ${_instructorController.text}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            children: [
              StatusChip(label: ArabicMapper.category(_category), color: AppColors.primary),
              StatusChip(label: ArabicMapper.level(_level), color: AppColors.secondary),
              if (_isPublished) const StatusChip(label: 'Published', color: AppColors.success),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(15),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: AppColors.primary.withAlpha(30)),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary),
            SizedBox(height: AppSpacing.xs),
            Text('Change cover photo', style: TextStyle(color: AppColors.primary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidelinesCard() {
    return AppCard(
      title: 'Publication guidelines and detailed information',
      subtitle: 'Follow these rules to ensure an outstanding and professional learning experience.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GuidelineRow(
            icon: Icons.image_rounded, 
            text: 'Cover image: Use PNG or JPG format with a resolution of at least 1280x720 pixels. Make sure that the image expresses the content of the Course, and avoid heavy writing above it so that it appears well in the mini menus.'
          ),
          const SizedBox(height: AppSpacing.md),
          _GuidelineRow(
            icon: Icons.title_rounded, 
            text: 'Educational title: The title must be clear and concise (between 30 to 60 characters). Start with powerful words like “learn,” “master,” or “the complete guide to...” to capture students\' attention and interest.'
          ),
          const SizedBox(height: AppSpacing.md),
          _GuidelineRow(
            icon: Icons.description_rounded, 
            text: 'Comprehensive description: Do not limit yourself to one line. Write what the student will learn, what the prerequisites are, and who this Course is for. A good description turns a visitor into a registered student immediately and reduces repetitive inquiries.'
          ),
          const SizedBox(height: AppSpacing.md),
          _GuidelineRow(
            icon: Icons.category_outlined, 
            text: 'Classification and level: Choose the classification that is closest to your field precisely. Determining the level (beginner/intermediate) helps the system suggest the Course to suitable students and ensures positive evaluations in the future.'
          ),
          const SizedBox(height: AppSpacing.md),
          _GuidelineRow(
            icon: Icons.video_collection_rounded, 
            text: 'Structure lessons: Organize your videos into logical sections. It is preferable to add a free welcome video as the first lesson to familiarize students with your style before actually starting complex educational lessons.'
          ),
        ],
      ),
    );
  }

  void _submit(BuildContext context) {
    if (_titleController.text.isEmpty || _instructorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Basic fields are required.')));
      return;
    }

    if (_isEdit) {
      context.read<CoursesCubit>().updateCourse(UpdateCourseParams(
        id: widget.courseId!,
        title: _titleController.text,
        description: _descriptionController.text,
        instructorName: _instructorController.text,
        category: _category,
        level: _level,
        isPublished: _isPublished,
      ));
    } else {
      context.read<CoursesCubit>().createCourse(CreateCourseParams(
        title: _titleController.text,
        description: _descriptionController.text,
        instructorName: _instructorController.text,
        category: _category,
        level: _level,
        isPublished: _isPublished,
      ));
    }
  }

  void _onNavChanged(BuildContext context, int index) {
     switch (index) {
      case 0: context.go('/admin'); break;
      case 1: context.go('/admin/courses'); break;
      case 2: context.go('/admin/students'); break;
      case 3: context.go('/admin/notifications/send'); break;
    }
  }

  List<NavigationDestination> _getDestinations() {
    return const [
      NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
      NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Courses'),
      NavigationDestination(icon: Icon(Icons.groups_outlined), label: 'Students'),
      NavigationDestination(icon: Icon(Icons.send_outlined), label: 'Send'),
    ];
  }

  static const _categories = {
    'Development': 'Software development',
    'Design': 'Interface design',
    'Analytics': 'Data analysis',
    'AI': 'Artificial intelligence',
    'Teaching': 'Teaching methods',
  };

  static const _levels = {
    'Beginner': 'Beginner',
    'Intermediate': 'Intermediate',
    'Advanced': 'Advanced',
  };
}

class _GuidelineRow extends StatelessWidget {
  const _GuidelineRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    );
  }
}
