import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.label, this.center = true});

  final String? label;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadii.xl),
            boxShadow: AppShadows.card,
          ),
          child: const SizedBox(
            width: 28,
            height: 28,
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            label!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (center) {
      return Center(child: child);
    }

    return child;
  }
}
