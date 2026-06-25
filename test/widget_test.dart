import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:router_commander_ai/app/app.dart';

void main() {
  testWidgets('renders the application dashboard shell', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RouterCommanderApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Network command center'), findsOneWidget);
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Routers'), findsWidgets);
    expect(find.text('Tools'), findsWidgets);
    expect(find.text('AI'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });
}
