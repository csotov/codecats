import 'package:flutter/material.dart';

import '../data/atcoder_lists.dart';
import '../l10n.dart';
import '../services/cloud.dart';
import '../services/open_url.dart';
import '../services/progress.dart';
import 'olympiad_screens.dart';
import 'professor.dart';
import 'theme.dart';

class AtcoderScreen extends StatefulWidget {
  const AtcoderScreen({super.key});

  @override
  State<AtcoderScreen> createState() => _AtcoderScreenState();
}

class _AtcoderScreenState extends State<AtcoderScreen> {
  bool _busy = false;

  Future<void> _verify() async {
    final p = Progress.instance;
    final l = L.instance;
    if (p.atcoderUser.isEmpty) return _askUser();
    setState(() => _busy = true);
    try {
      final ac = await atcoderAccepted(p.atcoderUser);
      var fresh = 0;
      for (final pr in kAtcoderProblems) {
        if (ac.contains(pr.id) && !p.of(pr.levelId).solved) {
          p.recordSolve(pr.levelId, 150, 3);
          fresh++;
        }
      }
      Cloud.instance.log('atcoder_verify', data: {'new': fresh});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(fresh > 0
              ? l.pick('¡$fresh problema(s) nuevos aceptados en AtCoder!',
                  '$fresh new problem(s) accepted on AtCoder!')
              : l.pick(
                  'Todavía no veo Accepted nuevos. Puede tardar unos minutos en aparecer.',
                  'No new Accepted yet. It can take a few minutes to show up.'))));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l.pick('No pude consultar AtCoder: $e',
              'Could not reach AtCoder: $e'))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _askUser() async {
    final l = L.instance;
    final ctrl = TextEditingController(text: Progress.instance.atcoderUser);
    final u = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.pick('Tu usuario de AtCoder', 'Your AtCoder user')),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c),
              child: Text(l.pick('Cancelar', 'Cancel'))),
          FilledButton(
              onPressed: () => Navigator.pop(c, ctrl.text),
              child: Text(l.pick('Guardar', 'Save'))),
        ],
      ),
    );
    if (u != null && u.trim().isNotEmpty) {
      Progress.instance.setAtcoderUser(u);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final p = Progress.instance;
    final w = worldReached(p);
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '🌏 ${l.pick('Problemas reales de AtCoder', 'Real AtCoder problems')}'),
        actions: [
          Tooltip(
            message:
                l.pick('Cambiar usuario de AtCoder', 'Change AtCoder user'),
            child: IconButton(
                icon: const Icon(Icons.person_outline), onPressed: _askUser),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: p,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(14),
          children: [
            ProfessorSays(
              text: l.pick(
                  'Estos son problemas de verdad del juez japonés AtCoder, el que usan los chicos de Japón. Abrilo, envialo allá con tu cuenta y tocá "Verificar": si sale AC, te pago acá.',
                  'These are real problems from AtCoder, the Japanese judge kids in Japan use. Open it, submit there with your account and tap "Verify": if it is AC, I pay you here.'),
            ),
            const SizedBox(height: 8),
            Text(
                p.atcoderUser.isEmpty
                    ? l.pick('Usuario: (sin configurar)', 'User: (not set)')
                    : '${l.pick('Usuario', 'User')}: ${p.atcoderUser}',
                style: const TextStyle(color: AppTheme.textLo)),
            const SizedBox(height: 8),
            for (final pr in kAtcoderProblems)
              Card(
                child: ListTile(
                  enabled: pr.minWorld <= w,
                  leading: Icon(
                      p.of(pr.levelId).solved
                          ? Icons.check_circle
                          : (pr.minWorld <= w ? Icons.public : Icons.lock),
                      color: p.of(pr.levelId).solved
                          ? AppTheme.good
                          : AppTheme.accent2),
                  title: Text(pr.titleEs),
                  subtitle: Text(pr.minWorld <= w
                      ? l.pick(pr.topicEs, pr.topicEn)
                      : l.pick('Se abre en el mundo ${pr.minWorld}',
                          'Opens in world ${pr.minWorld}')),
                  trailing: Tooltip(
                    message: l.pick('Abrir en AtCoder', 'Open on AtCoder'),
                    child: IconButton(
                      icon: const Icon(Icons.open_in_new),
                      onPressed:
                          pr.minWorld <= w ? () => openUrl(pr.url) : null,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Tooltip(
                message: l.pick('Buscar tus Accepted en AtCoder',
                    'Look up your Accepted on AtCoder'),
                child: FilledButton.icon(
                  onPressed: _busy ? null : _verify,
                  icon: const Icon(Icons.verified),
                  label: Text(l.pick('Verificar', 'Verify')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
