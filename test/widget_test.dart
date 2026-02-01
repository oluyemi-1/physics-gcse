import 'package:flutter_test/flutter_test.dart';
import 'package:physics_gcse/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const PhysicsGCSEApp());
    await tester.pumpAndSettle();

    // Verify the app title is displayed
    expect(find.text('Physics GCSE'), findsOneWidget);
  });
}
