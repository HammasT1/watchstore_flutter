import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/watch_item.dart';
import 'effects.dart';

/// The hero stage for a single watch: it floats, catches a sweep of light,
/// is circled by comets, and tilts in 3D when dragged.
class WatchShowcase extends StatefulWidget {
  const WatchShowcase({
    super.key,
    required this.watch,
    required this.heroTag,
    this.height = 340,
  });

  final WatchItem watch;
  final Object heroTag;
  final double height;

  @override
  State<WatchShowcase> createState() => _WatchShowcaseState();
}

class _WatchShowcaseState extends State<WatchShowcase>
    with TickerProviderStateMixin {
  static const double _maxYaw = 1.0;
  static const double _maxPitch = 0.6;

  late final AnimationController _entrance;
  late final AnimationController _spring;
  late final Animation<double> _stageIn;
  late final Animation<double> _spin;

  // dx is yaw, dy is pitch, both in radians.
  Offset _tilt = Offset.zero;
  Offset _releasedTilt = Offset.zero;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    _stageIn = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.15, 0.7, curve: Curves.easeOutBack),
    );
    // One full turn once the hero flight has landed. It starts and ends
    // face-on, so there is no jump when the flight hands over.
    _spin = Tween<double>(begin: tau, end: 0).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.35, 1, curve: Curves.easeOutCubic),
      ),
    );

    _spring =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 900),
        )..addListener(() {
          setState(() {
            _tilt = Offset.lerp(
              _releasedTilt,
              Offset.zero,
              Curves.elasticOut.transform(_spring.value),
            )!;
          });
        });
  }

  @override
  void dispose() {
    _entrance.dispose();
    _spring.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _spring.stop();
    setState(() {
      _tilt = Offset(
        (_tilt.dx + details.delta.dx * 0.012).clamp(-_maxYaw, _maxYaw),
        (_tilt.dy - details.delta.dy * 0.012).clamp(-_maxPitch, _maxPitch),
      );
    });
  }

  void _release() {
    _releasedTilt = _tilt;
    _spring.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = widget.watch.accent;
    final double height = widget.height;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: _onPanUpdate,
        onPanEnd: (_) => _release(),
        onPanCancel: _release,
        child: AnimatedBuilder(
          animation: _entrance,
          builder: (BuildContext context, Widget? _) {
            return Loop(
              duration: const Duration(seconds: 8),
              builder: (BuildContext context, double t, Widget? _) {
                final double wave = math.sin(t * tau * 2);
                final double bob = wave * 8;
                final double sway = math.sin(t * tau) * 0.12;
                final double stage = _stageIn.value;
                final double yaw = _tilt.dx + sway + _spin.value;

                return Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    // Glow, far orbits and glints scale in behind the watch.
                    Opacity(
                      opacity: stage.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: 0.5 + 0.5 * stage,
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Transform.scale(
                              scale: 1 + 0.06 * wave,
                              child: Container(
                                width: height * 0.9,
                                height: height * 0.9,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: <Color>[
                                      accent.withValues(alpha: 0.42),
                                      accent.withValues(alpha: 0.10),
                                      accent.withValues(alpha: 0),
                                    ],
                                    stops: const <double>[0, 0.55, 1],
                                  ),
                                ),
                              ),
                            ),
                            CustomPaint(
                              size: Size.square(height),
                              painter: SparklePainter(t: t, color: accent),
                            ),
                            CustomPaint(
                              size: Size.square(height),
                              painter: OrbitRingsPainter(
                                t: t,
                                color: accent,
                                front: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Contact shadow that tightens as the watch rises.
                    Positioned(
                      bottom: height * 0.04,
                      child: Opacity(
                        opacity: stage.clamp(0.0, 1.0),
                        child: Container(
                          width: height * (0.36 + 0.03 * wave),
                          height: 16,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(99),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: 0.42 + 0.08 * wave,
                                ),
                                blurRadius: 22,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(0, bob),
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0014)
                          ..rotateX(_tilt.dy)
                          ..rotateY(yaw),
                        child: ShineSweep(
                          // The band crosses during the first third of
                          // each half-loop, then rests.
                          progress: ((t * 2) % 1.0) / 0.35,
                          child: Hero(
                            tag: widget.heroTag,
                            child: Image.asset(
                              widget.watch.image,
                              height: height * 0.8,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IgnorePointer(
                      child: Opacity(
                        opacity: stage.clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale: 0.5 + 0.5 * stage,
                          child: CustomPaint(
                            size: Size.square(height),
                            painter: OrbitRingsPainter(
                              t: t,
                              color: accent,
                              front: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
