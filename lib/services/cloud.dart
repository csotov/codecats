import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase glue: accounts, cloud progress snapshot and gameplay
/// telemetry. Everything is a no-op when the app is built without
/// `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`,
/// so the game keeps working fully offline.
class Cloud extends ChangeNotifier {
  Cloud._();
  static final Cloud instance = Cloud._();

  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static bool get configured => url.isNotEmpty && anonKey.isNotEmpty;

  SupabaseClient? _c;
  bool get ready => _c != null;
  User? get user => _c?.auth.currentUser;
  bool get signedIn => user != null;
  bool isAdmin = false;
  String displayName = '';

  /// One id per app launch; groups events into sessions.
  final String sessionId =
      DateTime.now().millisecondsSinceEpoch.toRadixString(36);

  final List<Map<String, dynamic>> _queue = [];
  Timer? _flushTimer;

  Future<void> init() async {
    if (!configured) return;
    try {
      // ignore: deprecated_member_use
      await Supabase.initialize(url: url, anonKey: anonKey);
      _c = Supabase.instance.client;
      _c!.auth.onAuthStateChange.listen((_) => _refreshProfile());
      await _refreshProfile();
      _flushTimer = Timer.periodic(const Duration(seconds: 10), (_) => flush());
    } catch (e) {
      debugPrint('Cloud init failed: $e');
    }
  }

  Future<void> _refreshProfile() async {
    isAdmin = false;
    displayName = '';
    final u = user;
    if (u != null && _c != null) {
      try {
        final row = await _c!
            .from('profiles')
            .select('display_name, role')
            .eq('id', u.id)
            .maybeSingle();
        isAdmin = row?['role'] == 'admin';
        displayName = (row?['display_name'] as String?) ?? '';
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<String?> signUp(String email, String password, String name) async {
    if (_c == null) return 'offline';
    try {
      await _c!.auth.signUp(
          email: email, password: password, data: {'display_name': name});
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> signIn(String email, String password) async {
    if (_c == null) return 'offline';
    try {
      await _c!.auth.signInWithPassword(email: email, password: password);
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  Future<void> signOut() async {
    await flush();
    await _c?.auth.signOut();
  }

  // ---- progress snapshot (cross-device) ----

  Future<void> pushSnapshot(Map<String, dynamic> data) async {
    final u = user;
    if (u == null || _c == null) return;
    try {
      await _c!.from('progress_snapshots').upsert({
        'user_id': u.id,
        'data': data,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint('pushSnapshot: $e');
    }
  }

  Future<Map<String, dynamic>?> pullSnapshot() async {
    final u = user;
    if (u == null || _c == null) return null;
    try {
      final row = await _c!
          .from('progress_snapshots')
          .select('data')
          .eq('user_id', u.id)
          .maybeSingle();
      final d = row?['data'];
      if (d is Map) return Map<String, dynamic>.from(d);
      if (d is String) return jsonDecode(d) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('pullSnapshot: $e');
    }
    return null;
  }

  // ---- telemetry ----

  /// Record a gameplay event. Cheap: buffered and flushed every 10 s.
  void log(String type, {String? levelId, Map<String, dynamic>? data}) {
    if (_c == null || user == null) return;
    _queue.add({
      'user_id': user!.id,
      'session_id': sessionId,
      'ts': DateTime.now().toUtc().toIso8601String(),
      'type': type,
      'level_id': levelId,
      'data': data ?? const {},
    });
    if (_queue.length >= 40) flush();
  }

  Future<void> flush() async {
    if (_queue.isEmpty || _c == null) return;
    final batch = List<Map<String, dynamic>>.from(_queue);
    _queue.clear();
    try {
      await _c!.from('events').insert(batch);
    } catch (e) {
      debugPrint('flush: $e');
      _queue.insertAll(0, batch.take(200));
    }
  }

  // ---- admin ----

  Future<List<Map<String, dynamic>>> students() async {
    if (_c == null || !isAdmin) return const [];
    final rows = await _c!
        .from('profiles')
        .select('id, display_name, role, created_at')
        .order('created_at');
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<List<Map<String, dynamic>>> levelStats(String userId) async {
    if (_c == null) return const [];
    final rows = await _c!.rpc('admin_level_stats', params: {'p_user': userId});
    return List<Map<String, dynamic>>.from(rows as List);
  }

  Future<List<Map<String, dynamic>>> recentEvents(String userId,
      {int limit = 2000}) async {
    if (_c == null) return const [];
    final rows = await _c!
        .from('events')
        .select('ts, type, level_id, data, session_id')
        .eq('user_id', userId)
        .order('ts', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(rows);
  }
}
