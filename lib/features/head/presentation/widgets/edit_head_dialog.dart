import 'dart:io';
import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/features/head/domain/entities/head.dart';
import 'package:e_learning/features/head/presentation/cubit/head_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class EditHeadDialog extends StatefulWidget {
  final Head? head;
  const EditHeadDialog({super.key, this.head});

  @override
  State<EditHeadDialog> createState() => _EditHeadDialogState();
}

class _EditHeadDialogState extends State<EditHeadDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _nameController;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.head?.title);
    _nameController = TextEditingController(text: widget.head?.name);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HeadCubit, HeadState>(
      listener: (context, state) {
        if (state is HeadLoaded) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Head updated successfully')),
          );
        } else if (state is HeadError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: AlertDialog(
        title: Text(widget.head == null ? 'Add Head' : 'Edit Head'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      image: _selectedImage != null
                          ? DecorationImage(
                              image: FileImage(_selectedImage!),
                              fit: BoxFit.cover,
                            )
                          : (widget.head != null
                              ? DecorationImage(
                                  image: NetworkImage(widget.head!.imageUrl),
                                  fit: BoxFit.cover,
                                )
                              : null),
                    ),
                    child: _selectedImage == null && widget.head == null
                        ? const Icon(Icons.add_a_photo, size: 40)
                        : null,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    hintText: 'e.g. Founder & CEO',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    hintText: 'e.g. Mohamed Gomaa',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          BlocBuilder<HeadCubit, HeadState>(
            builder: (context, state) {
              final isLoading = state is HeadLoading;
              return FilledButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          if (widget.head == null) {
                            if (_selectedImage == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select an image'),
                                ),
                              );
                              return;
                            }
                            context.read<HeadCubit>().createHead(
                              title: _titleController.text,
                              name: _nameController.text,
                              image: _selectedImage!,
                            );
                          } else {
                            context.read<HeadCubit>().updateHead(
                              id: widget.head!.id,
                              title: _titleController.text,
                              name: _nameController.text,
                              image: _selectedImage,
                            );
                          }
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.head == null ? 'Add' : 'Save'),
              );
            },
          ),
        ],
      ),
    );
  }
}
