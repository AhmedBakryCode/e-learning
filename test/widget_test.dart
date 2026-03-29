import 'package:e_learning/app/app.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await resetDependencies();
    await configureDependencies();
  });

  testWidgets('renders role selection entry screen', (tester) async {
    await tester.pumpWidget(const ELearningApp());
    await tester.pumpAndSettle();

    expect(find.text('Mock sign in'), findsOneWidget);
    expect(find.text('Continue as Admin'), findsOneWidget);
    expect(find.text('Continue as Student'), findsOneWidget);
  });
}
