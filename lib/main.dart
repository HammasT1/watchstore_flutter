import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const WatchStoreApp());
}

class WatchStoreApp extends StatelessWidget {
  const WatchStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chrono Vault',
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFEE8A2E),
          secondary: Color(0xFF63E5D7),
          surface: Color(0xFF131B2C),
        ),
        scaffoldBackgroundColor: const Color(0xFF0B1120),
        useMaterial3: true,
      ),
      home: const WatchStoreHome(),
    );
  }
}

class WatchItem {
  const WatchItem({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.accent,
    required this.description,
  });

  final String id;
  final String name;
  final String image;
  final int price;
  final Color accent;
  final String description;
}

class WatchStoreHome extends StatefulWidget {
  const WatchStoreHome({super.key});

  @override
  State<WatchStoreHome> createState() => _WatchStoreHomeState();
}

class _WatchStoreHomeState extends State<WatchStoreHome> {
  final List<WatchItem> _watches = <WatchItem>[
    const WatchItem(
      id: 'w1',
      name: 'Aurelia Pulse',
      image: 'assets/images/1.png',
      price: 299,
      accent: Color(0xFFEE8A2E),
      description: 'Rose gold body with precision quartz movement.',
    ),
    const WatchItem(
      id: 'w2',
      name: 'Nebula Edge',
      image: 'assets/images/2.png',
      price: 359,
      accent: Color(0xFF6CF4DE),
      description: 'Ultra-light frame and a sapphire-inspired face.',
    ),
    const WatchItem(
      id: 'w3',
      name: 'Titan Crest',
      image: 'assets/images/3.png',
      price: 409,
      accent: Color(0xFF91A4FF),
      description: 'Industrial finish with all-day comfort straps.',
    ),
    const WatchItem(
      id: 'w4',
      name: 'Velvet Orbit',
      image: 'assets/images/4.png',
      price: 329,
      accent: Color(0xFFE58DBA),
      description: 'Elegant profile designed for evening style.',
    ),
    const WatchItem(
      id: 'w5',
      name: 'Carbon Drift',
      image: 'assets/images/5.png',
      price: 389,
      accent: Color(0xFFF2C66B),
      description: 'Sport build with premium carbon fiber texture.',
    ),
    const WatchItem(
      id: 'w6',
      name: 'Solar Arc',
      image: 'assets/images/6.png',
      price: 439,
      accent: Color(0xFF65C4FF),
      description: 'Clean analog style powered by a solar module.',
    ),
    const WatchItem(
      id: 'w7',
      name: 'Midnight Alloy',
      image: 'assets/images/7.png',
      price: 469,
      accent: Color(0xFFB5A0FF),
      description: 'Midnight tone case with polished metallic accents.',
    ),
    const WatchItem(
      id: 'w8',
      name: 'Linea Spark',
      image: 'assets/images/image2.png',
      price: 279,
      accent: Color(0xFF7AE7B3),
      description: 'Slim profile dial made for lightweight daily wear.',
    ),
    const WatchItem(
      id: 'w9',
      name: 'Nova Classic',
      image: 'assets/images/image3.png',
      price: 319,
      accent: Color(0xFFFFB079),
      description: 'Classic analog face with premium balanced strap.',
    ),
    const WatchItem(
      id: 'w10',
      name: 'Monarch Signature',
      image: 'assets/images/watch.png',
      price: 529,
      accent: Color(0xFFFFE08A),
      description: 'Signature edition with luxury crown detailing.',
    ),
    const WatchItem(
      id: 'w11',
      name: 'Branco Edition',
      image: 'assets/images/watch_branco.png',
      price: 549,
      accent: Color(0xFFC8F2FF),
      description: 'Branco edition with elegant bright-tone finishing.',
    ),
  ];

  late final PageController _pageController;
  final Set<String> _favoriteIds = <String>{};
  final Set<String> _cartIds = <String>{};

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

  void _toggleFavorite(WatchItem item) {
    setState(() {
      if (_favoriteIds.contains(item.id)) {
        _favoriteIds.remove(item.id);
      } else {
        _favoriteIds.add(item.id);
      }
    });
  }

