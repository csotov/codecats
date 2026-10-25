import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/cats.dart';
import '../data/worlds.dart';
import '../models.dart';

/// Per-level saved state.
class LevelProgress {
  LevelProgress({
    this.solved = false,
    this.stars = 0,
    this.attempts = 0,
    this.hintUsed = false,
    this.hintsBought = 0,
    this.code = '',
    this.blocksJson,
  });

  bool solved;
  int stars;
  int attempts;
  bool hintUsed;

  /// Hints already paid for with Miaudólares (stay unlocked forever).
  int hintsBought;
  String code;
  List<dynamic>? blocksJson;

  Map<String, dynamic> toJson() => {
        's': solved,
        'st': stars,
        'a': attempts,
        'h': hintUsed,
        if (hintsBought > 0) 'hb': hintsBought,
        'c': code,
        if (blocksJson != null) 'b': blocksJson,
      };

  factory LevelProgress.fromJson(Map<String, dynamic> j) => LevelProgress(
        solved: j['s'] == true,
        stars: (j['st'] as num?)?.toInt() ?? 0,
        attempts: (j['a'] as num?)?.toInt() ?? 0,
        hintUsed: j['h'] == true,
        hintsBought: (j['hb'] as num?)?.toInt() ?? 0,
        code: j['c'] as String? ?? '',
        blocksJson: j['b'] as List<dynamic>?,
      );
}

/// A player slot: independent progress so several kids can share a
/// device (or one player can start from zero without losing the old run).
class Profile {
  Profile({required this.id, required this.name, required this.emoji});

  final String id;
  String name;
  String emoji;

  Map<String, dynamic> toJson() => {'id': id, 'n': name, 'e': emoji};

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        id: j['id'] as String,
        name: j['n'] as String? ?? 'Jugador',
        emoji: j['e'] as String? ?? '🐯',
      );
}

/// Global persistent progress: XP, solved levels, saved code, language —
/// namespaced by the active [Profile] slot.
class Progress extends ChangeNotifier {
  Progress._();
  static final Progress instance = Progress._();

  static const _legacyKey = 'codecats_progress_v1';
  static const _profilesKey = 'codecats_profiles_v1';
  static const _activeKey = 'codecats_active_v1';
  static String _keyFor(String id) => 'codecats_progress_$id';

  int xp = 0;

  /// Miaudólares: in-game cat money. Earned by winning battles,
  /// spent on hints.
  int coins = kStartCoins;

  /// Coins earned by the most recent [recordSolve] (for the victory card).
  int lastCoinsEarned = 0;

  static const kStartCoins = 30;
  static const kHintCost = 10;

  final Map<String, LevelProgress> levels = {};

  /// Cat-meme collection: ids of unlocked cats (see data/cats.dart).
  final Set<String> unlockedCats = {};

  /// Big O classes the professor already explained.
  final Set<String> taughtBigO = {};

  /// Consecutive victories — resets on a failed battle.
  int streak = 0;

  /// Daily training streak — a little every day beats a lot once
  /// a week (the Gomel/China training rule).
  int dayStreak = 0;

  /// 'yyyy-mm-dd' of the last day a level was solved.
  String lastSolveDay = '';

  /// Epoch-day of the first solve — anchors the ghost rival's
  /// steady advance (~1 level every 2 days).
  int ghostStartDay = 0;

  final List<Profile> profiles = [];
  Profile? active;

  Future<void>? _loading;

