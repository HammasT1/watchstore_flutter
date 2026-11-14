import 'package:flutter/material.dart';

import '../models/watch_item.dart';
import '../state/store.dart';
import '../widgets/effects.dart';
import 'cart_page.dart';
import 'detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<CartBadgeState> _cartKey = GlobalKey<CartBadgeState>();

  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  void _moveToCart(BuildContext cardContext, WatchItem watch) {
    // Measure the card before the store update removes it from the grid.
    final RenderObject? card = cardContext.findRenderObject();
    final Rect? from = card is RenderBox
        ? Rect.fromCenter(
            center: card.localToGlobal(
              Offset(card.size.width / 2, card.size.width / 2),
            ),
            width: 120,
            height: 120,
          )
        : null;

    StoreScope.of(context).moveFavoriteToCart(watch.id);

    if (from != null) {
      flyToCart(
        context,
        image: watch.image,
        from: from,
        targetKey: _cartKey,
        onArrive: () => _cartKey.currentState?.bump(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final StoreController store = StoreScope.of(context);
    final List<WatchItem> favorites = store.favorites;

    return Scaffold(
      body: AuroraBackground(
        color: const Color(0xFFE58DBA),
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
                    const Expanded(
                      child: Text(
                        'Favorites',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 26,
                        ),
                      ),
                    ),
                    CartBadge(
                      key: _cartKey,
                      count: store.cartCount,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const CartPage(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  favorites.length == 1
                      ? '1 watch saved'
                      : '${favorites.length} watches saved',
                  style: const TextStyle(
                    color: Color(0xFFAFC2EA),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: favorites.isEmpty
                      ? const _EmptyFavorites()
                      : GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                mainAxisExtent: 268,
                              ),
                          itemCount: favorites.length,
                          itemBuilder: (BuildContext context, int index) {
                            final WatchItem watch = favorites[index];
                            return StaggeredEntrance(
                              key: ValueKey<String>(watch.id),
                              animation: _entrance,
                              start: (index * 0.12).clamp(0.0, 0.6),
                              span: 0.4,
                              child: _FavoriteCard(
                                watch: watch,
                                onRemove: () => store.toggleFavorite(watch.id),
                                onMoveToCart: (BuildContext cardContext) =>
                                    _moveToCart(cardContext, watch),
                              ),
                            );
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

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.watch,
    required this.onRemove,
    required this.onMoveToCart,
  });

  final WatchItem watch;
  final VoidCallback onRemove;
  final ValueChanged<BuildContext> onMoveToCart;

  @override
  Widget build(BuildContext context) {
    final String heroTag = 'favorite-${watch.id}';

    return GestureDetector(
      onTap: () => Navigator.of(
        context,
      ).push(WatchDetailPage.route(watch, heroTag: heroTag)),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: <Color>[
                            watch.accent.withValues(alpha: 0.32),
                            watch.accent.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Hero(
                      tag: heroTag,
                      child: Image.asset(watch.image, fit: BoxFit.contain),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: FavoriteButton(
                      isFavorite: true,
                      onTap: onRemove,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              watch.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '\$${watch.price}',
              style: TextStyle(
                color: watch.accent,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => onMoveToCart(context),
                style: FilledButton.styleFrom(
                  backgroundColor: watch.accent.withValues(alpha: 0.2),
                  foregroundColor: Colors.white,
                  side: BorderSide(color: watch.accent.withValues(alpha: 0.7)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Move to cart',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.favorite_border_rounded,
            size: 56,
            color: Colors.white.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 12),
          const Text(
            'No favorites yet',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap the heart on a watch to save it here.',
            style: TextStyle(color: Color(0xFFAFC2EA), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