  void _addToCart(WatchItem item) {
    final bool alreadyAdded = _cartIds.contains(item.id);
    setState(() {
      _cartIds.add(item.id);
    });
    if (!alreadyAdded) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1000),
            content: Text('${item.name} added to cart'),
          ),
        );
    }
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

  void _openTryOn(WatchItem item) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<TryOnPage>(builder: (_) => TryOnPage(item: item)));
  }

  void _openCartCollection() {
    final List<WatchItem> items = _watches
        .where((WatchItem item) => _cartIds.contains(item.id))
        .toList();

    Navigator.of(context).push(
      MaterialPageRoute<CartCollectionPage>(
        builder: (_) => CartCollectionPage(items: items),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final WatchItem selected = _selectedWatch;
    final bool isFavorite = _favoriteIds.contains(selected.id);
    final bool isInCart = _cartIds.contains(selected.id);

    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  children: <Widget>[
                    const Expanded(
                      child: Text(
                        'Chrono Vault',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _openCartCollection,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          children: <Widget>[
                            Image.asset(
                              'assets/images/cart.png',
                              width: 18,
                              height: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_cartIds.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: Column(
                      key: ValueKey<String>(selected.id),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 12),
                        Row(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () => _toggleFavorite(selected),
                              child: Image.asset(
                                isFavorite
                                    ? 'assets/images/liked.png'
                                    : 'assets/images/unlike.png',
                                width: 30,
                                height: 30,
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () => _shareWatch(selected),
                              child: Image.asset(
                                'assets/images/share.png',
                                width: 26,
                                height: 26,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          selected.name,
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
                        Text(
                          '\$${selected.price}',
                          style: TextStyle(
                            color: selected.accent,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _addToCart(selected),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isInCart
                                      ? const Color(0xFF2D9F6D)
                                      : selected.accent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                  elevation: 0,
                                ),
                                icon: Image.asset(
                                  'assets/images/cart.png',
                                  width: 18,
                                  height: 18,
                                ),
                                label: Text(
                                  isInCart ? 'Added to cart' : 'Add to cart',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _openTryOn(selected),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: selected.accent),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
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
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 260,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _watches.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    final WatchItem watch = _watches[index];
                    final double distance = (index - _currentPage).abs();
                    final double clamped = distance.clamp(0.0, 1.2);
                    final double scale = 1.12 - (clamped * 0.28);
                    final double opacity = 1 - (clamped * 0.48);
                    final double yOffset = clamped * 22;

                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Opacity(
                          opacity: opacity,
                          child: Transform.translate(
                            offset: Offset(0, yOffset),
                            child: Transform.scale(
                              scale: scale,
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
                                  ClipRect(
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      heightFactor: 0.56,
                                      child: Hero(
                                        tag: watch.id,
                                        child: Image.asset(
                                          watch.image,
                                          fit: BoxFit.contain,
                                          height: 260,
                                        ),
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
                  },
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 18,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(_watches.length, (int i) {
                    final double activeDistance = (_currentPage - i).abs();
                    final bool isActive = activeDistance < 0.5;
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                        );
                      },
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
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

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

class CartCollectionPage extends StatefulWidget {
  const CartCollectionPage({super.key, required this.items});

  final List<WatchItem> items;

  @override
  State<CartCollectionPage> createState() => _CartCollectionPageState();
}

class _CartCollectionPageState extends State<CartCollectionPage> {
  int _selectedPayment = 0;

  int get _total => widget.items.fold<int>(0, (int sum, WatchItem item) {
    return sum + item.price;
  });

  void _openSmartCheckout() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SmartCheckoutSheet(
          total: _total,
          selectedPayment: _selectedPayment,
          onPaymentChange: (int index) {
            setState(() {
              _selectedPayment = index;
            });
          },
          onPlaceOrder: () {
            Navigator.of(context).pop();
            _showOrderSuccess();
          },
        );
      },
    );
  }

  void _showOrderSuccess() {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'success',
      pageBuilder: (BuildContext context, _, __) {
        return Center(
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
                const Icon(
                  Icons.verified_rounded,
                  color: Color(0xFF6AF5C6),
                  size: 54,
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
                const SizedBox(height: 8),
                const Text(
                  'Your premium watches are on the way.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFC6D9FF), fontSize: 14),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Awesome'),
                ),
              ],
            ),
          ),
        );
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
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Cart Collection',
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
                  '${widget.items.length} watches selected',
                  style: const TextStyle(
                    color: Color(0xFFAFC2EA),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: widget.items.isEmpty
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
                          itemCount: widget.items.length,
                          separatorBuilder: (BuildContext context, int index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (BuildContext context, int index) {
                            final WatchItem item = widget.items[index];
                            return Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Image.asset(
                                    item.image,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFFAFC2EA),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '\$${item.price}',
                                    style: TextStyle(
                                      color: item.accent,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                if (widget.items.isNotEmpty) ...<Widget>[
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
                        Text(
                          '\$$_total',
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
                      onPressed: _openSmartCheckout,
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

class SmartCheckoutSheet extends StatefulWidget {
  const SmartCheckoutSheet({
    super.key,
    required this.total,
    required this.selectedPayment,
    required this.onPaymentChange,
    required this.onPlaceOrder,
  });

  final int total;
  final int selectedPayment;
  final ValueChanged<int> onPaymentChange;
  final VoidCallback onPlaceOrder;

  @override
  State<SmartCheckoutSheet> createState() => _SmartCheckoutSheetState();
}

class _SmartCheckoutSheetState extends State<SmartCheckoutSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _etaController;

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
    final List<String> methods = <String>['Visa **** 4218', 'Master **** 9031'];

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
                    children: List<Widget>.generate(methods.length, (
                      int index,
                    ) {
                      final bool selected = index == widget.selectedPayment;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            widget.onPaymentChange(index);
                            setState(() {});
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
                              methods[index],
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
                        const Text(
                          'Total payable',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
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
