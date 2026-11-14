import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'effects.dart';

const List<String> paymentMethods = <String>[
  'Visa **** 4218',
  'Master **** 9031',
];

class SmartCheckoutSheet extends StatefulWidget {
  const SmartCheckoutSheet({
    super.key,
    required this.total,
    required this.itemCount,
    required this.selectedPayment,
    required this.onPaymentChange,
    required this.onPlaceOrder,
  });

  final int total;
  final int itemCount;
  final int selectedPayment;
  final ValueChanged<int> onPaymentChange;
  final VoidCallback onPlaceOrder;

  @override
  State<SmartCheckoutSheet> createState() => _SmartCheckoutSheetState();
}

class _SmartCheckoutSheetState extends State<SmartCheckoutSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _etaController;
  late int _selected = widget.selectedPayment;

  @override
  void initState() {
    super.initState();
    _etaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();
  }

  @override
  void dispose() {
    _etaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 14,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1C2B46).withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Smart Checkout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Delivery ETA and payment preview',
                    style: TextStyle(color: Color(0xFFC6D9FF), fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  AnimatedBuilder(
                    animation: _etaController,
                    builder: (BuildContext context, Widget? child) {
                      final int minutes = (35 - (_etaController.value * 8))
                          .round()
                          .clamp(27, 35);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'ETA: $minutes minutes',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: _etaController.value,
                              minHeight: 8,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF6AF5C6),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Payment Method',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List<Widget>.generate(paymentMethods.length, (
                      int index,
                    ) {
                      final bool selected = index == _selected;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            widget.onPaymentChange(index);
                            setState(() {
                              _selected = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            margin: EdgeInsets.only(right: index == 0 ? 8 : 0),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: selected
                                  ? const Color(
                                      0xFF6AF5C6,
                                    ).withValues(alpha: 0.2)
                                  : Colors.white.withValues(alpha: 0.08),
                              border: Border.all(
                                color: selected
                                    ? const Color(0xFF6AF5C6)
                                    : Colors.white24,
                              ),
                            ),
                            child: Text(
                              paymentMethods[index],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'Total payable',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              widget.itemCount == 1
                                  ? '1 watch'
                                  : '${widget.itemCount} watches',
                              style: const TextStyle(
                                color: Color(0xFFAFC2EA),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          '\$${widget.total}',
                          style: const TextStyle(
                            color: Color(0xFFEE8A2E),
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: widget.onPlaceOrder,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF6AF5C6),
                        foregroundColor: const Color(0xFF0D1729),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Place Order',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows the order confirmation and resolves to true if the shopper chose
/// to view their orders.
Future<bool> showOrderSuccess(BuildContext context, {required String number}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'success',
    pageBuilder: (BuildContext context, _, _) {
      return _OrderSuccessDialog(number: number);
    },
    transitionBuilder:
        (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.88, end: 1).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              ),
              child: child,
            ),
          );
        },
  ).then((bool? viewOrders) => viewOrders ?? false);
}

class _OrderSuccessDialog extends StatefulWidget {
  const _OrderSuccessDialog({required this.number});

  final String number;

  @override
  State<_OrderSuccessDialog> createState() => _OrderSuccessDialogState();
}

class _OrderSuccessDialogState extends State<_OrderSuccessDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF132238),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget? _) {
                  return CustomPaint(
                    size: const Size.square(84),
                    painter: _SuccessPainter(_controller.value),
                  );
                },
              ),
              const SizedBox(height: 10),
              const Text(
                'Order Placed',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.number,
                style: const TextStyle(
                  color: Color(0xFF6AF5C6),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your premium watches are on the way.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFC6D9FF), fontSize: 14),
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('View orders'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Keep browsing'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws a ring, then a tick, then throws confetti outward.
class _SuccessPainter extends CustomPainter {
  _SuccessPainter(this.t);

  final double t;

  static const Color _green = Color(0xFF6AF5C6);
  static const List<Color> _confetti = <Color>[
    Color(0xFF6AF5C6),
    Color(0xFFEE8A2E),
    Color(0xFF91A4FF),
    Color(0xFFFFE08A),
    Color(0xFFE58DBA),
  ];

  double _phase(double start, double end) =>
      ((t - start) / (end - start)).clamp(0.0, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.shortestSide * 0.36;

    final Paint stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = _green;

    final double ring = Curves.easeOutCubic.transform(_phase(0, 0.4));
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      tau * ring,
      false,
      stroke,
    );

    final double tick = Curves.easeOutCubic.transform(_phase(0.3, 0.6));
    if (tick > 0) {
      final Path path = Path()
        ..moveTo(center.dx - radius * 0.45, center.dy + radius * 0.02)
        ..lineTo(center.dx - radius * 0.1, center.dy + radius * 0.36)
        ..lineTo(center.dx + radius * 0.5, center.dy - radius * 0.32);
      for (final PathMetric metric in path.computeMetrics()) {
        canvas.drawPath(metric.extractPath(0, metric.length * tick), stroke);
      }
    }

    final double burst = _phase(0.45, 1);
    if (burst > 0 && burst < 1) {
      final math.Random random = math.Random(3);
      final double eased = Curves.easeOutCubic.transform(burst);
      for (int i = 0; i < 26; i++) {
        final double angle = random.nextDouble() * tau;
        final double reach = radius * (1.3 + random.nextDouble() * 1.6);
        final Offset position =
            center +
            Offset(math.cos(angle), math.sin(angle)) * (reach * eased) +
            Offset(0, 26 * burst * burst);
        canvas.save();
        canvas.translate(position.dx, position.dy);
        canvas.rotate(angle + burst * 6);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: 7, height: 3.5),
            const Radius.circular(1.5),
          ),
          Paint()..color = _confetti[i % 5].withValues(alpha: 1 - burst),
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_SuccessPainter oldDelegate) => oldDelegate.t != t;
}
