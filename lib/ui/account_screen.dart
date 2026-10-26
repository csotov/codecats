import 'package:flutter/material.dart';

import '../l10n.dart';
import '../services/cloud.dart';
import '../services/progress.dart';

/// Sign in / sign up with email + password so progress follows the
/// player to any device. Optional: the game works offline without it.
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _name = TextEditingController();
  bool _signup = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = L.instance;
    setState(() {
      _busy = true;
      _error = null;
    });
    final email = _email.text.trim();
    final pass = _pass.text;
    String? err;
    if (email.isEmpty || pass.length < 6) {
      err = l.pick('Escribí tu email y una contraseña de al menos 6 letras.',
          'Enter your email and a password of at least 6 characters.');
    } else if (_signup) {
      err = await Cloud.instance.signUp(email, pass, _name.text.trim());
      // Email confirmation may be on: try to sign in anyway.
      if (err == null && !Cloud.instance.signedIn) {
        err = await Cloud.instance.signIn(email, pass);
      }
    } else {
      err = await Cloud.instance.signIn(email, pass);
    }
    if (err == null && Cloud.instance.signedIn) {
      await Progress.instance.adoptCloudSnapshot();
      Cloud.instance.log('sign_in', data: {'signup': _signup});
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = err;
    });
    if (err == null && Cloud.instance.signedIn) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l.pick('¡Listo! Tu progreso ya se guarda en la nube.',
              'Done! Your progress is now saved in the cloud.'))));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final c = Cloud.instance;
    return Scaffold(
      appBar: AppBar(title: Text(l.pick('Tu cuenta', 'Your account'))),
      body: AnimatedBuilder(
        animation: c,
        builder: (context, _) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: c.signedIn ? _signedIn(l, c) : _form(l),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _signedIn(L l, Cloud c) => [
        const Icon(Icons.cloud_done_outlined, size: 64, color: Colors.green),
        const SizedBox(height: 12),
        Text(
          l.pick('Conectado como ${c.user!.email}',
              'Signed in as ${c.user!.email}'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          l.pick(
              'Tu progreso se guarda solo. Entrá con este mismo email en otro dispositivo para seguir donde dejaste.',
              'Your progress saves automatically. Sign in with this email on another device to continue.'),
          textAlign: TextAlign.center,
        ),
        if (c.isAdmin) ...[
          const SizedBox(height: 8),
          Text(l.pick('Sos admin.', 'You are an admin.'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
        const SizedBox(height: 24),
        Tooltip(
          message: l.pick(
              'Cerrar sesión en este dispositivo', 'Sign out on this device'),
          child: OutlinedButton.icon(
            onPressed: () async {
              await c.signOut();
              if (mounted) setState(() {});
            },
            icon: const Icon(Icons.logout),
            label: Text(l.pick('Cerrar sesión', 'Sign out')),
          ),
        ),
      ];

  List<Widget> _form(L l) => [
        Text(
          _signup
              ? l.pick('Crear cuenta', 'Create account')
              : l.pick('Entrar', 'Sign in'),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(l.pick(
            'Con una cuenta tu progreso, tus gatos y tus Miaudólares te siguen a cualquier compu o celular.',
            'With an account your progress, cats and Meowdollars follow you to any computer or phone.')),
        const SizedBox(height: 16),
        if (_signup)
          TextField(
            controller: _name,
            decoration: InputDecoration(
                labelText: l.pick('Tu nombre', 'Your name'),
                border: const OutlineInputBorder()),
          ),
        if (_signup) const SizedBox(height: 10),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(
              labelText: 'Email', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _pass,
          obscureText: true,
          onSubmitted: (_) => _busy ? null : _submit(),
          decoration: InputDecoration(
              labelText: l.pick('Contraseña', 'Password'),
              border: const OutlineInputBorder()),
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(_error!, style: const TextStyle(color: Colors.redAccent)),
        ],
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_signup
                  ? l.pick('Crear cuenta', 'Create account')
                  : l.pick('Entrar', 'Sign in')),
        ),
        TextButton(
          onPressed: () => setState(() => _signup = !_signup),
          child: Text(_signup
              ? l.pick('Ya tengo cuenta', 'I already have an account')
              : l.pick('Soy nuevo: crear cuenta', 'New here: create account')),
        ),
      ];
}
