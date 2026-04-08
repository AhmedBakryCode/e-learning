import 'dart:io';

import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/features/auth/domain/entities/app_user.dart';
import 'package:e_learning/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:e_learning/features/profile/domain/entities/profile.dart';
import 'package:e_learning/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key, required this.profile});

  final Profile profile;

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;
  DateTime? _dateOfBirth;
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _emailController = TextEditingController(text: widget.profile.email);
    _bioController = TextEditingController(text: widget.profile.bio);
    _phoneController = TextEditingController(text: widget.profile.phoneNumber);
    _dateOfBirth = widget.profile.dateOfBirth;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    final updatedProfile = widget.profile.copyWith(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      bio: _bioController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      dateOfBirth: _dateOfBirth,
    );

    File? imageFile;
    if (_selectedImagePath != null) {
      imageFile = File(_selectedImagePath!);
    }

    context.read<ProfileCubit>().updateProfile(
      updatedProfile,
      imageFile: imageFile,
    );

    // Sync with AuthCubit
    final currentAuthUser = context.read<AuthCubit>().state.user;
    final role = currentAuthUser?.role ?? (widget.profile.role == 'admin'
        ? UserRole.admin
        : UserRole.student);

    context.read<AuthCubit>().updateUser(
      AppUser(
        id: updatedProfile.id,
        name: updatedProfile.name,
        email: updatedProfile.email,
        role: role,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.updated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Profile updated successfully! Please log in again with your updated info.',
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          // Wait for snackbar then logout
          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) {
              context.read<AuthCubit>().signOut();
              context.go('/login');
            }
          });
        }
      },
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image
          Center(
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary.withAlpha(50),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: state.profile?.profileImageUrl != null
                        ? NetworkImage(state.profile!.profileImageUrl!)
                        : null,
                    child: state.profile?.profileImageUrl == null
                        ? Text(
                            widget.profile.name[0].toUpperCase(),
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: Material(
                    elevation: 4,
                    shape: const CircleBorder(),
                    color: theme.colorScheme.primary,
                    child: IconButton(
                      onPressed: _pickImage,
                      icon: Icon(
                        _selectedImagePath != null
                            ? Icons.check_rounded
                            : Icons.edit_rounded,
                        color: theme.colorScheme.onPrimary,
                        size: 20,
                      ),
                      tooltip: 'Change Photo',
                    ),
                  ),
                ),
                if (state.status == ProfileStatus.updating &&
                    _selectedImagePath != null)
                  const Positioned.fill(
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          Text(
            'Personal Information',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Name
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Display Name',
              prefixIcon: const Icon(Icons.person_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
            ),
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter your name'
                : null,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Email
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email Address',
              prefixIcon: const Icon(Icons.email_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) return 'Please enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          // Phone
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: const Icon(Icons.phone_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Date of Birth
          InkWell(
            onTap: () => _selectDate(context),
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                prefixIcon: const Icon(Icons.cake_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
              ),
              child: Text(
                _dateOfBirth != null
                    ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                    : 'Select your birthday',
                style: _dateOfBirth == null
                    ? TextStyle(color: theme.hintColor)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          Text(
            'About You',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Bio
          TextFormField(
            controller: _bioController,
            decoration: InputDecoration(
              labelText: 'Bio',
              hintText: 'Tell us a bit about yourself...',
              prefixIcon: const Icon(Icons.info_outline_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
          ),
          const SizedBox(height: AppSpacing.huge),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: state.status == ProfileStatus.updating
                  ? null
                  : _saveProfile,
              icon: state.status == ProfileStatus.updating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(
                state.status == ProfileStatus.updating
                    ? 'Saving...'
                    : 'Update Profile',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          if (state.status == ProfileStatus.error)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        state.errorMessage ?? 'An error occurred',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (state.status == ProfileStatus.updated)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(color: Colors.green.withAlpha(100)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: Colors.green,
                    ),
                    SizedBox(width: AppSpacing.md),
                    Text(
                      'Profile updated successfully!',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.huge),
        ],
      ),
    );
  },
),
);
  }
}
