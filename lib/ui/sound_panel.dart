import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n.dart';
import '../services/sfx.dart';

/// Music on/off + volumes. Shared by every screen's app bar.
Future<void> showSoundPanel(BuildContext context) {
  final l = L.instance;
  return showDialog<void>(
    context: context,
    builder: (c) => StatefulBuilder(
      builder: (c, set) => AlertDialog(
        title: Text(l.t('sound_title')),
        content: SizedBox(
          width: math.min(380, MediaQuery.sizeOf(c).width - 72),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text(l.t('sound_music_on')),
                value: !Sfx.muted,
                onChanged: (_) async {
                  await Sfx.toggleMute();
                  set(() {});
                },
              ),
              ListTile(
                leading: const Icon(Icons.music_note),
                title: Text(l.t('sound_music')),
                subtitle: Slider(
                  value: Sfx.musicVolume,
                  onChanged: Sfx.muted
                      ? null
                      : (v) {
                          Sfx.setMusicVolume(v);
                          set(() {});
                        },
                ),
              ),
              ListTile(
                leading: const Text('🐱', style: TextStyle(fontSize: 22)),
                title: Text(l.t('sound_cats')),
                subtitle: Slider(
                  value: Sfx.memeVolume,
                  onChanged: (v) {
                    Sfx.setMemeVolume(v);
                    set(() {});
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: Text(l.t('close'))),
        ],
      ),
    ),
  );
}

/// App-bar button that opens [showSoundPanel]; icon shows if music is off.
class MusicButton extends StatefulWidget {
  const MusicButton({super.key});

  @override
  State<MusicButton> createState() => _MusicButtonState();
}

class _MusicButtonState extends State<MusicButton> {
  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: L.instance.t('tip_music'),
        icon: Icon(
            Sfx.muted ? Icons.music_off_outlined : Icons.music_note_outlined),
        onPressed: () async {
          await showSoundPanel(context);
          if (mounted) setState(() {});
        },
      );
}
