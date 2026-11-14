import 'dart:async';

import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../models/order.dart';
import '../models/watch_item.dart';
import '../state/store.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  Timer? _refresh;

  @override
  void initState() {
    super.initState();
    // Order status depends on elapsed time, so re-read the clock regularly.
    _refresh = Timer.periodic(const Duration(seconds: 30), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _refresh?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Order> orders = StoreScope.of(context).orders;
    final DateTime now = DateTime.now();

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
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
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
                    const Text(
                      'Orders',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 26,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  orders.length == 1
                      ? '1 order placed'
                      : '${orders.length} orders placed',
                  style: const TextStyle(
                    color: Color(0xFFAFC2EA),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: orders.isEmpty
                      ? const _EmptyOrders()
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: orders.length,
                          separatorBuilder: (BuildContext context, int index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (BuildContext context, int index) {
                            return _OrderCard(order: orders[index], now: now);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.now});

  final Order order;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final OrderStage stage = order.stageAt(now);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      order.number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatOrderDate(order.placedAt),
                      style: const TextStyle(
                        color: Color(0xFFAFC2EA),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${order.total}',
                style: const TextStyle(
                  color: Color(0xFFEE8A2E),
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final OrderLine line in order.lines) _OrderLineRow(line: line),
          const SizedBox(height: 4),
          Text(
            'Paid with ${order.payment}',
            style: const TextStyle(color: Color(0xFFAFC2EA), fontSize: 12),
          ),
          const SizedBox(height: 14),
          _StatusTimeline(stage: stage),
        ],
      ),
    );
  }
}

class _OrderLineRow extends StatelessWidget {
  const _OrderLineRow({required this.line});

  final OrderLine line;

  @override
  Widget build(BuildContext context) {
    final WatchItem? watch = watchById(line.watchId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 40,
            height: 40,
            child: watch == null
                ? const Icon(Icons.watch_outlined, color: Colors.white38)
                : Image.asset(watch.image, fit: BoxFit.contain),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              line.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '${line.quantity} × \$${line.unitPrice}',
            style: const TextStyle(color: Color(0xFFD4E2FF), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.stage});

  final OrderStage stage;

  static const Color _done = Color(0xFF6AF5C6);

  @override
  Widget build(BuildContext context) {
    const List<OrderStage> stages = OrderStage.values;
    final double target = stage.index / (stages.length - 1);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: target),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double progress, Widget? _) {
        return Column(
          children: <Widget>[
            SizedBox(
              height: 16,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  // Dots sit at the centre of each of the equal columns
                  // used by the labels below.
                  final double column = constraints.maxWidth / stages.length;
                  final double track = constraints.maxWidth - column;
                  return Stack(
                    alignment: Alignment.centerLeft,
                    children: <Widget>[
                      Positioned(
                        left: column / 2,
                        width: track,
                        child: Container(height: 3, color: Colors.white12),
                      ),
                      Positioned(
                        left: column / 2,
                        width: track * progress,
                        child: Container(height: 3, color: _done),
                      ),
                      for (int i = 0; i < stages.length; i++)
                        Positioned(
                          left: column * i + column / 2 - 7,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: progress >= i / (stages.length - 1) - 0.001
                                  ? _done
                                  : const Color(0xFF2A3854),
                              border: Border.all(
                                color: const Color(0xFF132238),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: <Widget>[
                for (final OrderStage s in stages)
                  Expanded(
                    child: Text(
                      s.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: s.index <= stage.index
                            ? Colors.white
                            : Colors.white38,
                        fontSize: 11,
                        fontWeight: s == stage
                            ? FontWeight.w800
                            : FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.receipt_long_outlined,
            size: 56,
            color: Colors.white.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 12),
          const Text(
            'No orders yet',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Orders you place will show up here.',
            style: TextStyle(color: Color(0xFFAFC2EA), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
