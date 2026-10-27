import 'package:flutter/material.dart';

import '../l10n.dart';
import '../services/progress.dart';
import 'theme.dart';

const kProfileEmojis = [
  '🐯', '🦊', '🐸', '🐼', '🦁', '🐙', '🦄', '🐺',
  '🐱', '🐶', '🦖', '🐧', '🤖', '👾', '🐝', '🐨',
];

/// Profile slots picker: each player gets independent progress.
class ProfilePicker extends StatefulWidget {
  const ProfilePicker({super.key});

  static Future<void> show(BuildContext context) => showDialog(
        context: context,
        builder: (_) => const ProfilePicker(),
      );

  @override
  State<ProfilePicker> createState() => _ProfilePickerState();
}

class _ProfilePickerState extends State<ProfilePicker> {
  bool _creating = false;
  final _name = TextEditingController();
  String _emoji = kProfileEmojis.first;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final progress = Progress.instance;
    return AlertDialog(
      backgroundColor: AppTheme.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(l.t('who_plays'),
          style: const TextStyle(fontWeight: FontWeight.w800)),
      content: SizedBox(
        width: 320,
        child: _creating ? _createForm(l) : _list(l, progress),
      ),
      actions: [
        if (!_creating)
          TextButton.icon(
            onPressed: () => setState(() => _creating = true),
            icon: const Icon(Icons.person_add_alt_1, size: 18),
            label: Text(l.t('new_profile')),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.t('cancel')),
        ),
      ],
    );
  }

  Widget _list(L l, Progress progress) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final p in progress.profiles)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: AppTheme.bgAlt,
              child: Text(p.emoji, style: const TextStyle(fontSize: 18)),
            ),
            title: Text(p.name,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            trailing: progress.active?.id == p.id
                ? const Icon(Icons.check_circle, color: AppTheme.good)
                : null,
            onTap: () async {
              final nav = Navigator.of(context);
              await progress.switchProfile(p.id);
              nav.pop();
            },
          ),
        const SizedBox(height: 8),
        Text(l.t('start_fresh'),
            style: const TextStyle(color: AppTheme.textLo, fontSize: 12)),
      ],
    );
  }

  Widget _createForm(L l) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.t('profile_name'),
            style: const TextStyle(color: AppTheme.textLo, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: _name,
          autofocus: true,
          maxLength: 16,
          style: const TextStyle(fontSize: 15),
          decoration: const InputDecoration(
            isDense: true,
            counterText: '',
          ),
        ),
        const SizedBox(height: 10),
        Text(l.t('choose_avatar'),
            style: const TextStyle(color: AppTheme.textLo, fontSize: 12)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final e in kProfileEmojis)
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => setState(() => _emoji = e),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: e == _emoji
                        ? AppTheme.accent.withOpacity(0.25)
                        : AppTheme.bgAlt,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: e == _emoji
                          ? AppTheme.accent
                          : AppTheme.cardEdge,
                    ),
                  ),
                  child: Text(e, style: const TextStyle(fontSize: 20)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () async {
              final nav = Navigator.of(context);
              await Progress.instance.createProfile(_name.text, _emoji);
              nav.pop();
            },
            icon: const Icon(Icons.add),
            label: Text(l.t('create')),
          ),
        ),
      ],
    );
  }
}
