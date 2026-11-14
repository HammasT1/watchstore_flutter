import 'dart:math' as math;

import 'package:flutter/material.dart';

const double tau = math.pi * 2;

/// Rebuilds [builder] every frame with `t` running 0 → 1 on repeat.
///
/// When the platform asks for reduced motion the loop holds still at `t = 0`.
class Loop extends StatefulWidget {
  const Loop({
    super.key,
    required this.duration,
    required this.builder,
    this.child,
  });

  final Duration duration;
  final Widget Function(BuildContext context, double t, Widget? child) builder;
  final Widget? child;

  @override
  State<Loop> createState() => _LoopState();
}

class _LoopState extends State<Loop> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool reduceMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion) {
      _controller
        ..stop()
        ..value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (BuildContext context, Widget? child) =>
          widget.builder(context, _controller.value, child),
    );
  }
}

/// Dark navy backdrop with slow drifting blobs of [color] light.
class AuroraBackground extends StatelessWidget {
  const AuroraBackground({super.key, required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF050912),
            Color(0xFF0D1D38),
            Color(0xFF0A1325),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          RepaintBoundary(
            child: Loop(
              duration: const Duration(seconds: 18),
              builder: (BuildContext context, double t, Widget? _) {
                return CustomPaint(painter: _AuroraPainter(t, color));
              },
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter(this.t, this.color);

  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double a = t * tau;
    final HSLColor hsl = HSLColor.fromColor(color);
    final Color shifted = hsl.withHue((hsl.hue + 45) % 360).toColor();

    void blob(Offset center, double radius, Color c, double alpha) {
      final Rect rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: <Color>[
              c.withValues(alpha: alpha),
              c.withValues(alpha: 0),
            ],
          ).createShader(rect),
      );
    }

    blob(
      Offset(
        size.width * (0.2 + 0.18 * math.sin(a)),
        size.height * (0.18 + 0.08 * math.cos(a)),
      ),
      size.width * 0.85,
      color,
      0.20,
    );
    blob(
      Offset(
        size.width * (0.85 + 0.12 * math.cos(a)),
        size.height * (0.72 + 0.1 * math.sin(a)),
      ),
      size.width * 0.9,
      color,
      0.16,
    );
    blob(
      Offset(
        size.width * (0.5 + 0.3 * math.sin(a + 2)),
        size.height * (0.45 + 0.12 * math.cos(a * 2)),
      ),
      size.width * 0.7,
      shifted,
      0.10,
    );
  }

  @override
  bool shouldRepaint(_AuroraPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color;
}

/// Sweeps a band of light across the opaque pixels of [child].
///
/// [progress] 0 → 1 moves the band from off the left edge to off the right.
class ShineSweep extends StatelessWidget {
  const ShineSweep({super.key, required this.progress, required this.child});

  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double center = -1.8 + 3.6 * progress.clamp(0.0, 1.0);
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment(center - 0.45, -0.5),
          end: Alignment(center + 0.45, 0.5),
          colors: const <Color>[
            Color(0x00FFFFFF),
            Color(0x8CFFFFFF),
            Color(0x00FFFFFF),
          ],
        ).createShader(bounds);
      },
      child: child,
    );
  }
}

/// Tilted elliptical orbits with comets travelling around them.
///
/// Paint once with `front: false` behind the subject and once with
/// `front: true` on top of it, so the comets pass around the subject.
class OrbitRingsPainter extends CustomPainter {
  OrbitRingsPainter({
    required this.t,
    required this.color,
    required this.front,
  });

  final double t;
  final Color color;
  final bool front;

