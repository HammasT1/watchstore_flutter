import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../models/watch_item.dart';
import '../state/store.dart';
import '../widgets/effects.dart';
import 'cart_page.dart';
import 'detail_page.dart';
import 'favorites_page.dart';
import 'orders_page.dart';
import 'try_on_page.dart';

class WatchStoreHome extends StatefulWidget {
  const WatchStoreHome({super.key});

  @override
  State<WatchStoreHome> createState() => _WatchStoreHomeState();
}

class _WatchStoreHomeState extends State<WatchStoreHome> {
  static const List<WatchItem> _watches = watchCatalog;

  final GlobalKey<CartBadgeState> _cartKey = GlobalKey<CartBadgeState>();
  final GlobalKey _carouselKey = GlobalKey();

  late final PageController _pageController;

  double _currentPage = 0;
  int _selectedIndex = 0;

  WatchItem get _selectedWatch => _watches[_selectedIndex];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.58);
    _pageController.addListener(_onPageScroll);
  }

  void _onPageScroll() {
    final double page = _pageController.page ?? 0;
    if (!mounted) {
      return;
    }
    setState(() {
      _currentPage = page;
      _selectedIndex = page.round().clamp(0, _watches.length - 1);
    });
  }

  @override
  void dispose() {
    _pageController
      ..removeListener(_onPageScroll)
      ..dispose();
    super.dispose();
  }

  /// Accent blended between the two watches the carousel is resting between.
  Color get _ambientColor {
    final int lower = _currentPage.floor().clamp(0, _watches.length - 1);
    final int upper = _currentPage.ceil().clamp(0, _watches.length - 1);
    return Color.lerp(
      _watches[lower].accent,
      _watches[upper].accent,
      (_currentPage - lower).clamp(0.0, 1.0),
    )!;
  }

  void _addToCart(WatchItem item) {
    StoreScope.of(context).addToCart(item.id);

    final RenderObject? carousel = _carouselKey.currentContext
        ?.findRenderObject();
    if (carousel is! RenderBox) {
      return;
    }
    final Offset center = carousel.localToGlobal(
      carousel.size.center(Offset.zero),
    );
    flyToCart(
      context,
      image: item.image,
      from: Rect.fromCenter(center: center, width: 170, height: 170),
      targetKey: _cartKey,
      onArrive: () => _cartKey.currentState?.bump(),
    );
  }

  void _shareWatch(WatchItem item) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 900),
          content: Text('Shared ${item.name}'),
        ),
      );
  }

  void _push(Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  void _openDetail(WatchItem item) {
    Navigator.of(context).push(WatchDetailPage.route(item, heroTag: item.id));
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final StoreController store = StoreScope.of(context);
    final WatchItem selected = _selectedWatch;
    final int quantity = store.quantityOf(selected.id);

    return Scaffold(
      body: AuroraBackground(
        color: _ambientColor,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              _buildHeader(store),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.06, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                    child: _buildInfo(store, selected, quantity),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                key: _carouselKey,
                height: 260,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _watches.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: _buildCarouselItem,
                ),
              ),
              const SizedBox(height: 8),
              _buildIndicator(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(StoreController store) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        children: <Widget>[
          const Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'Chrono Vault',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Favorites',
            onPressed: () => _push(const FavoritesPage()),
            icon: Badge(
              isLabelVisible: store.favoriteCount > 0,
              label: Text('${store.favoriteCount}'),
              backgroundColor: const Color(0xFFFF5C7A),
              child: const Icon(
                Icons.favorite_border_rounded,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Orders',
            onPressed: () => _push(const OrdersPage()),
            icon: const Icon(Icons.receipt_long_outlined, color: Colors.white),
          ),
          const SizedBox(width: 4),
          CartBadge(
            key: _cartKey,
            count: store.cartCount,
            onTap: () => _push(const CartPage()),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(StoreController store, WatchItem selected, int quantity) {
    return Column(
      key: ValueKey<String>(selected.id),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            FavoriteButton(
              isFavorite: store.isFavorite(selected.id),
              onTap: () => store.toggleFavorite(selected.id),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _shareWatch(selected),
              child: Image.asset(
                'assets/images/share.png',
                width: 26,
                height: 26,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          selected.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          selected.description,
          style: const TextStyle(
            color: Color(0xFFD4E2FF),
            height: 1.45,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: <Widget>[
            Text(
              '\$${selected.price}',
              style: TextStyle(
                color: selected.accent,
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _openDetail(selected),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text(
                'Details',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: quantity >= StoreController.maxQuantity
                    ? null
                    : () => _addToCart(selected),
                style: ElevatedButton.styleFrom(
                  backgroundColor: quantity > 0
                      ? const Color(0xFF2D9F6D)
                      : selected.accent,
                  foregroundColor: quantity > 0
                      ? Colors.white
                      : const Color(0xFF0B1120),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  elevation: 0,
                ),
                icon: Image.asset(
                  'assets/images/cart.png',
                  width: 18,
                  height: 18,
                  color: quantity > 0 ? Colors.white : const Color(0xFF0B1120),
                ),
                label: Text(
                  quantity > 0 ? 'In cart · $quantity' : 'Add to cart',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _push(TryOnPage(item: selected)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: selected.accent),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text(
                  'Try on',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCarouselItem(BuildContext context, int index) {
    final WatchItem watch = _watches[index];
    final double delta = index - _currentPage;
    final double clamped = delta.abs().clamp(0.0, 1.2);
    final double scale = 1.12 - (clamped * 0.28);
    final double opacity = 1 - (clamped * 0.48);
    final double yOffset = clamped * 22;
    final double focus = (1 - delta.abs()).clamp(0.0, 1.0);
    final bool isSelected = index == _selectedIndex;

    Widget image = Hero(
      tag: watch.id,
      child: Image.asset(watch.image, fit: BoxFit.contain, height: 260),
    );
    if (isSelected) {
      // The watch in focus breathes and catches a passing light.
      image = Loop(
        duration: const Duration(seconds: 5),
        child: image,
        builder: (BuildContext context, double t, Widget? child) {
          return Transform.translate(
            offset: Offset(0, math.sin(t * tau) * 5 * focus),
            child: ShineSweep(progress: t / 0.4, child: child!),
          );
        },
      );
    }

    return Semantics(
      button: true,
      label: isSelected ? '${watch.name}, view details' : watch.name,
      child: GestureDetector(
        onTap: () => isSelected ? _openDetail(watch) : _goToPage(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(0, yOffset),
              child: Transform(
                alignment: Alignment.center,
                // Neighbours turn away from the centre like a coverflow.
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateY((delta * -0.6).clamp(-0.9, 0.9))
                  ..scaleByDouble(scale, scale, 1, 1),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: <Color>[
                            watch.accent.withValues(alpha: 0.35),
                            watch.accent.withValues(alpha: 0.02),
                          ],
                        ),
                      ),
                    ),
                    if (focus > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Opacity(
                          opacity: focus,
                          child: Loop(
                            duration: const Duration(seconds: 6),
                            builder:
                                (BuildContext context, double t, Widget? _) {
                                  return CustomPaint(
                                    size: const Size.square(200),
                                    painter: HaloRingPainter(
                                      t: t,
                                      color: watch.accent,
                                    ),
                                  );
                                },
                          ),
                        ),
                      ),
                    ClipRect(
                      child: Align(
                        alignment: Alignment.topCenter,
                        heightFactor: 0.56,
                        child: image,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator() {
    return SizedBox(
      height: 18,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List<Widget>.generate(_watches.length, (int i) {
          final bool isActive = (_currentPage - i).abs() < 0.5;
          return GestureDetector(
            onTap: () => _goToPage(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 26 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: isActive
                    ? _selectedWatch.accent
                    : Colors.white.withValues(alpha: 0.28),
              ),
            ),
          );
        }),
      ),
    );
  }
}
