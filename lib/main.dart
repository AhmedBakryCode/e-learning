import 'package:e_learning/app/app.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:flutter/widgets.dart';
import 'package:media_kit/media_kit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await configureDependencies();
  runApp(const ELearningApp());
}
