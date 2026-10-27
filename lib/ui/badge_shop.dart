import 'package:flutter/material.dart';

import '../data/badges.dart';
import '../data/cats.dart';
import '../data/shop_cats.dart';
import '../l10n.dart';
import '../services/progress.dart';
import 'keyboard_scroll.dart';
import 'theme.dart';
import 'coin.dart';

/// Round badge art: a gradient medal with big text, or a cat photo with
/// its phrase on a banner on top.
class BadgeArt extends StatelessWidget {
  const BadgeArt(this.badge, {super.key, this.size = 96, this.locked = false});

  final CatBadge badge;
  final double size;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final b = badge;
    final medal = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: b.colors,
        ),
        border: Border.all(
            color: locked ? AppTheme.cardEdge : AppTheme.accent2,
            width: size / 32),
      ),
      clipBehavior: Clip.antiAlias,
      child: !b.isPhoto
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(size / 9),
                child: FittedBox(
                  child: Text(b.art,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontSize: 40,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 6)
                          ])),
                ),
              ),
            )
          : Image.asset('assets/badges/${b.cat}.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(child: Text('🐱'))),
    );
    final art = !b.isPhoto || size < 40
        ? medal
        : Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Padding(padding: EdgeInsets.only(top: size / 7), child: medal),
              Container(
                constraints: BoxConstraints(maxWidth: size * 1.25),
                padding: EdgeInsets.symmetric(
                    horizontal: size / 14, vertical: size / 40),
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 4)
                  ],
                ),
                child: FittedBox(
                  child: Text(b.phrase!,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          fontSize: 13,
                          letterSpacing: 0.5)),
                ),
              ),
            ],
          );
    if (!locked) return art;
    return Opacity(
      opacity: 0.35,
      child: ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.33, 0.33, 0.33, 0, 0, //
          0.33, 0.33, 0.33, 0, 0, //
          0.33, 0.33, 0.33, 0, 0, //
          0, 0, 0, 1, 0,
        ]),
        child: art,
      ),
    );
  }
}

/// Miaudólar shop (fantasy badges) plus the goal badges album.
class BadgeShopScreen extends StatefulWidget {
  const BadgeShopScreen({super.key});

  @override
  State<BadgeShopScreen> createState() => _BadgeShopScreenState();
}

