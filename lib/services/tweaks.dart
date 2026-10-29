import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/worlds.dart';
import 'activity.dart';
import 'cloud.dart';

/// Topic keys of a level: its concepts plus its world ("mundo 2").
List<String> levelTopics(String id) {
  final lv = levelById(id);
  if (lv == null) return const [];
  final wi = kWorlds.indexWhere((w) => w.levels.contains(lv));
  return [...lv.concepts, if (wi >= 0) 'mundo ${wi + 1}'];
}

/// Coaching decisions applied from the admin report (table coach_tweaks).
/// Actions: 'hint1' shows hint 1 free from the start; 'harder' turns off
/// the automatic free hint. Topic is a concept, 'mundo N' or 'level:ID'.
class Tweaks extends ChangeNotifier {
  Tweaks._();
  static final instance = Tweaks._();
  static const _cacheKey = 'coach_tweaks_cache';

  List<Map<String, dynamic>> applied = const [];

  bool has(String action, String levelId) {
    final keys = {
      'level:$levelId',
      for (final t in levelTopics(levelId)) normConcept(t),
    };
    return applied
        .any((t) => t['action'] == action && keys.contains(t['topic']));
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    if (cached != null && applied.isEmpty) {
      try {
        applied = [
          for (final j in jsonDecode(cached) as List)
            Map<String, dynamic>.from(j as Map)
        ];
      } catch (_) {}
    }
    final c = Cloud.instance.client;
    final u = Cloud.instance.user;
    if (c == null || u == null) return;
    try {
      final rows = await c
          .from('coach_tweaks')
          .select('topic, action')
          .eq('student_id', u.id)
          .eq('status', 'applied');
      applied = List<Map<String, dynamic>>.from(rows);
      await prefs.setString(_cacheKey, jsonEncode(applied));
      notifyListeners();
    } catch (_) {
      // offline: keep the cache
    }
  }

  // ---- admin ----

  Future<List<Map<String, dynamic>>> forStudent(String id) async {
    final c = Cloud.instance.client;
    if (c == null) return const [];
    try {
      final rows = await c
          .from('coach_tweaks')
          .select('topic, action, status, evidence, updated_at')
          .eq('student_id', id);
      return List<Map<String, dynamic>>.from(rows);
    } catch (_) {
      return const [];
    }
  }

  Future<void> decide(String student, String topic, String action,
      String status, String evidence) async {
    final c = Cloud.instance.client;
    if (c == null) return;
    await c.from('coach_tweaks').upsert({
      'student_id': student,
      'topic': topic,
      'action': action,
      'status': status,
      'evidence': evidence,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'student_id,topic,action');
  }

  Future<void> undo(String student, String topic, String action) async {
    final c = Cloud.instance.client;
    if (c == null) return;
    await c
        .from('coach_tweaks')
        .delete()
        .eq('student_id', student)
        .eq('topic', topic)
        .eq('action', action);
  }
}
