import 'package:flutter/material.dart';

import '../models/watch_item.dart';

class TryOnPage extends StatefulWidget {
  const TryOnPage({super.key, required this.item});

  final WatchItem item;

  @override
  State<TryOnPage> createState() => _TryOnPageState();
}

class _TryOnPageState extends State<TryOnPage> {
  Offset _offset = const Offset(0, 0);
  double _scale = 1;
  double _rotation = 0;

  Offset _startFocal = Offset.zero;
  Offset _startOffset = Offset.zero;
  double _startScale = 1;
  double _startRotation = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF161B27), Color(0xFF090E1A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Try On Studio',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[
                                Color(0xFF2B3245),
                                Color(0xFF1D2333),
                                Color(0xFF141A28),
                              ],
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: CustomPaint(painter: WristGuidePainter()),
                        ),
                        Positioned.fill(
                          child: GestureDetector(
                            onScaleStart: (ScaleStartDetails details) {
                              _startFocal = details.focalPoint;
                              _startOffset = _offset;
                              _startScale = _scale;
                              _startRotation = _rotation;
                            },
                            onScaleUpdate: (ScaleUpdateDetails details) {
                              setState(() {
                                _offset =
                                    _startOffset +
                                    (details.focalPoint - _startFocal);
                                _scale = (_startScale * details.scale).clamp(
                                  0.55,
                                  2.1,
                                );
                                _rotation = _startRotation + details.rotation;
                              });
                            },
                            child: Center(
                              child: Transform.translate(
                                offset: _offset,
                                child: Transform.rotate(
                                  angle: _rotation,
                                  child: Transform.scale(
                                    scale: _scale,
                                    child: Image.asset(
                                      widget.item.image,
                                      width: 230,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Pinch to zoom, rotate with two fingers, and drag to position on wrist guide.',
                    style: TextStyle(color: Color(0xFFC9D8F9), fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class WristGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint guidePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.18);

    final Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: <Color>[
          const Color(0xFFD2B49C).withValues(alpha: 0.18),
          const Color(0xFFAD7A63).withValues(alpha: 0.16),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final RRect wrist = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.58),
        width: size.width * 0.78,
        height: size.height * 0.26,
      ),
      const Radius.circular(120),
    );

    canvas.drawRRect(wrist, fillPaint);
    canvas.drawRRect(wrist, guidePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
