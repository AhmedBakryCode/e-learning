import 'package:e_learning/app/app.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const ELearningApp());
}
