import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchstore_flutter/main.dart';
import 'package:watchstore_flutter/state/store.dart';

/// Sizes the test surface like a tall phone. With [reduceMotion] the idle
/// animation loops hold still, which lets `pumpAndSettle` finish.
void _usePhone(WidgetTester tester, {bool reduceMotion = true}) {
  tester.view.physicalSize = const Size(1200, 3200);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  if (reduceMotion) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }
}

void main() {
  testWidgets('shows the storefront and adds a watch to the cart', (
    WidgetTester tester,
  ) async {
    _usePhone(tester);
    final StoreController store = StoreController();

    await tester.pumpWidget(WatchStoreApp(store: store));
    await tester.pumpAndSettle();

    expect(find.text('Chrono Vault'), findsOneWidget);
    expect(find.text('Aurelia Pulse'), findsOneWidget);
    expect(find.bySemanticsLabel('Cart, 0 items'), findsOneWidget);

    await tester.tap(find.text('Add to cart'));
    await tester.pumpAndSettle();

    expect(find.text('In cart · 1'), findsOneWidget);
    expect(find.bySemanticsLabel('Cart, 1 item'), findsOneWidget);

    await tester.tap(find.text('In cart · 1'));
    await tester.pumpAndSettle();

    expect(store.quantityOf('w1'), 2);
    expect(find.text('In cart · 2'), findsOneWidget);
  });

  testWidgets('detail page shows specs and adjusts quantity', (
    WidgetTester tester,
  ) async {
    _usePhone(tester);
    final StoreController store = StoreController();

    await tester.pumpWidget(WatchStoreApp(store: store));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Details'));
    await tester.pumpAndSettle();

    expect(find.text('Movement'), findsOneWidget);
    expect(find.text('44 mm'), findsOneWidget);
    expect(find.text('Sport silicone'), findsOneWidget);

    await tester.tap(find.text('Add to cart'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Increase quantity'));
    await tester.pumpAndSettle();
    expect(store.quantityOf('w1'), 2);

    await tester.tap(find.bySemanticsLabel('Decrease quantity'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Remove'));
    await tester.pumpAndSettle();

    expect(store.quantityOf('w1'), 0);
    expect(find.text('Add to cart'), findsOneWidget);
  });

  testWidgets('favorites can be viewed and moved to the cart', (
    WidgetTester tester,
  ) async {
    _usePhone(tester);
    final StoreController store = StoreController();

    await tester.pumpWidget(WatchStoreApp(store: store));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Add to favorites'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Favorites'));
    await tester.pumpAndSettle();

    expect(find.text('1 watch saved'), findsOneWidget);
    expect(find.text('Aurelia Pulse'), findsOneWidget);

    await tester.tap(find.text('Move to cart'));
    await tester.pumpAndSettle();

    expect(find.text('No favorites yet'), findsOneWidget);
    expect(store.quantityOf('w1'), 1);
    expect(store.favoriteCount, 0);
  });

  testWidgets('checkout turns the cart into an order', (
    WidgetTester tester,
  ) async {
    _usePhone(tester);
    final StoreController store = StoreController()
      ..addToCart('w1')
      ..addToCart('w1')
      ..addToCart('w2');

    await tester.pumpWidget(WatchStoreApp(store: store));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Cart, 3 items'));
    await tester.pumpAndSettle();

    expect(find.text('3 watches selected'), findsOneWidget);
    expect(find.text('\$${299 * 2 + 359}'), findsOneWidget);

    await tester.drag(find.text('Nebula Edge'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(store.quantityOf('w2'), 0);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(store.quantityOf('w2'), 1);

    await tester.tap(find.text('Smart Checkout Preview'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Master **** 9031'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Place Order'));
    await tester.pumpAndSettle();

    expect(find.text('Order Placed'), findsOneWidget);
    expect(store.cartCount, 0);
    expect(store.orders.single.payment, 'Master **** 9031');

    await tester.tap(find.text('View orders'));
    await tester.pumpAndSettle();

    expect(find.text('1 order placed'), findsOneWidget);
    expect(find.text(store.orders.single.number), findsOneWidget);
    expect(find.text('2 × \$299'), findsOneWidget);
    expect(find.text('Paid with Master **** 9031'), findsOneWidget);
  });

  testWidgets('animations run without errors', (WidgetTester tester) async {
    _usePhone(tester, reduceMotion: false);

    await tester.pumpWidget(WatchStoreApp(store: StoreController()));
    for (int i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Swipe the carousel, then throw a watch into the cart.
    await tester.drag(find.byType(PageView), const Offset(-250, 0));
    for (int i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Nebula Edge'), findsOneWidget);
    await tester.tap(find.text('Add to cart'));
    for (int i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Open the showcase, drag the watch around, and let it spring back.
    await tester.tap(find.text('Details'));
    for (int i = 0; i < 25; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.dragFrom(const Offset(200, 300), const Offset(120, -40));
    for (int i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('Drag the watch to turn it'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
