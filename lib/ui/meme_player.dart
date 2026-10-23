import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../data/cats.dart';
import '../l10n.dart';
import 'theme.dart';

/// Full-screen "brainrot burst": a cat-meme clip plays once with its
/// audio, framed like a sticker drop, then dismisses itself.
/// Tap anywhere to skip.
class MemeBurst {
  static Future<void> show(BuildContext context, CatMeme cat,
      {String? captionEs, String? captionEn}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (_) => _BurstDialog(cat: cat, capEs: captionEs, capEn: captionEn),
    );
  }
}

class _BurstDialog extends StatefulWidget {
  const _BurstDialog({required this.cat, this.capEs, this.capEn});
  final CatMeme cat;
  final String? capEs, capEn;

  @override
  State<_BurstDialog> createState() => _BurstDialogState();
}

class _BurstDialogState extends State<_BurstDialog>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _vc;
  late final AnimationController _pop;
  Timer? _autoClose;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _pop = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..forward();
    _init();
    _autoClose = Timer(const Duration(seconds: 5), _close);
  }

  Future<void> _init() async {
    try {
      final c = VideoPlayerController.asset(widget.cat.file);
      _vc = c;
      await c.initialize();
      c.addListener(() {
        if (c.value.isInitialized &&
            c.value.position >= c.value.duration) {
          _close();
        }
      });
      await c.play();
      if (mounted) setState(() => _ready = true);
    } catch (_) {
      _close(); // never let a meme break the game
    }
  }

  void _close() {
    if (!mounted) return;
    _autoClose?.cancel();
    Navigator.of(context, rootNavigator: true).maybePop();
  }

  @override
  void dispose() {
    _autoClose?.cancel();
    _vc?.dispose();
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final name = l.pick(widget.cat.nameEs, widget.cat.nameEn);
    final cap = widget.capEs == null
        ? null
        : l.pick(widget.capEs!, widget.capEn ?? widget.capEs!);
    return GestureDetector(
      onTap: _close,
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: ScaleTransition(
            scale: CurvedAnimation(parent: _pop, curve: Curves.elasticOut),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    color: AppTheme.bgAlt,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: widget.cat.rarity.color, width: 3),
                    boxShadow: [
                      BoxShadow(
                          color: widget.cat.rarity.color.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 2),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _ready && _vc != null
                      ? FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _vc!.value.size.width,
                            height: _vc!.value.size.height,
                            child: VideoPlayer(_vc!),
                          ),
                        )
                      : const Center(
                          child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: widget.cat.rarity.color),
                  ),
                  child: Text(
                    cap == null ? name : '$name — $cap',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 15),
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

/// Small inline player used inside the collection detail: muted-able,
/// loops, tap to pause/play.
class MemeTile extends StatefulWidget {
  const MemeTile({super.key, required this.cat, this.height = 140});
  final CatMeme cat;
  final double height;

  @override
  State<MemeTile> createState() => _MemeTileState();
}

class _MemeTileState extends State<MemeTile> {
  VideoPlayerController? _vc;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final c = VideoPlayerController.asset(widget.cat.file);
      _vc = c;
      await c.initialize();
      await c.setLooping(true);
      await c.play();
      if (mounted) setState(() => _ready = true);
    } catch (_) {}
  }

  @override
  void dispose() {
    _vc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready || _vc == null) {
      return Container(
          height: widget.height,
          color: AppTheme.bgAlt,
          child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2)));
    }
    return SizedBox(
      height: widget.height,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _vc!.value.size.width,
          height: _vc!.value.size.height,
          child: VideoPlayer(_vc!),
        ),
      ),
    );
  }
}