  Future<void> ensureLoaded() => _loading ??= _load();

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    // profiles
    final rawProfiles = prefs.getString(_profilesKey);
    if (rawProfiles != null) {
      try {
        for (final j in jsonDecode(rawProfiles) as List) {
          profiles.add(Profile.fromJson(Map<String, dynamic>.from(j)));
        }
      } catch (_) {}
    }
    // migrate legacy single-slot progress -> first profile
    if (profiles.isEmpty) {
      final p = Profile(
          id: 'p${DateTime.now().millisecondsSinceEpoch}',
          name: 'Jugador 1',
          emoji: '🐯');
      profiles.add(p);
      final legacy = prefs.getString(_legacyKey);
      if (legacy != null) {
        await prefs.setString(_keyFor(p.id), legacy);
        await prefs.remove(_legacyKey);
      }
      await prefs.setString(
          _profilesKey, jsonEncode(profiles.map((e) => e.toJson()).toList()));
      await prefs.setString(_activeKey, p.id);
    }
    final activeId = prefs.getString(_activeKey) ?? profiles.first.id;
    await _loadProfile(activeId, save: false);
    notifyListeners();
  }

  Future<void> _loadProfile(String id, {bool save = true}) async {
    final prefs = await SharedPreferences.getInstance();
    active =
        profiles.firstWhere((p) => p.id == id, orElse: () => profiles.first);
    xp = 0;
    coins = kStartCoins;
    streak = 0;
    dayStreak = 0;
    lastSolveDay = '';
    ghostStartDay = 0;
    levels.clear();
    unlockedCats.clear();
    final raw = prefs.getString(_keyFor(active!.id));
    if (raw != null) {
      try {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        xp = (j['xp'] as num?)?.toInt() ?? 0;
        (j['lv'] as Map?)?.forEach((k, v) {
          levels['$k'] =
              LevelProgress.fromJson(Map<String, dynamic>.from(v as Map));
        });
        streak = (j['st'] as num?)?.toInt() ?? 0;
        // Profiles from before Miaudólares get a starting purse plus
        // a reward for the levels they already beat.
        coins = (j['mc'] as num?)?.toInt() ??
            kStartCoins + 15 * levels.values.where((p) => p.solved).length;
        dayStreak = (j['dsk'] as num?)?.toInt() ?? 0;
        lastSolveDay = j['rd'] as String? ?? '';
        ghostStartDay = (j['gh'] as num?)?.toInt() ?? 0;
        unlockedCats
          ..clear()
          ..addAll((j['cats'] as List? ?? const []).map((e) => '$e'));
        taughtBigO
          ..clear()
          ..addAll((j['bo'] as List? ?? const []).map((e) => '$e'));
      } catch (_) {/* corrupted state -> start fresh */}
    }
    if (save) await prefs.setString(_activeKey, active!.id);
  }

  Future<void> _save() async {
    if (active == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _keyFor(active!.id),
        jsonEncode({
          'xp': xp,
          'mc': coins,
          'st': streak,
          'dsk': dayStreak,
          'rd': lastSolveDay,
          'gh': ghostStartDay,
          'cats': unlockedCats.toList(),
          'bo': taughtBigO.toList(),
          'lv': levels.map((k, v) => MapEntry(k, v.toJson())),
        }));
  }

  Future<void> _saveProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _profilesKey, jsonEncode(profiles.map((e) => e.toJson()).toList()));
  }

  /// Create a fresh slot and make it active (starts from zero).
  Future<Profile> createProfile(String name, String emoji) async {
    final p = Profile(
        id: 'p${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim().isEmpty ? 'Jugador' : name.trim(),
        emoji: emoji);
    profiles.add(p);
    await _saveProfiles();
    await _loadProfile(p.id);
    await _save();
    notifyListeners();
    return p;
  }

  /// Switch to an existing slot.
  Future<void> switchProfile(String id) async {
    if (active?.id == id) return;
    await _loadProfile(id);
    notifyListeners();
  }

  /// Rename/recolor the active profile.
  Future<void> updateActive({String? name, String? emoji}) async {
    if (active == null) return;
    if (name != null && name.trim().isNotEmpty) active!.name = name.trim();
    if (emoji != null) active!.emoji = emoji;
    await _saveProfiles();
    notifyListeners();
  }

  LevelProgress of(String levelId) => levels[levelId] ??= LevelProgress();

  /// Returns earned XP for this solve (first solve gives full XP).
  /// Also pays Miaudólares (see [coinsForSolve]) into [lastCoinsEarned].
  int recordSolve(String levelId, int levelXp, int stars,
      {bool codeMode = false, bool boss = false}) {
    final p = of(levelId);
    var earned = 0;
    lastCoinsEarned =
        coinsForSolve(firstSolve: !p.solved, stars: stars, boss: boss);
    coins += lastCoinsEarned;
    if (!p.solved) {
      earned = levelXp;
      xp += levelXp;
      p.solved = true;
    }
    if (stars > p.stars) p.stars = stars;
    streak++;
    _bumpDayStreak();
    _lastSolve = _SolveCtx(stars: stars, codeMode: codeMode, boss: boss);
    _save();
    notifyListeners();
    return earned;
  }

  /// First wins pay well (more stars, more coins; bosses pay a bonus);
  /// replays pay a little so a stuck player can earn hint money.
  static int coinsForSolve(
          {required bool firstSolve, required int stars, bool boss = false}) =>
      firstSolve ? 10 + 5 * stars + (boss ? 20 : 0) : 3;

  /// Pay [kHintCost] for the next hint of [levelId]. Returns false
  /// (and charges nothing) when the purse is too light.
  bool buyHint(String levelId) {
    if (coins < kHintCost) return false;
    final p = of(levelId);
    coins -= kHintCost;
    p.hintsBought++;
    p.hintUsed = true;
    _save();
    notifyListeners();
    return true;
  }

  /// O(1) is explained together with O(n), when loops arrive.
  bool shouldTeachBigO(String id) => id != 'c1' && !taughtBigO.contains(id);

  void markBigOTaught(String id) {
    taughtBigO.add(id);
    if (id == 'n') taughtBigO.add('c1');
    _save();
    notifyListeners();
  }

  /// Free hint from the professor's tutorial (after repeated fails).
  void giftHint(String levelId) {
    final p = of(levelId);
    p.hintsBought++;
    p.hintUsed = true;
    _save();
    notifyListeners();
  }

  static String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static int _epochDay(DateTime d) => d.millisecondsSinceEpoch ~/ 86400000;

  /// A solve on a new day extends the daily streak if it continues
  /// yesterday's, otherwise it restarts at 1.
  void _bumpDayStreak() {
    final now = DateTime.now();
    final today = _dayKey(now);
    if (lastSolveDay == today) return;
    dayStreak = (lastSolveDay == _dayKey(now.subtract(const Duration(days: 1))))
        ? dayStreak + 1
        : 1;
    lastSolveDay = today;
    ghostStartDay = ghostStartDay == 0 ? _epochDay(now) : ghostStartDay;
  }

  /// Ghost rival: a steady ~1 level every 2 days since the first
  /// solve — a gentle race to keep daily practice going.
  int get ghostSolved => ghostStartDay == 0
      ? 0
      : ((_epochDay(DateTime.now()) - ghostStartDay) * 0.5).floor();

  /// Upsolving queue: attempted but never beaten.
  List<String> get pendingIds => [
        for (final e in levels.entries)
          if (e.value.attempts > 0 && !e.value.solved) e.key,
      ];

  /// Call when a battle is lost: resets the win streak.
  void failBattle() {
    if (streak != 0) {
      streak = 0;
      _save();
      notifyListeners();
    }
  }

  _SolveCtx? _lastSolve;

  /// The Gatoteca lists exactly the cats the player has seen on screen.
  void markSeen(String id) {
    if (!unlockedCats.add(id)) return;
    _save();
    notifyListeners();
  }

  static final _rng = math.Random();
  int _dryChecks = 0;

  /// Cats whose unlock condition is currently met but not yet owned.
  /// Evaluated after events; returns the freshly unlocked memes.
  /// Drip-feeds the collection: at most one cat per event, and only
  /// sometimes (variable reward). Pending cats come out on later events;
  /// after two empty events in a row the next one always gives a cat.
  /// Starter ('always') cats are never granted here: they join the
  /// Gatoteca only when actually shown (see [markSeen]).
  List<CatMeme> checkCatUnlocks() {
    final fresh = <CatMeme>[];
    for (final c in kCats) {
      if (unlockedCats.contains(c.id)) continue;
      if (c.trigger == CatTrigger.always) continue;
      if (!_catMet(c.trigger, c.need)) continue;
      if (fresh.isNotEmpty) break;
      fresh.add(c);
    }
    if (fresh.isNotEmpty) {
      final give =
          unlockedCats.isEmpty || _dryChecks >= 2 || _rng.nextDouble() < 0.5;
      if (give) {
        _dryChecks = 0;
      } else {
        _dryChecks++;
        fresh.clear();
      }
    }
    unlockedCats.addAll(fresh.map((c) => c.id));
    if (fresh.isNotEmpty) {
      _save();
      notifyListeners();
    }
    _lastSolve = null;
    return fresh;
  }

  bool _catMet(CatTrigger t, int need) {
    final s = _lastSolve;
    switch (t) {
      case CatTrigger.always:
        return true;
      case CatTrigger.firstWin:
        return solvedCount >= 1;
      case CatTrigger.perfect:
        return s?.stars == 3;
      case CatTrigger.fail:
        return false; // banana cat is 'always' — kept for future cats
      case CatTrigger.streak3:
        return streak >= 3;
      case CatTrigger.syntaxFix:
        return s != null &&
            levels.values.any((p) => p.solved && p.attempts > 1);
      case CatTrigger.hint:
        return levels.values.any((p) => p.hintUsed);
      case CatTrigger.tryHard:
        return levels.values.any((p) => p.attempts >= 3);
      case CatTrigger.codeMode:
        return s?.codeMode == true;
      case CatTrigger.worldBoss:
        return s?.boss == true;
      case CatTrigger.worldUnlock:
        final worldsSolved = kWorlds
            .where((w) => w.levels.any((lv) => levels[lv.id]?.solved == true))
            .length;
        return worldsSolved >= 2;
      case CatTrigger.solved10:
        return solvedCount >= 10;
      case CatTrigger.solved25:
        return solvedCount >= 25;
      case CatTrigger.solved50:
        return solvedCount >= 50;
      case CatTrigger.rankGold:
        return xp >= 5000;
      case CatTrigger.rankIoi:
        return xp >= 20000;
      case CatTrigger.allStarsW1:
        final w1 = kWorlds.first;
        return w1.levels.every((lv) => (levels[lv.id]?.stars ?? 0) >= 3);
      case CatTrigger.solvedN:
        return solvedCount >= need;
      case CatTrigger.starsN:
        return totalStars >= need;
      case CatTrigger.triesN:
        return levels.values.fold(0, (n, p) => n + p.attempts) >= need;
      case CatTrigger.coinsN:
        return coins >= need;
    }
  }

  void recordAttempt(String levelId) {
    of(levelId).attempts++;
    _save();
    notifyListeners();
  }

  void saveCode(String levelId, String code, {List<dynamic>? blocksJson}) {
    final p = of(levelId);
    p.code = code;
    if (blocksJson != null) p.blocksJson = blocksJson;
    _save();
  }

  /// Campaign rule: the first level of every world is always unlocked,
  /// so the player can jump between worlds freely; inside a world,
  /// each level opens when the previous one is solved.
  bool isUnlocked(Level level, World world) {
    final idx = world.levels.indexWhere((l) => l.id == level.id);
    if (idx <= 0) return true;
    return levels[world.levels[idx - 1].id]?.solved ?? false;
  }

  int get totalStars => levels.values.fold(0, (s, p) => s + p.stars);

  int get solvedCount => levels.values.where((p) => p.solved).length;

  /// Reset only the ACTIVE profile's progress (start from zero).
  Future<void> reset() async {
    xp = 0;
    coins = kStartCoins;
    streak = 0;
    unlockedCats.clear();
    taughtBigO.clear();
    levels.clear();
    final prefs = await SharedPreferences.getInstance();
    if (active != null) {
      await prefs.remove(_keyFor(active!.id));
    }
    notifyListeners();
  }
}

/// Player rank derived from XP.
class _SolveCtx {
  _SolveCtx({required this.stars, required this.codeMode, required this.boss});
  final int stars;
  final bool codeMode;
  final bool boss;
}

class Rank {
  const Rank(this.key, this.minXp, this.color);
  final String key; // l10n key suffix: rank_bronze...
  final int minXp;
  final int color;
}

const kRanks = [
  Rank('rank_bronze', 0, 0xFFCD7F32),
  Rank('rank_silver', 2000, 0xFFC0C0C0),
  Rank('rank_gold', 5000, 0xFFFFD700),
  Rank('rank_platinum', 9000, 0xFF7FE7DC),
  Rank('rank_diamond', 14000, 0xFF6EC6FF),
  Rank('rank_ioi', 20000, 0xFFFF5252),
];

Rank rankForXp(int xp) {
  var r = kRanks.first;
  for (final cand in kRanks) {
    if (xp >= cand.minXp) r = cand;
  }
  return r;
}

Rank? nextRank(int xp) {
  for (final cand in kRanks) {
    if (xp < cand.minXp) return cand;
  }
  return null;
}
