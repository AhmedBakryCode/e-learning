import 'package:e_learning/core/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LoadingIndicator(label: 'Preparing your learning space...'),
    );
  }
}
