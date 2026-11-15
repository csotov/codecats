import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../services/cloud.dart';
import '../services/progress.dart';
import '../services/sfx.dart';

const kObiExamVideo = 'assets/video/examen_obi.mp4';

/// The Profe's narrated walkthrough of exam day: CMS, the Ubuntu terminal,
/// Geany and uploading the file. Reports how much of it was watched.
class ObiVideoScreen extends StatefulWidget {
  const ObiVideoScreen({super.key});

  @override
  State<ObiVideoScreen> createState() => _ObiVideoScreenState();
}

class _ObiVideoScreenState extends State<ObiVideoScreen> {
  final _vc = VideoPlayerController.asset(kObiExamVideo);
  bool _ready = false, _failed = false, _ended = false;
  Duration _max = Duration.zero;

  @override
  void initState() {
    super.initState();
    Cloud.instance.log('obi_video_open');
    Sfx.holdMusic();
    _vc.addListener(_tick);
    _vc.initialize().then((_) async {
      if (!mounted) return;
      await _vc.setVolume(1);
      setState(() => _ready = true);
      await _vc.play();
    }, onError: (_) {
      if (mounted) setState(() => _failed = true);
    });
  }

  void _tick() {
    final v = _vc.value;
    if (!v.isInitialized) return;
    if (v.position > _max) _max = v.position;
    if (!_ended && v.duration > Duration.zero && v.position >= v.duration) {
      _ended = true;
      Progress.instance.recordScore('vid:obi_exam', 1);
      Cloud.instance.log('obi_video_end');
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    final d = _vc.value.duration.inSeconds;
    if (_ready && d > 0) {
      Cloud.instance.log('obi_video_close', data: {
        'watched_s': _max.inSeconds,
        'pct': (100 * _max.inSeconds / d).round(),
      });
    }
    _vc.removeListener(_tick);
    _vc.dispose();
    Sfx.releaseMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = _vc.value;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF222222),
        title: const Text('🎬 Así es el examen',
            style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: Center(
          child: _failed
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No se pudo cargar el video. Revisá internet.',
                      style: TextStyle(color: Colors.white70)),
                )
              : !_ready
                  ? const CircularProgressIndicator()
                  : Column(mainAxisSize: MainAxisSize.min, children: [
                      Flexible(
                        child: AspectRatio(
                          aspectRatio: v.aspectRatio,
                          child: GestureDetector(
                            onTap: _toggle,
                            child: VideoPlayer(_vc),
                          ),
                        ),
                      ),
                      if (MediaQuery.orientationOf(context) ==
                          Orientation.portrait)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text('📱 Girá el celular para verlo grande',
                              style: TextStyle(color: Colors.white70)),
                        ),
                      VideoProgressIndicator(_vc,
                          allowScrubbing: true,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          colors: const VideoProgressColors(
                              playedColor: Color(0xFF4FB3E8))),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              tooltip: 'Volver 10 segundos',
                              color: Colors.white,
                              iconSize: 32,
                              onPressed: () => _vc.seekTo(
                                  v.position - const Duration(seconds: 10)),
                              icon: const Icon(Icons.replay_10),
                            ),
                            IconButton(
                              tooltip: v.isPlaying ? 'Pausa' : 'Reproducir',
                              color: Colors.white,
                              iconSize: 44,
                              onPressed: _toggle,
                              icon: Icon(v.isPlaying
                                  ? Icons.pause_circle
                                  : Icons.play_circle),
                            ),
                            Text('${_fmt(v.position)} / ${_fmt(v.duration)}',
                                style: const TextStyle(color: Colors.white70)),
                          ]),
                    ]),
        ),
      ),
    );
  }

  void _toggle() {
    final v = _vc.value;
    if (v.isPlaying) {
      _vc.pause();
    } else {
      if (v.position >= v.duration) _vc.seekTo(Duration.zero);
      _vc.play();
    }
  }

  String _fmt(Duration d) =>
      '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
}
