import 'package:flutter/material.dart';

import '../models/watch_item.dart';
import '../state/store.dart';
import '../widgets/effects.dart';
import '../widgets/watch_showcase.dart';
import 'cart_page.dart';
import 'try_on_page.dart';

class WatchDetailPage extends StatefulWidget {
  const WatchDetailPage({
    super.key,
    required this.watch,
    required this.heroTag,
  });

  final WatchItem watch;

  /// Must match the tag of the Hero the watch was opened from.
  final Object heroTag;

  static Route<void> route(WatchItem watch, {required Object heroTag}) {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 520),
      reverseTransitionDuration: const Duration(milliseconds: 380),
      pageBuilder: (_, _, _) => WatchDetailPage(watch: watch, heroTag: heroTag),
      transitionsBuilder:
          (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: child,
            );
          },
    );
  }

  @override
  State<WatchDetailPage> createState() => _WatchDetailPageState();
}

class _WatchDetailPageState extends State<WatchDetailPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<CartBadgeState> _cartKey = GlobalKey<CartBadgeState>();
  final GlobalKey _showcaseKey = GlobalKey();

  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  void _addToCart() {
    final WatchItem watch = widget.watch;
    StoreScope.of(context).addToCart(watch.id);

    final RenderObject? stage = _showcaseKey.currentContext?.findRenderObject();
    if (stage is! RenderBox) {
      return;
    }
    final Offset center = stage.localToGlobal(stage.size.center(Offset.zero));
    flyToCart(
      context,
      image: watch.image,
      from: Rect.fromCenter(center: center, width: 220, height: 220),
      targetKey: _cartKey,
      onArrive: () => _cartKey.currentState?.bump(),
    );
  }

  void _push(Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final StoreController store = StoreScope.of(context);
    final WatchItem watch = widget.watch;
    final int quantity = store.quantityOf(watch.id);

    final List<(IconData, String, String)> specs = <(IconData, String, String)>[
      (Icons.straighten_rounded, 'Case', watch.caseSize),
      (Icons.settings_outlined, 'Movement', watch.movement),
      (Icons.water_drop_outlined, 'Water rating', watch.waterResistance),
      (Icons.watch_outlined, 'Strap', watch.strap),
    ];

    return Scaffold(
      body: AuroraBackground(
        color: watch.accent,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 20, 0),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      tooltip: 'Back',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    FavoriteButton(
                      isFavorite: store.isFavorite(watch.id),
                      onTap: () => store.toggleFavorite(watch.id),
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    CartBadge(
                      key: _cartKey,
                      count: store.cartCount,
                      onTap: () => _push(const CartPage()),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      WatchShowcase(
                        key: _showcaseKey,
                        watch: watch,
                        heroTag: widget.heroTag,
                      ),
                      Center(
                        child: StaggeredEntrance(
                          animation: _entrance,
                          start: 0.5,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.threed_rotation_rounded,
                                size: 16,
                                color: watch.accent,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Drag the watch to turn it',
                                style: TextStyle(
                                  color: Color(0xFFAFC2EA),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      StaggeredEntrance(
                        animation: _entrance,
                        start: 0.2,
                        child: Text(
                          watch.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      StaggeredEntrance(
                        animation: _entrance,
                        start: 0.28,
                        child: Text(
                          watch.description,
                          style: const TextStyle(
                            color: Color(0xFFD4E2FF),
                            height: 1.45,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      StaggeredEntrance(
                        animation: _entrance,
                        start: 0.36,
                        child: AnimatedPrice(
                          value: watch.price,
                          from: 0,
                          duration: const Duration(milliseconds: 1300),
                          style: TextStyle(
                            color: watch.accent,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (int row = 0; row < 2; row++) ...<Widget>[
                        StaggeredEntrance(
                          animation: _entrance,
                          start: 0.44 + row * 0.1,
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Expanded(
                                  child: _SpecCard(
                                    spec: specs[row * 2],
                                    accent: watch.accent,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _SpecCard(
                                    spec: specs[row * 2 + 1],
                                    accent: watch.accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: quantity == 0
                            ? SizedBox(
                                key: const ValueKey<String>('add'),
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: _addToCart,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: watch.accent,
                                    foregroundColor: const Color(0xFF0B1120),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 20,
                                  ),
                                  label: const Text(
                                    'Add to cart',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                key: const ValueKey<String>('stepper'),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: Colors.white12),
                                ),
                                alignment: Alignment.center,
                                child: QuantityStepper(
                                  quantity: quantity,
                                  accent: watch.accent,
                                  max: StoreController.maxQuantity,
                                  onChanged: (int next) {
                                    if (next > quantity) {
                                      _addToCart();
                                    } else {
                                      store.setQuantity(watch.id, next);
                                    }
                                  },
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () => _push(TryOnPage(item: watch)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: watch.accent),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 18,
                        ),
                      ),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text(
                        'Try on',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecCard extends StatelessWidget {
  const _SpecCard({required this.spec, required this.accent});

  final (IconData, String, String) spec;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, String label, String value) = spec;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.16),
            ),
            child: Icon(icon, size: 16, color: accent),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFFAFC2EA),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
