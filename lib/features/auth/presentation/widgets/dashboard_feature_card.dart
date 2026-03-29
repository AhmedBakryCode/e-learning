import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/core/widgets/app_card.dart';
import 'package:flutter/material.dart';

class DashboardFeatureCard extends StatelessWidget {
  const DashboardFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      leading: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Icon(icon, color: color),
      ),
      trailing: Icon(
        Icons.arrow_outward_rounded,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: title,
      subtitle: description,
    );
  }
}
