import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watchstore_flutter/models/order.dart';
import 'package:watchstore_flutter/state/store.dart';

void main() {
  test('cart tracks quantities and totals', () {
    final StoreController store = StoreController();

    store.addToCart('w1');
    store.addToCart('w1');
    store.addToCart('w2');

    expect(store.quantityOf('w1'), 2);
    expect(store.cartCount, 3);
    expect(store.cartTotal, 299 * 2 + 359);

    store.setQuantity('w1', 1);
    expect(store.cartTotal, 299 + 359);

    store.setQuantity('w2', 0);
    expect(store.cartLines.map((CartLine line) => line.watch.id), <String>[
      'w1',
    ]);
  });

  test('quantity is capped', () {
    final StoreController store = StoreController();
    for (int i = 0; i < StoreController.maxQuantity + 5; i++) {
      store.addToCart('w1');
    }
    expect(store.quantityOf('w1'), StoreController.maxQuantity);
  });

  test('moving a favorite to the cart removes it from favorites', () {
    final StoreController store = StoreController();
    store.toggleFavorite('w3');
    expect(store.isFavorite('w3'), isTrue);

    store.moveFavoriteToCart('w3');

    expect(store.isFavorite('w3'), isFalse);
    expect(store.quantityOf('w3'), 1);
  });

  test('placing an order records it and empties the cart', () {
    final DateTime placed = DateTime(2026, 11, 14, 15, 42);
    final StoreController store = StoreController(clock: () => placed);
    store.addToCart('w1');
    store.addToCart('w1');
    store.addToCart('w10');

    final Order? order = store.placeOrder(payment: 'Visa **** 4218');

    expect(order, isNotNull);
    expect(order!.total, 299 * 2 + 529);
    expect(order.itemCount, 3);
    expect(store.cartCount, 0);
    expect(store.orders.single.id, order.id);
    expect(store.placeOrder(payment: 'Visa **** 4218'), isNull);
  });

  test('order stage advances with elapsed time', () {
    final DateTime placed = DateTime(2026, 11, 14, 12);
    final Order order = Order(
      id: '1',
      placedAt: placed,
      lines: const <OrderLine>[],
      payment: 'Visa',
    );

    OrderStage after(int minutes) =>
        order.stageAt(placed.add(Duration(minutes: minutes)));

    expect(after(0), OrderStage.confirmed);
    expect(after(2), OrderStage.packed);
    expect(after(10), OrderStage.outForDelivery);
    expect(after(27), OrderStage.delivered);
    expect(
      formatOrderDate(DateTime(2026, 11, 14, 15, 42)),
      '14 Nov 2026, 3:42 PM',
    );
    expect(formatOrderDate(DateTime(2026, 1, 2, 0, 5)), '2 Jan 2026, 12:05 AM');
  });

  test('state survives a restart', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final StoreController first = await StoreController.load();
    first.toggleFavorite('w4');
    first.addToCart('w2');
    first.addToCart('w2');
    first.addToCart('w5');
    first.placeOrder(payment: 'Master **** 9031');
    first.addToCart('w7');

    final StoreController second = await StoreController.load();

    expect(second.isFavorite('w4'), isTrue);
    expect(second.quantityOf('w7'), 1);
    expect(second.cartCount, 1);
    expect(second.orders.single.total, 359 * 2 + 389);
    expect(second.orders.single.payment, 'Master **** 9031');
  });

  test('unreadable or unknown saved data is ignored', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'cv.favorites': <String>['w1', 'gone'],
      'cv.cart': '{"w2": 3, "gone": 1, "w3": "x"}',
      'cv.orders': 'not json',
    });

    final StoreController store = await StoreController.load();

    expect(store.favorites.map((w) => w.id), <String>['w1']);
    expect(store.quantityOf('w2'), 3);
    expect(store.cartCount, 3);
    expect(store.orders, isEmpty);
  });
}
