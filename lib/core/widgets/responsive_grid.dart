import 'package:e_learning/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileCrossAxisCount = 1,
    this.tabletCrossAxisCount = 2,
    this.desktopCrossAxisCount = 4,
    this.mainAxisSpacing = 16.0,
    this.crossAxisSpacing = 16.0,
    this.childAspectRatio,
  });

  final List<Widget> children;
  final int mobileCrossAxisCount;
  final int tabletCrossAxisCount;
  final int desktopCrossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double? childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = mobileCrossAxisCount;
        if (constraints.maxWidth >= Responsive.tabletBreakpoint) {
          crossAxisCount = desktopCrossAxisCount;
        } else if (constraints.maxWidth >= Responsive.mobileBreakpoint) {
          crossAxisCount = tabletCrossAxisCount;
        }

        double ratio = childAspectRatio ?? 0.8;
        if (childAspectRatio == null) {
          if (crossAxisCount == 1) {
            ratio = 1.3; // Full-width
          } else if (crossAxisCount == 2) {
            ratio = 0.46; // Multi-column (increased height for premium cards)
          }
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            childAspectRatio: ratio,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}
