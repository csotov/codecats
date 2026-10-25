import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../data/cats.dart';
import '../l10n.dart';
import '../services/progress.dart';
import '../services/prefetch_io.dart'
    if (dart.library.js_interop) '../services/prefetch_web.dart';
import '../services/sfx.dart';
import 'theme.dart';

/// Full-screen "brainrot burst": a cat-meme clip plays once with its
/// audio, framed like a sticker drop, then dismisses itself.
/// Tap anywhere to skip.
class MemeBurst {
  /// [minDuration]: short clips loop until at least this long has
  /// passed, so no meme flashes by too fast to enjoy.
  /// Download clips in the background before they are needed.
  static void warm(Iterable<CatMeme> cats) {
    prefetchAssets([for (final c in cats) c.file]);
  }

  static Future<void> show(BuildContext context, CatMeme cat,
      {String? captionEs,
      String? captionEn,
      Duration minDuration = const Duration(seconds: 2)}) {
    Progress.instance.markSeen(cat.id);
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (_) => _BurstDialog(
          cat: cat,
          capEs: captionEs,
          capEn: captionEn,
          minDuration: minDuration),
    );
  }
}

class _BurstDialog extends StatefulWidget {
  const _BurstDialog(
      {required this.cat, this.capEs, this.capEn, required this.minDuration});
  final CatMeme cat;
  final String? capEs, capEn;
  final Duration minDuration;

  @override
  State<_BurstDialog> createState() => _BurstDialogState();
}

class _BurstDialogState extends State<_BurstDialog>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _vc;
  late final AnimationController _pop;
  Timer? _autoClose;
  bool _ready = false;
  final _shown = Stopwatch()..start();

  @override
  void initState() {
    super.initState();
    _pop = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..forward();
    _init();
    // Safety net only; the real cap starts once the clip is playing,
    // so prefetch/initialize time never cuts the video short.
    _autoClose = Timer(const Duration(seconds: 12), _close);
  }

  Future<void> _init() async {
    try {
      // Make sure the whole clip is local before it starts, so it never
      // freezes halfway (fast when MemeBurst.warm already fetched it).
      await prefetchAssets([widget.cat.file])
          .timeout(const Duration(seconds: 3), onTimeout: () {});
      if (!mounted) return;
      final c = VideoPlayerController.asset(widget.cat.file);
      _vc = c;
      await c.initialize();
      await c.setVolume(Sfx.memeVolume);
      _hold();
      var looping = false;
      c.addListener(() {
        if (looping ||
            !c.value.isInitialized ||
            c.value.position < c.value.duration) {
          return;
        }
        if (_shown.elapsed >= widget.minDuration) {
          _close();
        } else {
          looping = true;
          c
              .seekTo(Duration.zero)
              .then((_) => c.play())
              .whenComplete(() => looping = false);
        }
      });
      await c.play();
      _autoClose?.cancel();
      final clip = c.value.duration + const Duration(milliseconds: 600);
      final min = widget.minDuration + const Duration(milliseconds: 1500);
      _autoClose = Timer(clip > min ? clip : min, _close);
      if (mounted) setState(() => _ready = true);
    } catch (_) {
      _close(); // never let a meme break the game
    }
  }

  bool _closed = false;

  /// Pops only this dialog, once. The video listener keeps firing at the
  /// end of the clip; a second pop would close the screen underneath.
  void _close() {
    if (!mounted || _closed) return;
    _closed = true;
    _autoClose?.cancel();
    _vc?.pause();
    _release();
    Navigator.of(context, rootNavigator: true).pop();
  }

  bool _holding = false;

  void _hold() {
    if (_holding || _closed) return;
    _holding = true;
    Sfx.holdMusic();
  }

  void _release() {
    if (!_holding) return;
    _holding = false;
    Sfx.releaseMusic();
  }

  @override
  void dispose() {
    _autoClose?.cancel();
    _release();
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
      // Taps can't skip the meme before its minimum on-screen time.
      onTap: () {
        if (_shown.elapsed >= widget.minDuration) _close();
      },
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
                    border:
                        Border.all(color: widget.cat.rarity.color, width: 3),
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
      await c.setVolume(Sfx.memeVolume);
      if (!mounted) return;
      _holding = true;
      Sfx.holdMusic();
      await c.play();
      if (mounted) setState(() => _ready = true);
    } catch (_) {}
  }

  bool _holding = false;

  @override
  void dispose() {
    if (_holding) Sfx.releaseMusic();
    _vc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready || _vc == null) {
      return Container(
          height: widget.height,
          color: AppTheme.bgAlt,
          child:
              const Center(child: CircularProgressIndicator(strokeWidth: 2)));
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
