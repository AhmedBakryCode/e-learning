import 'package:e_learning/app/theme/app_colors.dart';
import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:e_learning/core/widgets/app_card.dart';
import 'package:e_learning/core/widgets/adaptive_scaffold.dart';
import 'package:e_learning/features/progress/domain/usecases/enroll_in_course_usecase.dart';
import 'package:e_learning/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:e_learning/features/courses/presentation/cubit/courses_cubit.dart';
import 'package:e_learning/features/courses/presentation/cubit/courses_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key, required this.courseId});
  final String courseId;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedMethod = 'card';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CoursesCubit>()..loadCourseDetails(widget.courseId),
      child: BlocBuilder<CoursesCubit, CoursesState>(
        builder: (context, state) {
          final course = state.selectedCourse;

          return AdaptiveScaffold(
            title: 'Complete payment',
            subtitle: 'Confirm payment to participate in the Course and start immediately.',
            body: state.status == ViewStateStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : course == null
                    ? const Center(child: Text('Course not available'))
                    : ListView(
                        padding: const EdgeInsets.all(AppSpacing.pagePadding),
                        children: [
                          _OrderSummaryCard(course: course),
                          const SizedBox(height: AppSpacing.sectionGap),
                          Text(
                            'Choose the payment method',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _PaymentMethodTile(
                            id: 'card',
                            title: 'Bank card (Visa / MasterCard)',
                            icon: Icons.credit_card_rounded,
                            selectedId: _selectedMethod,
                            onChanged: (id) => setState(() => _selectedMethod = id),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _PaymentMethodTile(
                            id: 'fawry',
                            title: 'Fawry',
                            icon: Icons.payments_rounded,
                            selectedId: _selectedMethod,
                            onChanged: (id) => setState(() => _selectedMethod = id),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _PaymentMethodTile(
                            id: 'vodafone',
                            title: 'Vodafone Cash',
                            icon: Icons.phone_android_rounded,
                            selectedId: _selectedMethod,
                            onChanged: (id) => setState(() => _selectedMethod = id),
                          ),
                          const SizedBox(height: AppSpacing.huge),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton(
                              onPressed: _isProcessing ? null : () => _processPayment(context),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.xl)),
                              ),
                              child: _isProcessing
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                      'Payment confirmation (1500 EGP)',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          const Center(
                            child: Text(
                              'All transactions are encrypted and completely secure.',
                              style: TextStyle(color: AppColors.muted),
                            ),
                          ),
                        ],
                      ),
          );
        },
      ),
    );
  }

  Future<void> _processPayment(BuildContext context) async {
    setState(() => _isProcessing = true);

    // Simulate network delay
    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final studentId = context.read<AuthCubit>().state.user?.id;
    if (studentId != null) {
        // Here we enroll the student manually as if the payment was successful
        // In a real app, this would be done on the server-side after payment confirmation
        await sl<EnrollInCourseUseCase>()(
          EnrollInCourseParams(studentId: studentId, courseId: widget.courseId),
        );
    }

    if (!mounted) return;
    
    _showSuccessDialog(context);
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.check_circle_outline_rounded, size: 64, color: AppColors.success),
          title: const Text('Payment completed successfully!'),
          content: const Text('Congratulations! You have successfully subscribed to the Course. You can now start following the lessons.'),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.go('/student/courses/${widget.courseId}');
              },
              child: const Text('Start learning now'),
            ),
          ],
        );
      },
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.course});
  final dynamic course;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: 'Order summary',
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                child: const Icon(Icons.menu_book_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.title, style: Theme.of(context).textTheme.titleMedium),
                    Text('${course.totalLessons} Lesson', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const Text('1500 EGP', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: AppSpacing.xxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Total'),
              Text(
                '1500 EGP',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.id,
    required this.title,
    required this.icon,
    required this.selectedId,
    required this.onChanged,
  });

  final String id;
  final String title;
  final IconData icon;
  final String selectedId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isSelected = id == selectedId;

    return InkWell(
      onTap: () => onChanged(id),
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.cardStroke,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadii.xl),
          color: isSelected ? AppColors.secondary.withAlpha(10) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.secondary : AppColors.muted),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isSelected ? AppColors.secondary : AppColors.ink,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.secondary)
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cardStroke, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
