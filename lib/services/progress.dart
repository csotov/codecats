import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cloud.dart';

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
    this.failDay = 0,
    this.reviewStage = 0,
    this.reviewDue = 0,
    this.starMask = 0,
  });

  bool solved;
  int stars;
  int attempts;
  bool hintUsed;

  /// Hints already paid for with Miaudólares (stay unlocked forever).
  int hintsBought;
  String code;
  List<dynamic>? blocksJson;

  /// Error notebook: epoch day of the last fail, and the spaced-review
  /// ladder (0 = failed and not yet beaten, 1 = beaten, review in 3 days,
  /// 2 = reviewed, again in 10 days, 3 = done) with its due epoch day.
  int failDay;
  int reviewStage;
  int reviewDue;

  /// Which of the three visible stars were ever earned (win / no hint /
  /// level challenge), OR-ed across visits.
  int starMask;

  Map<String, dynamic> toJson() => {
        's': solved,
        'st': stars,
        'a': attempts,
        'h': hintUsed,
        if (hintsBought > 0) 'hb': hintsBought,
        'c': code,
        if (blocksJson != null) 'b': blocksJson,
        if (failDay > 0) 'fd': failDay,
        if (reviewStage > 0) 'rs': reviewStage,
        if (reviewDue > 0) 'rv': reviewDue,
        if (starMask > 0) 'sm': starMask,
      };

  factory LevelProgress.fromJson(Map<String, dynamic> j) => LevelProgress(
        solved: j['s'] == true,
        stars: (j['st'] as num?)?.toInt() ?? 0,
        attempts: (j['a'] as num?)?.toInt() ?? 0,
        hintUsed: j['h'] == true,
        failDay: (j['fd'] as num?)?.toInt() ?? 0,
        reviewStage: (j['rs'] as num?)?.toInt() ?? 0,
        reviewDue: (j['rv'] as num?)?.toInt() ?? 0,
        // Levels won before visible star rules: map old stars onto flags.
        starMask: (j['sm'] as num?)?.toInt() ??
            (j['s'] == true
                ? 1 |
                    (((j['st'] as num?)?.toInt() ?? 0) >= 2 ? 2 : 0) |
                    (((j['st'] as num?)?.toInt() ?? 0) >= 3 ? 4 : 0)
                : 0),
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

  /// Rotation counters so the professor never repeats his last phrasing.
  final Map<String, int> rot = {};

  /// Big O check-question results per class: [right, wrong].
  final Map<String, List<int>> quiz = {};

  /// Per-day activity, yyyy-mm-dd -> [solves, fails, seconds, reviews].
  final Map<String, List<int>> days = {};

  /// Golden cat cards (cat ids) won in Bonus levels; every [kTrophyPieces]
  /// cards complete a golden trophy.
  final Set<String> goldenCards = {};
  static const kTrophyPieces = 5;

  /// Epoch day of the last Bonus level won: at most one Bonus per day so
  /// spaced reviews feel like a treat, not homework.
  int bonusDay = 0;

  /// The player's Codeforces handle, to verify linked coach problems.
  String cfHandle = '';

  void setCfHandle(String h) {
    cfHandle = h.trim();
    _save();
    notifyListeners();
  }

  /// Mock contest in progress: problem ids and end time (epoch ms), so an
  /// accidental exit never loses the run.
  List<String> contestIds = const [];
  int contestEndMs = 0;
  bool get contestActive =>
      contestIds.isNotEmpty &&
      contestEndMs > DateTime.now().millisecondsSinceEpoch;

  void startContest(List<String> ids, Duration length) {
    contestIds = List.unmodifiable(ids);
    contestEndMs = DateTime.now().add(length).millisecondsSinceEpoch;
    _save();
    notifyListeners();
  }

  void endContest() {
    contestIds = const [];
    contestEndMs = 0;
    _save();
    notifyListeners();
  }

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
        rot
          ..clear()
          ..addAll(((j['rot'] as Map?) ?? const {})
              .map((k, v) => MapEntry('$k', (v as num).toInt())));
        quiz
          ..clear()
          ..addAll(_intLists(j['qz']));
        days
          ..clear()
          ..addAll(_intLists(j['dy']));
        goldenCards
          ..clear()
          ..addAll((j['gc'] as List? ?? const []).map((e) => '$e'));
        bonusDay = (j['bd'] as num?)?.toInt() ?? 0;
        cfHandle = j['cfh'] as String? ?? '';
        contestIds =
            List.unmodifiable((j['ct'] as List? ?? const []).map((e) => '$e'));
        contestEndMs = (j['cte'] as num?)?.toInt() ?? 0;
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

  Map<String, dynamic> toSnapshot() => {
        'xp': xp,
        'mc': coins,
        'st': streak,
        'dsk': dayStreak,
        'rd': lastSolveDay,
        'gh': ghostStartDay,
        'cats': unlockedCats.toList(),
        'bo': taughtBigO.toList(),
        'rot': rot,
        'qz': quiz,
        'dy': days,
        'gc': goldenCards.toList(),
        'bd': bonusDay,
        'cfh': cfHandle,
        'ct': contestIds,
        'cte': contestEndMs,
        'lv': levels.map((k, v) => MapEntry(k, v.toJson())),
      };

  Timer? _cloudTimer;

  /// Cloud copy, at most once every few seconds (saves are frequent).
  void _scheduleCloudPush() {
    if (!Cloud.instance.signedIn) return;
    _cloudTimer?.cancel();
    _cloudTimer = Timer(const Duration(seconds: 4),
        () => Cloud.instance.pushSnapshot(toSnapshot()));
  }

  /// Merge the cloud snapshot into the active profile (keeps the best of
  /// both: solved stays solved, higher stars/xp/coins win) and save.
  Future<void> adoptCloudSnapshot() async {
    final d = await Cloud.instance.pullSnapshot();
    if (d == null) {
      await Cloud.instance.pushSnapshot(toSnapshot());
      return;
    }
    xp = math.max(xp, (d['xp'] as num?)?.toInt() ?? 0);
    coins = math.max(coins, (d['mc'] as num?)?.toInt() ?? 0);
    dayStreak = math.max(dayStreak, (d['dsk'] as num?)?.toInt() ?? 0);
    if ((d['rd'] as String? ?? '').compareTo(lastSolveDay) > 0) {
      lastSolveDay = d['rd'] as String;
    }
    unlockedCats.addAll(List<String>.from(d['cats'] ?? const []));
    taughtBigO.addAll(List<String>.from(d['bo'] ?? const []));
    ((d['rot'] as Map?) ?? const {}).forEach((k, v) {
      rot['$k'] = math.max(rot['$k'] ?? 0, (v as num).toInt());
    });
    _mergeMax(quiz, d['qz']);
    _mergeMax(days, d['dy']);
    goldenCards.addAll(List<String>.from(d['gc'] ?? const []));
    bonusDay = math.max(bonusDay, (d['bd'] as num?)?.toInt() ?? 0);
    if (cfHandle.isEmpty) cfHandle = d['cfh'] as String? ?? '';
    final lv = d['lv'];
    if (lv is Map) {
      lv.forEach((k, v) {
        final r = LevelProgress.fromJson(Map<String, dynamic>.from(v as Map));
        final p = of(k as String);
        p.solved = p.solved || r.solved;
        p.stars = math.max(p.stars, r.stars);
        p.attempts = math.max(p.attempts, r.attempts);
        p.hintsBought = math.max(p.hintsBought, r.hintsBought);
        p.hintUsed = p.hintUsed || r.hintUsed;
        p.failDay = math.max(p.failDay, r.failDay);
        p.reviewStage = math.max(p.reviewStage, r.reviewStage);
        p.reviewDue = math.max(p.reviewDue, r.reviewDue);
        p.starMask |= r.starMask;
      });
    }
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    if (active == null) return;
    _scheduleCloudPush();
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
          'rot': rot,
          'qz': quiz,
          'dy': days,
          'gc': goldenCards.toList(),
          'bd': bonusDay,
          'cfh': cfHandle,
          'ct': contestIds,
          'cte': contestEndMs,
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

  static const kChallengeBonus = 30;
  int lastChallengeBonus = 0;

  /// Levels whose challenge (third) star was earned, campaign only.
  int get challengeStars => levels.entries
      .where((e) =>
          !e.key.startsWith('hw') &&
          !e.key.startsWith('cp') &&
          !e.key.startsWith('cc') &&
          !e.key.startsWith('tr') &&
          e.value.starMask & 4 != 0)
      .length;

  /// Returns earned XP for this solve (first solve gives full XP).
  /// Also pays Miaudólares (see [coinsForSolve]) into [lastCoinsEarned].
  int recordSolve(String levelId, int levelXp, int stars,
      {bool codeMode = false, bool boss = false, int mask = 0}) {
    final p = of(levelId);
    var earned = 0;
    lastChallengeBonus = 0;
    if (mask & 4 != 0 && p.starMask & 4 == 0) {
      // Every 10 challenge stars pay a bonus purse.
      if ((challengeStars + 1) % 10 == 0) {
        lastChallengeBonus = kChallengeBonus;
        coins += kChallengeBonus;
      }
    }
    p.starMask |= mask;
    lastCoinsEarned =
        coinsForSolve(firstSolve: !p.solved, stars: stars, boss: boss);
    coins += lastCoinsEarned;
    if (!p.solved) {
      earned = levelXp;
      xp += levelXp;
      p.solved = true;
    }
    if (stars > p.stars) p.stars = stars;
    _bumpDay(0);
    if (p.failDay > 0 && p.reviewStage < 3) {
      final today = _epochDay(DateTime.now());
      if (p.reviewStage == 0 || today >= p.reviewDue) {
        if (p.reviewStage >= 1) _bumpDay(3);
        p.reviewStage++;
        p.reviewDue = today + (p.reviewStage == 1 ? 3 : 10);
      }
    }
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
    int rank(CatMeme c) => c.trigger == CatTrigger.halloweenN
        ? 0
        : _momentTriggers.contains(c.trigger)
            ? 1
            : 2;
    final eligible = [
      for (final c in kCats)
        if (!unlockedCats.contains(c.id) &&
            c.trigger != CatTrigger.always &&
            _catMet(c.trigger, c.need))
          c
    ];
    // Event and "this win" cats first: they can't wait for a later draw
    // (the event ends; the win context is cleared below).
    final order = {for (var i = 0; i < kCats.length; i++) kCats[i].id: i};
    eligible.sort((a, b) {
      final r = rank(a) - rank(b);
      return r != 0 ? r : order[a.id]! - order[b.id]!;
    });
    if (eligible.isNotEmpty) fresh.add(eligible.first);
    if (fresh.isNotEmpty) {
      final give = rank(fresh.first) < 2 ||
          unlockedCats.isEmpty ||
          _dryChecks >= 2 ||
          _rng.nextDouble() < 0.5;
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

  static const _momentTriggers = {
    CatTrigger.perfect,
    CatTrigger.codeMode,
    CatTrigger.worldBoss,
    CatTrigger.syntaxFix,
  };

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
      case CatTrigger.halloweenN:
        return levels.entries
                .where((e) => e.key.startsWith('hw') && e.value.solved)
                .length >=
            need;
    }
  }

  void recordAttempt(String levelId) {
    of(levelId).attempts++;
    _save();
    notifyListeners();
  }

  /// A lost battle: the level enters the error notebook.
  void recordFail(String levelId) {
    final p = of(levelId);
    final today = _epochDay(DateTime.now());
    p.failDay = today;
    if (p.reviewStage == 0) p.reviewDue = today;
    _bumpDay(1);
    _save();
    notifyListeners();
  }

  /// Time spent inside a level (seconds), for the weekly summary.
  void addLevelSeconds(int seconds) {
    if (seconds <= 0) return;
    _bumpDay(2, seconds);
    _save();
  }

  /// Next phrasing index for [key] among [n] variants, cycling so the
  /// same one never comes twice in a row.
  int nextRot(String key, int n) {
    if (n <= 0) return 0;
    final i = (rot[key] ?? -1) + 1;
    rot[key] = i;
    _save();
    return i % n;
  }

  void recordQuiz(String id, bool right) {
    final q = quiz.putIfAbsent(id, () => [0, 0]);
    q[right ? 0 : 1]++;
    _save();
    notifyListeners();
  }

  /// Error notebook entries ready today: failed and not yet beaten, or
  /// beaten and whose spaced review is due.
  List<String> get dueReviews {
    final today = _epochDay(DateTime.now());
    return [
      for (final e in levels.entries)
        if (e.value.failDay > 0 &&
            e.value.reviewStage < 3 &&
            (e.value.reviewStage == 0 || today >= e.value.reviewDue))
          e.key,
    ];
  }

  /// Beaten after a fail, review scheduled for a later day.
  List<String> get upcomingReviews {
    final today = _epochDay(DateTime.now());
    return [
      for (final e in levels.entries)
        if (e.value.failDay > 0 &&
            e.value.reviewStage >= 1 &&
            e.value.reviewStage < 3 &&
            today < e.value.reviewDue)
          e.key,
    ];
  }

  /// Today's Bonus level: the longest-waiting spaced review of a level
  /// already beaten once (fresh fails stay in the plain notebook list).
  /// Null when there is none or today's Bonus was already won.
  String? get bonusLevelId {
    final today = _epochDay(DateTime.now());
    if (bonusDay >= today) return null;
    String? best;
    var bestDue = 1 << 30;
    for (final e in levels.entries) {
      final p = e.value;
      if (p.failDay > 0 &&
          p.reviewStage >= 1 &&
          p.reviewStage < 3 &&
          today >= p.reviewDue &&
          p.reviewDue < bestDue) {
        best = e.key;
        bestDue = p.reviewDue;
      }
    }
    return best;
  }

  /// Fresh fails: in the notebook, not yet beaten.
  List<String> get unsolvedFails => [
        for (final e in levels.entries)
          if (e.value.failDay > 0 && e.value.reviewStage == 0) e.key,
      ];

  /// Winning a Bonus pays a golden card of a cat not yet gilded.
  /// Returns the cat id (null if every cat is already golden).
  String? awardGoldenCard(List<String> catIds) {
    bonusDay = _epochDay(DateTime.now());
    final left = catIds.where((c) => !goldenCards.contains(c)).toList();
    String? pick;
    if (left.isNotEmpty) {
      pick = left[math.Random().nextInt(left.length)];
      goldenCards.add(pick);
    }
    _save();
    notifyListeners();
    return pick;
  }

  int get trophies => goldenCards.length ~/ kTrophyPieces;
  int get trophyPieces => goldenCards.length % kTrophyPieces;

  int daysUntilReview(String levelId) =>
      of(levelId).reviewDue - _epochDay(DateTime.now());

  /// [solves, fails, seconds, reviews] for a calendar day.
  List<int> dayStats(DateTime d) => days[_dayKey(d)] ?? const [0, 0, 0, 0];

  void _bumpDay(int idx, [int by = 1]) {
    final key = _dayKey(DateTime.now());
    final row = days.putIfAbsent(key, () => [0, 0, 0, 0]);
    while (row.length < 4) {
      row.add(0);
    }
    row[idx] += by;
    if (days.length > 21) {
      final keys = days.keys.toList()..sort();
      for (final k in keys.take(days.length - 21)) {
        days.remove(k);
      }
    }
  }

  static Map<String, List<int>> _intLists(Object? m) => m is Map
      ? m.map((k, v) => MapEntry(
          '$k', List<int>.from((v as List).map((e) => (e as num).toInt()))))
      : {};

  static void _mergeMax(Map<String, List<int>> into, Object? from) {
    _intLists(from).forEach((k, v) {
      final cur = into[k];
      if (cur == null) {
        into[k] = v;
        return;
      }
      for (var i = 0; i < v.length; i++) {
        if (i >= cur.length) {
          cur.add(v[i]);
        } else {
          cur[i] = math.max(cur[i], v[i]);
        }
      }
    });
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

  /// Campaign-only totals; Halloween event levels (hw*) count separately.
  Iterable<LevelProgress> get _campaign => levels.entries
      .where((e) =>
          !e.key.startsWith('hw') &&
          !e.key.startsWith('cp') &&
          !e.key.startsWith('cc'))
      .map((e) => e.value);

  int get totalStars => _campaign.fold(0, (s, p) => s + p.stars);

  int get solvedCount => _campaign.where((p) => p.solved).length;

  /// Reset only the ACTIVE profile's progress (start from zero).
  Future<void> reset() async {
    xp = 0;
    coins = kStartCoins;
    streak = 0;
    unlockedCats.clear();
    taughtBigO.clear();
    levels.clear();
    rot.clear();
    quiz.clear();
    days.clear();
    goldenCards.clear();
    bonusDay = 0;
    contestIds = const [];
    contestEndMs = 0;
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