  // (radius factor, flatten, tilt, laps per loop, phase)
  static const List<(double, double, double, int, double)> _rings =
      <(double, double, double, int, double)>[
        (0.46, 0.30, -0.35, 1, 0.0),
        (0.40, 0.36, 0.45, -1, 2.1),
        (0.50, 0.22, 0.08, 2, 4.0),
      ];

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    for (final (double r, double flatten, double tilt, int laps, double phase)
        in _rings) {
      final double rx = size.shortestSide * r;
      final double ry = rx * flatten;
      final Rect oval = Rect.fromCenter(
        center: Offset.zero,
        width: rx * 2,
        height: ry * 2,
      );

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(tilt);

      // The lower half of each ellipse is the near side.
      canvas.drawArc(
        oval,
        front ? 0 : math.pi,
        math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = color.withValues(alpha: front ? 0.30 : 0.14),
      );

      final double head = phase + t * tau * laps;
      const int segments = 16;
      const double step = 0.055;
      for (int i = 0; i < segments; i++) {
        final double angle = head - i * step * laps.sign;
        if ((math.sin(angle) >= 0) != front) {
          continue;
        }
        final double fade = 1 - i / segments;
        final Offset point = Offset(rx * math.cos(angle), ry * math.sin(angle));
        canvas.drawCircle(
          point,
          (i == 0 ? 3.2 : 2.2) * fade + 0.4,
          Paint()
            ..color = Color.lerp(
              color,
              Colors.white,
              i == 0 ? 0.7 : 0.2,
            )!.withValues(alpha: fade * (front ? 0.95 : 0.45)),
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(OrbitRingsPainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.color != color ||
      oldDelegate.front != front;
}

/// Small glints that drift upward and twinkle.
class SparklePainter extends CustomPainter {
  SparklePainter({required this.t, required this.color, this.count = 22});

  final double t;
  final Color color;
  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    final math.Random random = math.Random(7);
    for (int i = 0; i < count; i++) {
      final double x = random.nextDouble();
      final double y = random.nextDouble();
      final double phase = random.nextDouble();
      final int speed = 1 + random.nextInt(2);
      final double radius = 0.8 + random.nextDouble() * 1.8;
      final bool white = random.nextBool();

      final double life = (t * speed + phase) % 1.0;
      final double alpha = math.sin(life * math.pi);
      final Offset position = Offset(
        size.width * (x + 0.03 * math.sin((life + phase) * tau)),
        size.height * ((y - life * 0.35) % 1.0),
      );
      canvas.drawCircle(
        position,
        radius,
        Paint()
          ..color = (white ? Colors.white : color).withValues(
            alpha: alpha * 0.75,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(SparklePainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color;
}

/// A ring whose highlight chases around the circle.
class HaloRingPainter extends CustomPainter {
  HaloRingPainter({required this.t, required this.color});

  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = SweepGradient(
        colors: <Color>[
          color.withValues(alpha: 0),
          color.withValues(alpha: 0.9),
          color.withValues(alpha: 0),
        ],
        stops: const <double>[0.0, 0.25, 0.5],
        transform: GradientRotation(t * tau),
      ).createShader(rect);
    canvas.drawCircle(rect.center, size.shortestSide / 2 - 2, paint);
  }

  @override
  bool shouldRepaint(HaloRingPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color;
}

/// Fades and slides [child] in during its slice of [animation].
class StaggeredEntrance extends StatelessWidget {
  const StaggeredEntrance({
    super.key,
    required this.animation,
    required this.start,
    required this.child,
    this.span = 0.45,
  });

  final Animation<double> animation;
  final double start;
  final double span;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Animation<double> curved = CurvedAnimation(
      parent: animation,
      curve: Interval(
        start.clamp(0.0, 1.0),
        (start + span).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.35),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

/// Dollar amount that counts to its new value whenever [value] changes.
class AnimatedPrice extends StatelessWidget {
  const AnimatedPrice({
    super.key,
    required this.value,
    required this.style,
    this.from,
    this.duration = const Duration(milliseconds: 700),
  });

  final int value;
  final int? from;
  final TextStyle style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: from ?? value, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, int shown, Widget? _) {
        return Text('\$$shown', style: style);
      },
    );
  }
}

/// Heart toggle that pops and throws off a burst when it becomes active.
class FavoriteButton extends StatefulWidget {
  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
    this.size = 30,
  });

  final bool isFavorite;
  final VoidCallback onTap;
  final double size;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
    value: 1,
  );

  static final Animatable<double> _pop =
      TweenSequence<double>(<TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1, end: 0.7),
          weight: 15,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(
            begin: 0.7,
            end: 1,
          ).chain(CurveTween(curve: Curves.elasticOut)),
          weight: 85,
        ),
      ]);

  @override
  void didUpdateWidget(FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorite && !oldWidget.isFavorite) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.isFavorite ? 'Remove from favorites' : 'Add to favorites',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            return CustomPaint(
              painter: _BurstPainter(_controller.value),
              child: Transform.scale(
                scale: _pop.evaluate(_controller),
                child: child,
              ),
            );
          },
          child: Image.asset(
            widget.isFavorite
                ? 'assets/images/liked.png'
                : 'assets/images/unlike.png',
            width: widget.size,
            height: widget.size,
            color: widget.isFavorite ? const Color(0xFFFF5C7A) : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) {
      return;
    }
    final Offset center = size.center(Offset.zero);
    final double eased = Curves.easeOutCubic.transform(t);
    final double distance = size.shortestSide * (0.5 + 0.7 * eased);
    const List<Color> colors = <Color>[
      Color(0xFFFF5C7A),
      Color(0xFFFFC857),
      Color(0xFF63E5D7),
    ];
    for (int i = 0; i < 9; i++) {
      final double angle = i / 9 * tau;
      canvas.drawCircle(
        center + Offset(math.cos(angle), math.sin(angle)) * distance,
        2.6 * (1 - eased) + 0.4,
        Paint()..color = colors[i % 3].withValues(alpha: 1 - eased),
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) => oldDelegate.t != t;
}

/// Cart pill for page headers. Call [CartBadgeState.bump] to make it bounce.
class CartBadge extends StatefulWidget {
  const CartBadge({super.key, required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  State<CartBadge> createState() => CartBadgeState();
}

class CartBadgeState extends State<CartBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
    value: 1,
  );

