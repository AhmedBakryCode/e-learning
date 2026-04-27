import 'dart:developer' as dev;
import 'dart:io';

import 'package:e_learning/app/theme/app_colors.dart';
import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:e_learning/core/widgets/app_card.dart';
import 'package:e_learning/core/widgets/adaptive_scaffold.dart';
import 'package:e_learning/core/widgets/custom_text_field.dart';
import 'package:e_learning/core/widgets/section_header.dart';
import 'package:e_learning/features/students/data/datasources/students_data_source.dart';
import 'package:e_learning/features/students/domain/usecases/add_student_usecase.dart';
import 'package:e_learning/features/students/domain/usecases/update_student_usecase.dart';
import 'package:e_learning/features/students/presentation/cubit/students_cubit.dart';
import 'package:e_learning/features/students/presentation/cubit/students_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class AdminStudentFormPage extends StatelessWidget {
  const AdminStudentFormPage({super.key, this.studentId});

  final String? studentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StudentsCubit>(),
      child: _AdminStudentFormView(studentId: studentId),
    );
  }
}

class _AdminStudentFormView extends StatefulWidget {
  const _AdminStudentFormView({required this.studentId});

  final String? studentId;

  @override
  State<_AdminStudentFormView> createState() => _AdminStudentFormViewState();
}

class _AdminStudentFormViewState extends State<_AdminStudentFormView> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _parentPhoneController;
  late final TextEditingController _passwordController;

  String? _selectedImagePath;
  final ImagePicker _imagePicker = ImagePicker();

  bool get _isEdit => widget.studentId != null;

  @override
  void initState() {
    super.initState();
    final student = widget.studentId == null
        ? null
        : MockStudentsDataSource.findStudent(widget.studentId!);

    _nameController = TextEditingController(text: student?.name ?? '');
    _emailController = TextEditingController(text: student?.email ?? '');
    _phoneController = TextEditingController(text: student?.phoneNumber ?? '');
    _parentPhoneController = TextEditingController(
      text: student?.parentPhoneNumber ?? '',
    );
    _passwordController = TextEditingController(text: student?.password ?? '');
    _selectedImagePath = student?.profileImagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _parentPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _selectedImagePath = picked.path;
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline.withAlpha(50),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                ),
                Text(
                  'Choose the student\'s photo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                    ),
                    child: const Icon(
                      Icons.photo_camera_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  title: const Text('Camera'),
                  subtitle: const Text('Take a new photo'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickImage(ImageSource.camera);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withAlpha(20),
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.secondary,
                    ),
                  ),
                  title: const Text('Gallery'),
                  subtitle: const Text('Choose from photo gallery'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_selectedImagePath != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(20),
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                      ),
                    ),
                    title: const Text('Remove image'),
                    subtitle: const Text('Delete the current image'),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      setState(() {
                        _selectedImagePath = null;
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StudentsCubit, StudentsState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus &&
          current.actionStatus != ViewStateStatus.initial,
      listener: (context, state) {
        final isLoading = state.actionStatus == ViewStateStatus.loading;
        final isSuccess = state.actionStatus == ViewStateStatus.success;
        final isFailure = state.actionStatus == ViewStateStatus.failure;

        if (isLoading) return;

        if (isFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.actionMessage ?? 'This student could not be saved.',
              ),
            ),
          );
          context.read<StudentsCubit>().clearActionState();
          return;
        }

        if (isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.actionMessage ?? 'The student has been saved successfully.',
              ),
            ),
          );
          if (state.selectedStudent != null) {
            context.read<StudentsCubit>().clearActionState();
            context.pushReplacement(
              '/admin/students/${state.selectedStudent!.id}',
            );
          } else {
            context.read<StudentsCubit>().clearActionState();
          }
        }
      },
      builder: (context, state) {
        final isSaving = state.actionStatus == ViewStateStatus.loading;

        return AdaptiveScaffold(
          title: _isEdit ? 'Edit Student' : 'New student',
          subtitle: 'Easily create or edit student data from here.',
          selectedIndex: 2,
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
                        child: _buildInfoCard(),
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
                  _buildInfoCard(),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProfileImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: _showImageSourceDialog,
        child: Stack(
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withAlpha(50),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withAlpha(15),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: _selectedImagePath != null
                    ? (kIsWeb
                          ? Image.network(
                              _selectedImagePath!,
                              fit: BoxFit.cover,
                              width: 110,
                              height: 110,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person),
                            )
                          : Image.file(
                              File(_selectedImagePath!),
                              fit: BoxFit.cover,
                              width: 110,
                              height: 110,
                            ))
                    : Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(15),
                        child: Icon(
                          Icons.person_rounded,
                          size: 50,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(100),
                        ),
                      ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(60),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
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
                title: 'Student data',
                subtitle:
                    'Enter the basic data and the rest will be completed from the progression system.',
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildProfileImagePicker(),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: Text(
                  'Click to choose an image',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              CustomTextField(
                controller: _nameController,
                label: 'Full name',
                hintText: 'Example: Muhammad Ahmed',
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                hintText: 'student@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                controller: _passwordController,
                label: 'Password',
                hintText: 'Enter a strong password',
                obscureText: true,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _phoneController,
                      label: 'Phone number',
                      hintText: '01xxxxxxxxx',
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: CustomTextField(
                      controller: _parentPhoneController,
                      label: 'Guardian number',
                      hintText: '01xxxxxxxxx',
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEdit ? 'Save modifications' : 'Student creation'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return AppCard(
      title: 'Addition instructions',
      subtitle:
          'Make sure to enter a valid email so your student can receive alerts and progress update messages.',
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Text('The email will be used to log in later.'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(Icons.photo_camera_outlined, color: AppColors.secondary),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Text(
                  'You can upload a photo of the student from the camera or gallery.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submit(BuildContext context) {
    dev.log('AdminStudentFormPage: _submit called');
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final parentPhone = _parentPhoneController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and email are required fields.')),
      );
      return;
    }

    if (_isEdit) {
      context.read<StudentsCubit>().updateStudent(
        UpdateStudentParams(
          id: widget.studentId!,
          name: name,
          email: email,
          phoneNumber: phone,
          parentPhoneNumber: parentPhone,
          password: password,
          profileImagePath: _selectedImagePath,
        ),
      );
    } else {
      context.read<StudentsCubit>().addStudent(
        AddStudentParams(
          name: name,
          email: email,
          phoneNumber: phone,
          parentPhoneNumber: parentPhone,
          password: password,
          profileImagePath: _selectedImagePath,
        ),
      );
    }
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

  List<NavigationDestination> _getDestinations() {
    return const [
      NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        label: 'Dashboard',
      ),
      NavigationDestination(
        icon: Icon(Icons.menu_book_outlined),
        label: 'Courses',
      ),
      NavigationDestination(
        icon: Icon(Icons.groups_outlined),
        label: 'Students',
      ),
      NavigationDestination(icon: Icon(Icons.send_outlined), label: 'Send'),
    ];
  }
}
