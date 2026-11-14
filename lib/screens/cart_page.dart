import 'package:flutter/material.dart';

import '../models/order.dart';
import '../state/store.dart';
import '../widgets/checkout_sheet.dart';
import '../widgets/effects.dart';
import 'orders_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int _selectedPayment = 0;

  void _openSmartCheckout(StoreController store) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return SmartCheckoutSheet(
          total: store.cartTotal,
          itemCount: store.cartCount,
          selectedPayment: _selectedPayment,
          onPaymentChange: (int index) {
            setState(() {
              _selectedPayment = index;
            });
          },
          onPlaceOrder: () {
            Navigator.of(sheetContext).pop();
            _placeOrder(store);
          },
        );
      },
    );
  }

  Future<void> _placeOrder(StoreController store) async {
    final Order? order = store.placeOrder(
      payment: paymentMethods[_selectedPayment],
    );
    if (order == null || !mounted) {
      return;
    }
    final bool viewOrders = await showOrderSuccess(
      context,
      number: order.number,
    );
    if (viewOrders && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const OrdersPage()),
      );
    }
  }

  void _remove(StoreController store, CartLine line) {
    store.removeFromCart(line.watch.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          content: Text('${line.watch.name} removed'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => store.setQuantity(line.watch.id, line.quantity),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final StoreController store = StoreScope.of(context);
    final List<CartLine> lines = store.cartLines;
    final int count = store.cartCount;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF101A2D), Color(0xFF0B1120)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    IconButton(
                      tooltip: 'Back',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Cart Collection',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 26,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  count == 1 ? '1 watch selected' : '$count watches selected',
                  style: const TextStyle(
                    color: Color(0xFFAFC2EA),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: lines.isEmpty
                      ? const Center(
                          child: Text(
                            'Your cart is empty',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: lines.length,
                          separatorBuilder: (BuildContext context, int index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (BuildContext context, int index) {
                            final CartLine line = lines[index];
                            return Dismissible(
                              key: ValueKey<String>(line.watch.id),
                              direction: DismissDirection.endToStart,
                              onDismissed: (_) => _remove(store, line),
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 22),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFFF5C7A,
                                  ).withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Color(0xFFFF8FA3),
                                ),
                              ),
                              child: _CartLineTile(
                                line: line,
                                onQuantityChanged: (int next) {
                                  if (next <= 0) {
                                    _remove(store, line);
                                  } else {
                                    store.setQuantity(line.watch.id, next);
                                  }
                                },
                              ),
                            );
                          },
                        ),
                ),
                if (lines.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Text(
                          'Total',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        AnimatedPrice(
                          value: store.cartTotal,
                          duration: const Duration(milliseconds: 400),
                          style: const TextStyle(
                            color: Color(0xFFEE8A2E),
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _openSmartCheckout(store),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF6AF5C6),
                        foregroundColor: const Color(0xFF0D1729),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Smart Checkout Preview',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CartLineTile extends StatelessWidget {
  const _CartLineTile({required this.line, required this.onQuantityChanged});

  final CartLine line;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    final (:watch, :quantity) = line;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: <Widget>[
          Image.asset(watch.image, width: 70, height: 70, fit: BoxFit.contain),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  watch.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${watch.price} each',
                  style: const TextStyle(
                    color: Color(0xFFAFC2EA),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                QuantityStepper(
                  quantity: quantity,
                  accent: watch.accent,
                  max: StoreController.maxQuantity,
                  compact: true,
                  onChanged: onQuantityChanged,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          AnimatedPrice(
            value: watch.price * quantity,
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              color: watch.accent,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
