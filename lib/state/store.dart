import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/catalog.dart';
import '../models/order.dart';
import '../models/watch_item.dart';

typedef CartLine = ({WatchItem watch, int quantity});

/// Holds favorites, cart and order history, and saves them on every change.
///
/// Without [prefs] the store works in memory only.
class StoreController extends ChangeNotifier {
  StoreController({SharedPreferences? prefs, DateTime Function()? clock})
    : _prefs = prefs,
      _clock = clock ?? DateTime.now {
    _restore();
  }

  static const int maxQuantity = 9;

  static const String _favoritesKey = 'cv.favorites';
  static const String _cartKey = 'cv.cart';
  static const String _ordersKey = 'cv.orders';

  /// Loads the saved state, falling back to an in-memory store if the
  /// platform storage is unavailable.
  static Future<StoreController> load() async {
    try {
      return StoreController(prefs: await SharedPreferences.getInstance());
    } catch (_) {
      return StoreController();
    }
  }

  final SharedPreferences? _prefs;
  final DateTime Function() _clock;

  final Set<String> _favorites = <String>{};
  final Map<String, int> _cart = <String, int>{};
  final List<Order> _orders = <Order>[];

  // Favorites

  bool isFavorite(String id) => _favorites.contains(id);

  int get favoriteCount => _favorites.length;

  List<WatchItem> get favorites =>
      _favorites.map(watchById).whereType<WatchItem>().toList();

  void toggleFavorite(String id) {
    if (!_favorites.remove(id)) {
      _favorites.add(id);
    }
    _changed();
  }

  void moveFavoriteToCart(String id) {
    _favorites.remove(id);
    _bump(id);
    _changed();
  }

  // Cart

  int quantityOf(String id) => _cart[id] ?? 0;

  /// Total number of units in the cart.
  int get cartCount => _cart.values.fold<int>(0, (int sum, int q) => sum + q);

  List<CartLine> get cartLines => <CartLine>[
    for (final MapEntry<String, int> entry in _cart.entries)
      if (watchById(entry.key) case final WatchItem watch)
        (watch: watch, quantity: entry.value),
  ];

  int get cartTotal => cartLines.fold<int>(
    0,
    (int sum, CartLine line) => sum + line.watch.price * line.quantity,
  );

  void addToCart(String id) {
    _bump(id);
    _changed();
  }

  /// Sets the quantity for [id]; zero or less removes the line.
  void setQuantity(String id, int quantity) {
    if (quantity <= 0) {
      _cart.remove(id);
    } else {
      _cart[id] = quantity.clamp(1, maxQuantity);
    }
    _changed();
  }

  void removeFromCart(String id) => setQuantity(id, 0);

  void _bump(String id) {
    _cart[id] = (quantityOf(id) + 1).clamp(1, maxQuantity);
  }

  // Orders

  /// Newest first.
  List<Order> get orders => List<Order>.unmodifiable(_orders);

  /// Turns the cart into an order and empties it. Returns null if the cart
  /// is empty.
  Order? placeOrder({required String payment}) {
    final List<CartLine> lines = cartLines;
    if (lines.isEmpty) {
      return null;
    }
    final DateTime now = _clock();
    final Order order = Order(
      id: now.millisecondsSinceEpoch.toString(),
      placedAt: now,
      payment: payment,
      lines: <OrderLine>[
        for (final CartLine line in lines)
          OrderLine(
            watchId: line.watch.id,
            name: line.watch.name,
            quantity: line.quantity,
            unitPrice: line.watch.price,
          ),
      ],
    );
    _orders.insert(0, order);
    _cart.clear();
    _changed();
    return order;
  }

  // Persistence

  void _changed() {
    notifyListeners();
    final SharedPreferences? prefs = _prefs;
    if (prefs == null) {
      return;
    }
    prefs.setStringList(_favoritesKey, _favorites.toList());
    prefs.setString(_cartKey, jsonEncode(_cart));
    prefs.setString(
      _ordersKey,
      jsonEncode(_orders.map((Order order) => order.toJson()).toList()),
    );
  }

  void _restore() {
    final SharedPreferences? prefs = _prefs;
    if (prefs == null) {
      return;
    }
    // Each section is restored on its own so one unreadable value does not
    // discard the rest.
    try {
      _favorites.addAll(
        (prefs.getStringList(_favoritesKey) ?? <String>[]).where(
          (String id) => watchById(id) != null,
        ),
      );
    } catch (_) {}
    try {
      final String? raw = prefs.getString(_cartKey);
      if (raw != null) {
        (jsonDecode(raw) as Map<String, dynamic>).forEach((
          String id,
          dynamic quantity,
        ) {
          if (watchById(id) != null && quantity is int && quantity > 0) {
            _cart[id] = quantity.clamp(1, maxQuantity);
          }
        });
      }
    } catch (_) {
      _cart.clear();
    }
    try {
      final String? raw = prefs.getString(_ordersKey);
      if (raw != null) {
        _orders.addAll(
          (jsonDecode(raw) as List<dynamic>).map(
            (dynamic order) => Order.fromJson(order as Map<String, dynamic>),
          ),
        );
      }
    } catch (_) {
      _orders.clear();
    }
  }
}

/// Exposes the [StoreController] to the widget tree and rebuilds dependents
/// when it changes.
class StoreScope extends InheritedNotifier<StoreController> {
  const StoreScope({
    super.key,
    required StoreController store,
    required super.child,
  }) : super(notifier: store);

  static StoreController of(BuildContext context) {
    final StoreScope? scope = context
        .dependOnInheritedWidgetOfExactType<StoreScope>();
    assert(scope != null, 'No StoreScope found in context');
    return scope!.notifier!;
  }
}
