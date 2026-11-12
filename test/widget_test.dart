import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchstore_flutter/main.dart';

void main() {
  testWidgets('shows the storefront and adds a watch to the cart', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 3200);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const WatchStoreApp());
    await tester.pumpAndSettle();

    expect(find.text('Chrono Vault'), findsOneWidget);
    expect(find.text('Aurelia Pulse'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.text('Add to cart'));
    await tester.pumpAndSettle();

    expect(find.text('Added to cart'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });
}