class _BadgeShopScreenState extends State<BadgeShopScreen> {
  final _shopScroll = ScrollController();
  final _catScroll = ScrollController();
  final _goalScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    checkGoalBadges(Progress.instance);
  }

  @override
  void dispose() {
    _shopScroll.dispose();
    _catScroll.dispose();
    _goalScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final p = Progress.instance;
    return DefaultTabController(
      length: 3,
      child: AnimatedBuilder(
        animation: p,
        builder: (context, _) => Scaffold(
          appBar: AppBar(
            title: Text('🛍️ ${l.pick('Tienda de insignias', 'Badge shop')}',
                style: const TextStyle(fontWeight: FontWeight.w800)),
            actions: const [CoinBadge(), SizedBox(width: 10)],
            bottom: TabBar(tabs: [
              Tab(
                  child: Tooltip(
                      message: l.pick(
                          'Fotos de gatos famosos para comprar y ponerte',
                          'Famous cat photos to buy and wear'),
                      child: Text(l.pick('Insignias', 'Badges')))),
              Tab(
                  child: Tooltip(
                      message: l.pick('Gatitos para adoptar con Miaudólares',
                          'Kitties to adopt with Miaudólares'),
                      child: Text(
                          '🐱 ${l.pick('Gatos', 'Cats')} ${kShopCats.where((c) => p.badges.contains(c.id)).length}/${kShopCats.length}'))),
              Tab(
                  child: Tooltip(
                      message: l.pick('Medallas de C++ que se ganan con metas',
                          'C++ medals earned with goals'),
                      child: Text(
                          '${l.pick('Logros', 'Goals')} ${kGoalBadges.where((b) => p.badges.contains(b.id)).length}/${kGoalBadges.length}'))),
            ]),
          ),
          body: TabBarView(children: [
            _grid(_shopScroll, kShopBadges, p, l),
            _catsGrid(p, l),
            _grid(_goalScroll, kGoalBadges, p, l),
          ]),
        ),
      ),
    );
  }

  Widget _grid(ScrollController sc, List<CatBadge> list, Progress p, L l) {
    return KeyboardScroll(
      controller: sc,
      child: GridView.builder(
        controller: sc,
        padding: const EdgeInsets.all(14),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 190,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.68,
        ),
        itemCount: list.length,
        itemBuilder: (context, i) => _card(list[i], p, l),
      ),
    );
  }

  Widget _card(CatBadge b, Progress p, L l) {
    final owned = p.badges.contains(b.id);
    final worn = p.equippedBadge == b.id;
    final Widget action;
    if (owned && !b.isShop) {
      action = Text(l.pick('¡Ganada!', 'Earned!'),
          style: const TextStyle(
              fontWeight: FontWeight.w800, color: AppTheme.accent2));
    } else if (owned) {
      action = Tooltip(
        message: worn
            ? l.pick('Sacártela del perfil', 'Remove it from your profile')
            : l.pick(
                'Mostrarla al lado de tu nombre', 'Show it next to your name'),
        child: worn
            ? FilledButton(
                onPressed: () => p.equipBadge(b.id),
                child: Text(l.pick('✓ Puesta', '✓ Worn')))
            : OutlinedButton(
                onPressed: () => p.equipBadge(b.id),
                child: Text(l.pick('Ponérmela', 'Wear it'))),
      );
    } else if (b.isShop) {
      action = Tooltip(
        message: l.pick('Comprar por ${b.price} Miaudólares',
            'Buy for ${b.price} Miaudólares'),
        child: FilledButton(
          onPressed: p.coins >= b.price ? () => _buy(b) : null,
          child: Text('${b.price} 🪙'),
        ),
      );
    } else {
      action = Text(l.pick(b.goalEs, b.goalEn),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: AppTheme.textLo));
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: Center(child: BadgeArt(b, size: 104, locked: !owned)),
            ),
            const SizedBox(height: 6),
            Text(l.pick(b.nameEs, b.nameEn),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800)),
            if (owned && !b.isShop)
              Text(l.pick(b.goalEs, b.goalEn),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: AppTheme.textLo)),
            const SizedBox(height: 6),
            action,
          ],
        ),
      ),
    );
  }

  Widget _catsGrid(Progress p, L l) {
    return KeyboardScroll(
      controller: _catScroll,
      child: GridView.builder(
        controller: _catScroll,
        padding: const EdgeInsets.all(14),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 170,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.74,
        ),
        itemCount: kShopCats.length,
        itemBuilder: (context, i) => _catCard(kShopCats[i], p, l),
      ),
    );
  }

  Widget _catCard(ShopCat c, Progress p, L l) {
    final owned = p.badges.contains(c.id);
    final img = ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.asset(c.file,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Center(child: Text('🐱', style: TextStyle(fontSize: 40)))),
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(
              child: owned
                  ? img
                  : Opacity(
                      opacity: 0.35,
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.matrix([
                          0.33, 0.33, 0.33, 0, 0, //
                          0.33, 0.33, 0.33, 0, 0, //
                          0.33, 0.33, 0.33, 0, 0, //
                          0, 0, 0, 1, 0,
                        ]),
                        child: img,
                      ),
                    ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: c.rarity.color),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(l.pick(c.nameEs, c.nameEn),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (owned)
              Text(l.pick('¡Tuyo!', 'Yours!'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.accent2,
                      fontSize: 12))
            else
              Tooltip(
                message: l.pick('Adoptar por ${c.price} Miaudólares',
                    'Adopt for ${c.price} Miaudólares'),
                child: FilledButton(
                  onPressed: p.coins >= c.price ? () => _buyCat(c) : null,
                  child: Text('${c.price} 🪙'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _buyCat(ShopCat c) {
    final l = L.instance;
    final ok = Progress.instance.buyBadge(c.id, c.price);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? l.pick('¡Adoptaste a "${c.nameEs}"!', 'You adopted "${c.nameEn}"!')
          : l.pick(
              'No te alcanzan los Miaudólares.', 'Not enough Miaudólares.')),
    ));
  }

  void _buy(CatBadge b) {
    final l = L.instance;
    final ok = Progress.instance.buyBadge(b.id, b.price);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? l.pick('¡Compraste "${b.nameEs}"! Tocá "Ponérmela" para mostrarla.',
              'You bought "${b.nameEn}"! Tap "Wear it" to show it.')
          : l.pick(
              'No te alcanzan los Miaudólares.', 'Not enough Miaudólares.')),
    ));
  }
}

/// Pop-up when a goal badge is earned.
Future<void> showNewBadges(BuildContext context, List<CatBadge> fresh) async {
  final l = L.instance;
  if (fresh.isEmpty || !context.mounted) return;
  final one = fresh.length == 1;
  await showDialog<void>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(
          one
              ? l.pick('¡Nueva insignia!', 'New badge!')
              : l.pick('¡${fresh.length} insignias nuevas!',
                  '${fresh.length} new badges!'),
          textAlign: TextAlign.center),
      content: SizedBox(
        width: one ? null : 460,
        child: SingleChildScrollView(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 14,
            runSpacing: 12,
            children: [
              for (final b in fresh)
                SizedBox(
                  width: one ? 220 : 130,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    BadgeArt(b, size: one ? 140 : 90),
                    const SizedBox(height: 8),
                    Text(l.pick(b.nameEs, b.nameEn),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: one ? 18 : 14)),
                    Text(l.pick(b.goalEs, b.goalEn),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppTheme.textLo, fontSize: 12)),
                  ]),
                ),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
            onPressed: () => Navigator.pop(c),
            child: Text(l.pick('¡Genial!', 'Great!'))),
      ],
    ),
  );
}