  static final Animatable<double> _bounce =
      TweenSequence<double>(<TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1, end: 1.3),
          weight: 25,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(
            begin: 1.3,
            end: 1,
          ).chain(CurveTween(curve: Curves.elasticOut)),
          weight: 75,
        ),
      ]);

  void bump() => _controller.forward(from: 0);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: widget.count == 1 ? 'Cart, 1 item' : 'Cart, ${widget.count} items',
      child: GestureDetector(
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _bounce.animate(_controller),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset(
                  'assets/images/cart.png',
                  width: 18,
                  height: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.count}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
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

/// Minus / count / plus control.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onChanged,
    required this.accent,
    this.max = 9,
    this.compact = false,
  });

  final int quantity;
  final ValueChanged<int> onChanged;
  final Color accent;
  final int max;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double side = compact ? 30 : 40;

    Widget button(IconData icon, String label, VoidCallback? onPressed) {
      return Semantics(
        button: true,
        label: label,
        child: InkResponse(
          onTap: onPressed,
          radius: side * 0.7,
          child: Container(
            width: side,
            height: side,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: onPressed == null ? 0.06 : 0.18),
              border: Border.all(
                color: accent.withValues(alpha: onPressed == null ? 0.2 : 0.7),
              ),
            ),
            child: Icon(
              icon,
              size: side * 0.55,
              color: Colors.white.withValues(
                alpha: onPressed == null ? 0.3 : 1,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        button(
          quantity <= 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
          quantity <= 1 ? 'Remove' : 'Decrease quantity',
          () => onChanged(quantity - 1),
        ),
        SizedBox(
          width: compact ? 34 : 44,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Text(
              '$quantity',
              key: ValueKey<int>(quantity),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: compact ? 15 : 18,
              ),
            ),
          ),
        ),
        button(
          Icons.add_rounded,
          'Increase quantity',
          quantity >= max ? null : () => onChanged(quantity + 1),
        ),
      ],
    );
  }
}

/// Throws a shrinking copy of [image] from [from] along an arc into the
/// widget identified by [targetKey], then calls [onArrive].
void flyToCart(
  BuildContext context, {
  required String image,
  required Rect from,
  required GlobalKey targetKey,
  VoidCallback? onArrive,
}) {
  final OverlayState? overlay = Overlay.maybeOf(context, rootOverlay: true);
  final RenderObject? target = targetKey.currentContext?.findRenderObject();
  if (overlay == null || target is! RenderBox || !target.hasSize) {
    onArrive?.call();
    return;
  }
  final Offset to = target.localToGlobal(target.size.center(Offset.zero));

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (BuildContext context) {
      return _FlyingImage(
        image: image,
        from: from,
        to: to,
        onDone: () {
          entry.remove();
          onArrive?.call();
        },
      );
    },
  );
  overlay.insert(entry);
}

class _FlyingImage extends StatefulWidget {
  const _FlyingImage({
    required this.image,
    required this.from,
    required this.to,
    required this.onDone,
  });

  final String image;
  final Rect from;
  final Offset to;
  final VoidCallback onDone;

  @override
  State<_FlyingImage> createState() => _FlyingImageState();
}

class _FlyingImageState extends State<_FlyingImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 750),
          )
          ..addStatusListener((AnimationStatus status) {
            if (status == AnimationStatus.completed) {
              widget.onDone();
            }
          })
          ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Offset start = widget.from.center;
    final Offset end = widget.to;
    final Offset control = Offset(
      (start.dx + end.dx) / 2,
      math.min(start.dy, end.dy) - 90,
    );

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          final double t = Curves.easeInOutCubic.transform(_controller.value);
          final double u = 1 - t;
          final Offset position =
              start * (u * u) + control * (2 * u * t) + end * (t * t);
          final double size = widget.from.shortestSide * u + 26 * t;
          return Stack(
            children: <Widget>[
              Positioned(
                left: position.dx - size / 2,
                top: position.dy - size / 2,
                width: size,
                height: size,
                child: Opacity(
                  opacity: (1 - (t - 0.85) / 0.15).clamp(0.0, 1.0),
                  child: Transform.rotate(angle: t * 0.9, child: child),
                ),
              ),
            ],
          );
        },
        child: Image.asset(widget.image, fit: BoxFit.contain),
      ),
    );
  }
}
