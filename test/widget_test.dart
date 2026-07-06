import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_mobile/main.dart';
import 'package:project_mobile/features/auth/presentation/pages/splash_page.dart';

void main() {
  testWidgets('App starts with SplashPage smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Verify that SplashPage is displayed and contains the progress label.
    expect(find.byType(SplashPage), findsOneWidget);
    expect(find.text('INITIALIZING KINETIC LEDGER'), findsOneWidget);

    // Advance virtual time to complete the splash transition futures.
    await tester.pump(const Duration(seconds: 4));
  });
}
