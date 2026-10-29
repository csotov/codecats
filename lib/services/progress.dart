import '../data/belts.dart';
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
  Profile(
      {required this.id,
      required this.name,
      required this.emoji,
      this.acct = ''});

  final String id;
  String name;
  String emoji;

  /// Cloud account (user id) this slot syncs with; only that slot pushes.
  String acct;

  Map<String, dynamic> toJson() =>
      {'id': id, 'n': name, 'e': emoji, if (acct.isNotEmpty) 'a': acct};

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        id: j['id'] as String,
        name: j['n'] as String? ?? 'Jugador',
        emoji: j['e'] as String? ?? '🐯',
        acct: j['a'] as String? ?? '',
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

  /// How each cat was won: `levelId|stars|yyyy-mm-dd` (levelId empty when
  /// it was not tied to a battle). Cats won before this existed have none.
  final Map<String, String> catOrigin = {};

  void _noteCatOrigin(String id) {
    if (catOrigin.containsKey(id)) return;
    final s = _lastSolve;
    final d = DateTime.now().toIso8601String().substring(0, 10);
    catOrigin[id] = '${s?.levelId ?? ''}|${s?.stars ?? 0}|$d';
  }

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

  /// Badges owned (bought in the shop or earned by goals) and the one
  /// shown next to the player's name ('' = none).
  final Set<String> badges = {};
  String equippedBadge = '';

  /// Pay [price] for badge [id]. False (nothing charged) if too poor.
  bool buyBadge(String id, int price) {
    if (badges.contains(id) || coins < price) return false;
    coins -= price;
    badges.add(id);
    _save();
    notifyListeners();
    return true;
  }

  /// Grant goal badges; returns the ones that are new.
  List<String> awardBadges(Iterable<String> ids) {
    final fresh = ids.where(badges.add).toList();
    if (fresh.isNotEmpty) {
      _save();
      notifyListeners();
    }
    return fresh;
  }

  /// Only shop badges ('s_' ids) can be worn for now.
  void equipBadge(String id) {
    if (!id.startsWith('s_')) return;
    equippedBadge = equippedBadge == id ? '' : id;
    _save();
    notifyListeners();
  }

  /// Epoch day of the last Bonus level won: at most one Bonus per day so
  /// spaced reviews feel like a treat, not homework.
  int bonusDay = 0;

  /// Side tracks (lab, lead-ins, world closings, Coder round) do not
  /// count toward campaign totals.
  static bool _offCampaign(String id) =>
      id.startsWith('lb') ||
      id.startsWith('fx') ||
      id.startsWith('cr') ||
      id.startsWith('at');

  /// Best partial score (0-100) per subtask level.
  final Map<String, int> scores = {};

  void recordScore(String levelId, int score) {
    if (examActive &&
        examIds.contains(levelId) &&
        score > (examScores[levelId] ?? -1)) {
      examScores[levelId] = score;
      _save();
    }
    if (score <= (scores[levelId] ?? -1)) return;
    scores[levelId] = score;
    _save();
    notifyListeners();
  }

  /// Spends [price] Miaudólares; false (nothing charged) if too few.
  bool spendCoins(int price) {
    if (coins < price) return false;
    coins -= price;
    _save();
    notifyListeners();
    return true;
  }

  void earnCoins(int n) {
    coins += n;
    _save();
    notifyListeners();
  }

  /// Minutes played since the last lightning round, and right answers so
  /// far (more right answers -> 2 questions per round instead of 1).
  int blitzMin = 0;
  int blitzOk = 0;
  static const kBlitzEvery = 30;
  static const kBlitzCoins = 5;

  void tickBlitz() {
    blitzMin++;
    if (blitzMin % 5 == 0 || blitzMin == kBlitzEvery) _save();
    if (blitzMin == kBlitzEvery) notifyListeners();
  }

  /// Phases opened by the skip exam, and the exam in progress.
  final Set<int> openPhases = {};

  /// Current belt (index in kBelts); -1 = not placed yet (older saves are
  /// placed by what they already solved, never lower).
  int _belt = -1;
  int beltFailDay = 0;
  int beltStripesSeen = 0;
  int get belt {
    if (_belt < 0) _placeBelt();
    return _belt;
  }

  void _placeBelt() {
    var b = 0;
    // Never placed past the blue belt: Bronce USACO needs the exam.
    while (b < 4 && beltStripes(kBelts[b], this) == 4) {
      b++;
    }
    _belt = b;
    beltStripesSeen = beltStripes(kBelts[b], this);
  }

  bool get beltExamOpen =>
      belt < kBelts.length - 1 &&
      beltStripes(kBelts[belt], this) == 4 &&
      beltFailDay != _epochDay(DateTime.now());

  /// New stripes since the last celebration; pays 10 per stripe.
  int takeNewStripes() {
    final s = beltStripes(kBelts[belt], this);
    final n = s - beltStripesSeen;
    if (n <= 0) return 0;
    beltStripesSeen = s;
    coins += 10 * n;
    _save();
    notifyListeners();
    return n;
  }

  int examPhase = 0;
  List<String> examIds = const [];
  int examEndMs = 0;
  final Set<String> examSolved = {};

  /// Best score (0-100) per problem in the running exam.
  final Map<String, int> examScores = {};

  bool get examActive =>
      examPhase > 0 && DateTime.now().millisecondsSinceEpoch < examEndMs;

  void startExam(int phase, List<String> ids, Duration length) {
    examPhase = phase;
    examIds = List.unmodifiable(ids);
    examEndMs = DateTime.now().add(length).millisecondsSinceEpoch;
    examSolved.clear();
    examScores.clear();
    _save();
    notifyListeners();
  }

  void markExamSolved(String id) {
    if (!examActive || !examIds.contains(id)) return;
    examSolved.add(id);
    _save();
    notifyListeners();
  }

  /// Ends the exam; opens the phase when [passed].
  void endExam({required bool passed}) {
    if (examPhase >= kBeltExamBase) {
      if (passed && examPhase - kBeltExamBase == belt) {
        _belt = belt + 1;
        beltStripesSeen = beltStripes(kBelts[_belt], this);
        coins += 60;
      } else if (!passed) {
        beltFailDay = _epochDay(DateTime.now());
      }
    } else if (passed && examPhase > 0) {
      openPhases.add(examPhase);
    }
    examPhase = 0;
    examIds = const [];
    examEndMs = 0;
    examScores.clear();
    examSolved.clear();
    _save();
    notifyListeners();
  }

  /// Leitner boxes for lightning concept cards: id -> [box, dueRound].
  final Map<String, List<int>> blitzCards = {};

  /// Math gym: topic id -> [questions solved in order, total right].
  final Map<String, List<int>> mathGym = {};

  /// Bonus for finishing a full pass of a math-gym topic: big the first
  /// time, small on review laps. Returns the coins given.
  int mathLapDone(String topic, int lap) {
    final bonus = lap <= 1 ? 20 : 5;
    coins += bonus;
    _save();
    notifyListeners();
    return bonus;
  }

  void mathAnswered(String topic, bool right) {
    final m = mathGym[topic] ?? [0, 0];
    if (right) {
      m[0]++;
      m[1]++;
      coins += 2;
    }
    mathGym[topic] = m;
    _save();
    notifyListeners();
  }

  /// Write-from-memory drills reuse [mathGym] under `rec_<id>`:
  /// [times written right, best seconds].
  List<int> recallStats(String id) => mathGym['rec_$id'] ?? const [0, 0];

  /// Records a correct write-up; returns the coins earned (5 the first
  /// time, 2 for beating the best time).
  int recallDone(String id, int seconds) {
    final m = [...recallStats(id)];
    var earned = 0;
    if (m[0] == 0) {
      earned = 5;
    } else if (seconds < m[1]) {
      earned = 2;
    }
    m[0]++;
    if (m[1] == 0 || seconds < m[1]) m[1] = seconds;
    mathGym['rec_$id'] = m;
    coins += earned;
    _save();
    notifyListeners();
    return earned;
  }

  /// One-off Profe talks (e.g. the Departamental pep talk) stored under
  /// `talk_<id>` so they sync with the rest of the progress.
  bool talkSeen(String id) => mathGym.containsKey('talk_$id');

  void addCoins(int n) {
    coins += n;
    _save();
    notifyListeners();
  }

  void markTalkSeen(String id) {
    mathGym['talk_$id'] = [1, 0];
    _save();
  }

  /// Memory gym lessons reuse [mathGym] under `mem_<deck>`:
  /// [lessons finished, best first-try score].
  List<int> memStats(String deck) => mathGym['mem_$deck'] ?? const [0, 0];

  /// 1 Miaudólar per first-try answer, +5 for a perfect lesson.
  int memLesson(String deck, int firstTry, int total) {
    final m = [...memStats(deck)];
    m[0]++;
    m[1] = math.max(m[1], firstTry);
    mathGym['mem_$deck'] = m;
    final earned = firstTry + (firstTry == total ? 5 : 0);
    coins += earned;
    _save();
    notifyListeners();
    return earned;
  }

  /// Questions asked so far; even ones are contest facts, odd ones
  /// concept cards from won levels.
  int blitzSeq = 0;

  /// Next Leitner card (Anki-like): reviews that are due come first,
  /// then one new card in list order, else the one due soonest. [skip]
  /// avoids asking the same card twice in a row.
  String? nextBlitzCard(List<String> ids, {String? skip}) {
    final pool = ids.length > 1 ? [...ids.where((i) => i != skip)] : ids;
    if (pool.isEmpty) return null;
    final seen = [...pool.where(blitzCards.containsKey)]
      ..sort((a, b) => blitzCards[a]![1].compareTo(blitzCards[b]![1]));
    if (seen.isNotEmpty && blitzCards[seen.first]![1] <= blitzSeq) {
      return seen.first;
    }
    for (final id in pool) {
      if (!blitzCards.containsKey(id)) return id;
    }
    return seen.first;
  }

  /// Right answers wait longer (1, 2, 4, 8, 16 rounds); wrong ones come
  /// back on the next round.
  void answerBlitzCard(String id, bool right) {
    final c = blitzCards[id] ?? [0, 0];
    final box = right ? math.min(c[0] + 1, 5) : 0;
    blitzCards[id] = [box, blitzSeq + (right ? 1 << box : 1)];
  }

  void finishBlitz(int right) {
    blitzMin = 0;
    blitzOk += right;
    coins += right * kBlitzCoins;
    _save();
    notifyListeners();
  }

  /// The player's Codeforces handle, to verify linked coach problems.
  /// Suggested handle (the owner's son uses it on every judge).
  static const kDefaultHandle = 'augohan';

  String cfHandle = '';

  /// The player's AtCoder user, to verify linked AtCoder problems.
  String atcoderUser = '';

  void setAtcoderUser(String u) {
    atcoderUser = u.trim();
    _save();
    notifyListeners();
  }

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
    catOrigin.clear();
    badges.clear();
    equippedBadge = '';
    hatMade = List.filled(kHatTrade.length, 0);
    earlyDeadline = 0;
    earlyOfferDay = 0;
    earlyHats = 0;
    earlyTodayDay = 0;
    earlyWon = false;
    earlyFrom = 0;
    earlyAdminDl = 0;
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
        badges
          ..clear()
          ..addAll((j['bdg'] as List? ?? const []).map((e) => '$e'));
        equippedBadge = j['bde'] as String? ?? '';
        hatMade = _hatList(j['hmt']);
        earlyDeadline = (j['eo'] as num?)?.toInt() ?? 0;
        earlyOfferDay = (j['eod'] as num?)?.toInt() ?? 0;
        earlyHats = (j['eh'] as num?)?.toInt() ?? 0;
        earlyTodayDay = (j['etd'] as num?)?.toInt() ?? 0;
        earlyWon = j['ew'] == true;
        earlyFrom = (j['ef'] as num?)?.toInt() ?? 0;
        earlyAdminDl = (j['ead'] as num?)?.toInt() ?? 0;
        cfHandle = j['cfh'] as String? ?? '';
        atcoderUser = j['acu'] as String? ?? '';
        scores
          ..clear()
          ..addAll(((j['sc'] as Map?) ?? const {})
              .map((k, v) => MapEntry('$k', (v as num).toInt())));
        blitzMin = (j['bzm'] as num?)?.toInt() ?? 0;
        blitzOk = (j['bzo'] as num?)?.toInt() ?? 0;
        blitzSeq = (j['bzs'] as num?)?.toInt() ?? 0;
        openPhases
          ..clear()
          ..addAll(
              (j['php'] as List? ?? const []).map((e) => (e as num).toInt()));
        examPhase = (j['exp'] as num?)?.toInt() ?? 0;
        _belt = (j['blt'] as num?)?.toInt() ?? -1;
        beltFailDay = (j['bfd'] as num?)?.toInt() ?? 0;
        beltStripesSeen = (j['bss'] as num?)?.toInt() ?? 0;
        examIds =
            List.unmodifiable((j['exi'] as List? ?? const []).map((e) => '$e'));
        examEndMs = (j['exe'] as num?)?.toInt() ?? 0;
        examSolved
          ..clear()
          ..addAll((j['exs'] as List? ?? const []).map((e) => '$e'));
        examScores
          ..clear()
          ..addAll((j['exsc'] as Map? ?? const {})
              .map((k, v) => MapEntry('$k', (v as num).toInt())));
        blitzCards
          ..clear()
          ..addAll(_intLists(j['bq']));
        mathGym
          ..clear()
          ..addAll(_intLists(j['mg']));
        contestIds =
            List.unmodifiable((j['ct'] as List? ?? const []).map((e) => '$e'));
        contestEndMs = (j['cte'] as num?)?.toInt() ?? 0;
        unlockedCats
          ..clear()
          ..addAll((j['cats'] as List? ?? const []).map((e) => '$e'));
        catOrigin
          ..clear()
          ..addAll(((j['co'] as Map?) ?? const {})
              .map((k, v) => MapEntry('$k', '$v')));
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
        'co': catOrigin,
        'bo': taughtBigO.toList(),
        'rot': rot,
        'qz': quiz,
        'dy': days,
        'gc': goldenCards.toList(),
        'bd': bonusDay,
        'bdg': badges.toList(),
        'hmt': hatMade,
        'eo': earlyDeadline,
        'eod': earlyOfferDay,
        'eh': earlyHats,
        'etd': earlyTodayDay,
        'ew': earlyWon,
        'ef': earlyFrom,
        'ead': earlyAdminDl,
        'bde': equippedBadge,
        'cfh': cfHandle,
        'acu': atcoderUser,
        'sc': scores,
        'bzm': blitzMin,
        'bzo': blitzOk,
        'bzs': blitzSeq,
        'php': openPhases.toList(),
        'exp': examPhase,
        'blt': _belt,
        'bfd': beltFailDay,
        'bss': beltStripesSeen,
        'exi': examIds,
        'exe': examEndMs,
        'exs': examSolved.toList(),
        'exsc': examScores,
        'bq': blitzCards,
        'mg': mathGym,
        'ct': contestIds,
        'cte': contestEndMs,
        'lv': levels.map((k, v) => MapEntry(k, v.toJson())),
        'pn': active?.name ?? '',
        'pe': active?.emoji ?? '',
      };

  Timer? _cloudTimer;

  bool get _activeLinked {
    final uid = Cloud.instance.user?.id;
    return uid != null && active?.acct == uid;
  }

  /// Cloud copy, at most once every few seconds (saves are frequent).
  void _scheduleCloudPush() {
    if (!_activeLinked) return;
    _cloudTimer?.cancel();
    _cloudTimer = Timer(const Duration(seconds: 4), _syncCloud);
  }

  /// Pull, merge and push, so two devices never overwrite each other.
  Future<void> _syncCloud() async {
    if (!_activeLinked) return;
    final d = await Cloud.instance.pullSnapshot();
    if (d != null) {
      _mergeFrom(d);
      await _saveLocal();
      notifyListeners();
    }
    await Cloud.instance.pushSnapshot(toSnapshot());
  }

  /// Picks the local slot that belongs to the signed-in account (by link,
  /// then by the cloud profile name), creating it on a new device, and
  /// merges the cloud progress into it.
  Future<void> linkAccount() async {
    final uid = Cloud.instance.user?.id;
    if (uid == null) return;
    await ensureLoaded();
    final d = await Cloud.instance.pullSnapshot();
    var p = profiles.where((e) => e.acct == uid).firstOrNull;
    if (p == null) {
      var name = (d?['pn'] as String? ?? '').trim();
      if (name.isEmpty) name = Cloud.instance.displayName.trim();
      final key = name.toLowerCase();
      p = name.isEmpty
          ? null
          : profiles
              .where((e) => e.acct.isEmpty && e.name.toLowerCase() == key)
              .firstOrNull;
      if (p == null && name.isNotEmpty && d != null) {
        p = await createProfile(name, d['pe'] as String? ?? '🐯');
      }
      p ??= active!;
      p.acct = uid;
      await _saveProfiles();
    }
    if (active?.id != p.id) await _loadProfile(p.id, save: false);
    if (d != null) _mergeFrom(d);
    await _save();
    notifyListeners();
  }

  /// Merge the cloud snapshot into the active profile (keeps the best of
  /// both: solved stays solved, higher stars/xp/coins win) and save.
  Future<void> adoptCloudSnapshot() async {
    final d = await Cloud.instance.pullSnapshot();
    if (d == null) {
      await Cloud.instance.pushSnapshot(toSnapshot());
      return;
    }
    _mergeFrom(d);
    await _save();
    notifyListeners();
  }

  void _mergeFrom(Map<String, dynamic> d) {
    xp = math.max(xp, (d['xp'] as num?)?.toInt() ?? 0);
    coins = math.max(coins, (d['mc'] as num?)?.toInt() ?? 0);
    dayStreak = math.max(dayStreak, (d['dsk'] as num?)?.toInt() ?? 0);
    if ((d['rd'] as String? ?? '').compareTo(lastSolveDay) > 0) {
      lastSolveDay = d['rd'] as String;
    }
    unlockedCats.addAll(List<String>.from(d['cats'] ?? const []));
    ((d['co'] as Map?) ?? const {}).forEach((k, v) {
      catOrigin.putIfAbsent('$k', () => '$v');
    });
    taughtBigO.addAll(List<String>.from(d['bo'] ?? const []));
    ((d['rot'] as Map?) ?? const {}).forEach((k, v) {
      rot['$k'] = math.max(rot['$k'] ?? 0, (v as num).toInt());
    });
    _mergeMax(quiz, d['qz']);
    _mergeMax(days, d['dy']);
    goldenCards.addAll(List<String>.from(d['gc'] ?? const []));
    bonusDay = math.max(bonusDay, (d['bd'] as num?)?.toInt() ?? 0);
    badges.addAll(List<String>.from(d['bdg'] ?? const []));
    final hm = _hatList(d['hmt']);
    hatMade = [
      for (var i = 0; i < kHatTrade.length; i++) math.max(hatMade[i], hm[i])
    ];
    earlyHats = math.max(earlyHats, (d['eh'] as num?)?.toInt() ?? 0);
    earlyOfferDay = math.max(earlyOfferDay, (d['eod'] as num?)?.toInt() ?? 0);
    if (earlyDeadline == 0) earlyDeadline = (d['eo'] as num?)?.toInt() ?? 0;
    earlyTodayDay = math.max(earlyTodayDay, (d['etd'] as num?)?.toInt() ?? 0);
    earlyWon = earlyWon || d['ew'] == true;
    earlyFrom = math.max(earlyFrom, (d['ef'] as num?)?.toInt() ?? 0);
    earlyAdminDl = math.max(earlyAdminDl, (d['ead'] as num?)?.toInt() ?? 0);
    if (equippedBadge.isEmpty) equippedBadge = d['bde'] as String? ?? '';
    if (!equippedBadge.startsWith('s_')) equippedBadge = '';
    if (cfHandle.isEmpty) cfHandle = d['cfh'] as String? ?? '';
    if (atcoderUser.isEmpty) atcoderUser = d['acu'] as String? ?? '';
    ((d['sc'] as Map?) ?? const {}).forEach((k, v) {
      scores['$k'] = math.max(scores['$k'] ?? 0, (v as num).toInt());
    });
    blitzOk = math.max(blitzOk, (d['bzo'] as num?)?.toInt() ?? 0);
    blitzSeq = math.max(blitzSeq, (d['bzs'] as num?)?.toInt() ?? 0);
    openPhases
        .addAll((d['php'] as List? ?? const []).map((e) => (e as num).toInt()));
    final cloudBelt = (d['blt'] as num?)?.toInt() ?? -1;
    if (cloudBelt > _belt) {
      _belt = cloudBelt;
      beltStripesSeen =
          math.max(beltStripesSeen, (d['bss'] as num?)?.toInt() ?? 0);
    }
    _mergeMax(blitzCards, d['bq']);
    _mergeMax(mathGym, d['mg']);
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
  }

  Future<void> _save() async {
    if (active == null) return;
    _scheduleCloudPush();
    await _saveLocal();
  }

  Future<void> _saveLocal() async {
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
          'co': catOrigin,
          'bo': taughtBigO.toList(),
          'rot': rot,
          'qz': quiz,
          'dy': days,
          'gc': goldenCards.toList(),
          'bd': bonusDay,
          'bdg': badges.toList(),
          'hmt': hatMade,
          'eo': earlyDeadline,
          'eod': earlyOfferDay,
          'eh': earlyHats,
          'etd': earlyTodayDay,
          'ew': earlyWon,
          'ef': earlyFrom,
          'ead': earlyAdminDl,
          'bde': equippedBadge,
          'cfh': cfHandle,
          'acu': atcoderUser,
          'sc': scores,
          'bzm': blitzMin,
          'bzo': blitzOk,
          'bzs': blitzSeq,
          'php': openPhases.toList(),
          'exp': examPhase,
          'blt': _belt,
          'bfd': beltFailDay,
          'bss': beltStripesSeen,
          'exi': examIds,
          'exe': examEndMs,
          'exs': examSolved.toList(),
          'bq': blitzCards,
          'mg': mathGym,
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
          !_offCampaign(e.key) &&
          e.value.starMask & 4 != 0)
      .length;

  static bool _countsForChallenge(String id) =>
      !id.startsWith('hw') &&
      !id.startsWith('cp') &&
      !id.startsWith('cc') &&
      !id.startsWith('tr') &&
      !_offCampaign(id);

  /// Returns earned XP for this solve (first solve gives full XP).
  /// Also pays Miaudólares (see [coinsForSolve]) into [lastCoinsEarned].
  int recordSolve(String levelId, int levelXp, int stars,
      {bool codeMode = false, bool boss = false, int mask = 0}) {
    final p = of(levelId);
    var earned = 0;
    lastChallengeBonus = 0;
    // Only campaign levels count toward the challenge purse; side tracks
    // are excluded from [challengeStars], so they would re-trigger it.
    if (mask & 4 != 0 && p.starMask & 4 == 0 && _countsForChallenge(levelId)) {
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
    if (earlyIsToday && !(earlyFromAt?.isAfter(DateTime.now()) ?? false)) {
      earlyWon = true;
    }
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
    _lastSolve = _SolveCtx(
        levelId: levelId, stars: stars, codeMode: codeMode, boss: boss);
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

  /// Ghost rival: 2 levels a day since the first solve, but always
  /// close to the player (2 behind to 3 ahead) so the race stays alive.
  int get ghostSolved {
    if (ghostStartDay == 0) return 0;
    final raw = (_epochDay(DateTime.now()) - ghostStartDay) * 2 + 1;
    final you = solvedCount;
    return raw.clamp(math.max(0, you - 2), you + 3);
  }

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
    _noteCatOrigin(id);
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
  static const kHatCoins = 5;

  /// Hats of each tier needed to make one of the next (feo, ultra HD,
  /// plateado, de agua, el más feo): 10, 20, 40, 80 and 160 Gorritos Gatunos in total.
  static const kHatTrade = [10, 2, 2, 2, 2];

  /// Hats made by trading [kHatTrade] hats of the tier below: feo, ultra HD,
  /// plateado, de agua.
  List<int> hatMade = List.filled(kHatTrade.length, 0);

  static List<int> _hatList(Object? raw) {
    final l = [for (final e in (raw as List? ?? const [])) (e as num).toInt()];
    return [for (var i = 0; i < kHatTrade.length; i++) i < l.length ? l[i] : 0];
  }

  /// Hats of [tier] in hand (0 = Gorrito Gatuno … 4 = gorrito de agua).
  int hatsInHand(int tier) {
    final made = tier == 0 ? hats : hatMade[tier - 1];
    return made -
        (tier < kHatTrade.length ? kHatTrade[tier] * hatMade[tier] : 0);
  }

  /// Trade [kHatTrade] hats of [tier] for one of the next tier.
  bool tradeHats(int tier) {
    if (tier >= kHatTrade.length || hatsInHand(tier) < kHatTrade[tier]) {
      return false;
    }
    hatMade[tier]++;
    _save();
    notifyListeners();
    return true;
  }

  /// Gorritos Gatunos earned (one per level at most).
  int get hats =>
      levels.values.where((p) => p.starMask & 8 != 0).length + earlyHats;

  /// Early-bird prize: on some days the map promises a prize for coming
  /// back tomorrow before 15:00 (sometimes 15:30). [earlyDeadline] is that
  /// moment in ms (0 = no offer); [earlyOfferDay] the last day (yyyymmdd)
  /// the dice were rolled, so it is decided once a day.
  int earlyDeadline = 0, earlyOfferDay = 0, earlyHats = 0;

  /// Same-day offer sent by the admin: on [earlyTodayDay] the prize needs a
  /// level won ([earlyWon]) before the deadline, not just opening the game.
  int earlyTodayDay = 0;
  bool earlyWon = false;

  /// Optional start of today's window (ms, 0 = right away): wins before it
  /// don't count.
  int earlyFrom = 0;
  DateTime? get earlyFromAt =>
      earlyFrom == 0 ? null : DateTime.fromMillisecondsSinceEpoch(earlyFrom);
  bool get earlyIsToday {
    final dl = earlyDeadlineAt;
    return dl != null && earlyTodayDay == _ymd(dl);
  }

  /// Replaces any pending offer with one for today: win a level before
  /// 15:30 (or within 2 hours if it's later). Once a day. With [until] the
  /// admin fixes the deadline (to get him in early); a new one moves a
  /// pending offer.
  bool offerEarlyToday(DateTime now, {DateTime? until}) {
    final same = until == null
        ? earlyFrom == 0
        : earlyFrom == 0 && earlyDeadline == until.millisecondsSinceEpoch;
    if (earlyTodayDay == _ymd(now) &&
        (same || earlyDeadline == 0 || earlyWon)) {
      return false;
    }
    earlyTodayDay = _ymd(now);
    earlyOfferDay = _ymd(now);
    earlyWon = false;
    earlyFrom = 0;
    var dl = DateTime(now.year, now.month, now.day, 15, 30);
    final later = now.add(const Duration(hours: 2));
    if (until != null && until.isAfter(now)) {
      dl = until;
    } else if (later.isAfter(dl)) {
      dl = later;
    }
    final end = DateTime(now.year, now.month, now.day, 23, 59);
    if (dl.isAfter(end)) dl = end;
    earlyDeadline = dl.millisecondsSinceEpoch;
    _save();
    notifyListeners();
    return true;
  }

  /// Last deadline the admin scheduled ('early_on@HHMM'), so it's offered
  /// only once even after the prize is claimed.
  int earlyAdminDl = 0;

  /// Admin-scheduled offer: come in before [deadline] (no win needed).
  bool offerEarlyOn(DateTime now, DateTime deadline) {
    final ms = deadline.millisecondsSinceEpoch;
    if (earlyAdminDl == ms || !deadline.isAfter(now)) return false;
    earlyAdminDl = ms;
    earlyDeadline = ms;
    earlyTodayDay = 0;
    earlyWon = false;
    earlyFrom = 0;
    earlyOfferDay = _ymd(now);
    _save();
    notifyListeners();
    return true;
  }

  /// When the game was opened; the Profe's short challenges and offers wait
  /// [kWarmUp] so they never pop up right on entering.
  static DateTime appStart = DateTime.now();
  static const kWarmUp = Duration(seconds: 10);
  static bool get warm => DateTime.now().difference(appStart) >= kWarmUp;

  static const kEarlyChance = 0.4;
  static const kEarlyHats = 5;
  static const kEarlyCat = 'early_bird';

  static int _ymd(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

  DateTime? get earlyDeadlineAt => earlyDeadline == 0
      ? null
      : DateTime.fromMillisecondsSinceEpoch(earlyDeadline);

  /// Rolls today's dice once; true when a new offer was just made.
  bool offerEarly(DateTime now, [math.Random? rng]) {
    if (earlyDeadline != 0 || earlyOfferDay == _ymd(now)) return false;
    earlyOfferDay = _ymd(now);
    final r = rng ?? math.Random(_ymd(now));
    final lucky = r.nextDouble() < kEarlyChance;
    if (lucky) {
      earlyDeadline =
          DateTime(now.year, now.month, now.day + 1, 15, r.nextBool() ? 30 : 0)
              .millisecondsSinceEpoch;
    }
    _save();
    notifyListeners();
    return lucky;
  }

  /// On the deadline day before the deadline: grants the prize and
  /// returns 'cat' or 'hats'. Past it, the offer expires ('missed').
  String? claimEarly(DateTime now, [math.Random? rng]) {
    final dl = earlyDeadlineAt;
    if (dl == null) return null;
    if (now.isAfter(dl)) {
      earlyDeadline = 0;
      _save();
      notifyListeners();
      return 'missed';
    }
    if (now.isBefore(DateTime(dl.year, dl.month, dl.day))) return null;
    if (earlyIsToday && !earlyWon) return null;
    earlyDeadline = 0;
    earlyWon = false;
    final String prize;
    if (!unlockedCats.contains(kEarlyCat) && (rng ?? _rng).nextBool()) {
      unlockedCats.add(kEarlyCat);
      _noteCatOrigin(kEarlyCat);
      prize = 'cat';
    } else {
      earlyHats += kEarlyHats;
      coins += kHatCoins * kEarlyHats;
      prize = 'hats';
    }
    _save();
    notifyListeners();
    return prize;
  }

  /// Gives the Gorrito Gatuno of [levelId] once; false if already owned.
  bool awardHat(String levelId) {
    final p = of(levelId);
    if (p.starMask & 8 != 0) return false;
    p.starMask |= 8;
    coins += kHatCoins;
    _save();
    notifyListeners();
    return true;
  }

  /// Coin cats are granted as soon as the purse is big enough, from any
  /// screen, without the random draw.
  List<CatMeme> checkCoinCats() {
    final fresh = [
      for (final c in kCats)
        if (c.trigger == CatTrigger.coinsN &&
            !unlockedCats.contains(c.id) &&
            coins >= c.need)
          c
    ];
    if (fresh.isEmpty) return fresh;
    unlockedCats.addAll(fresh.map((c) => c.id));
    _save();
    notifyListeners();
    return fresh;
  }

  /// Cats with an announced goal ("Consigue 50 estrellas"): once the
  /// goal is met they are always given, never left to the draw.
  static const _milestoneTriggers = {
    CatTrigger.starsN,
    CatTrigger.solvedN,
    CatTrigger.solved10,
    CatTrigger.solved25,
    CatTrigger.solved50,
    CatTrigger.allStarsW1,
    CatTrigger.rankGold,
    CatTrigger.rankIoi,
  };

  List<CatMeme> checkCatUnlocks({bool milestonesOnly = false}) {
    final promised = [
      for (final c in kCats)
        if (!unlockedCats.contains(c.id) &&
            _milestoneTriggers.contains(c.trigger) &&
            _catMet(c.trigger, c.need))
          c
    ];
    if (promised.isNotEmpty || milestonesOnly) {
      unlockedCats.addAll(promised.map((c) => c.id));
      for (final c in promised) {
        _noteCatOrigin(c.id);
      }
      if (promised.isNotEmpty) {
        _save();
        notifyListeners();
      }
      _lastSolve = null;
      return promised;
    }
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
          fresh.first.trigger == CatTrigger.coinsN ||
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
    for (final c in fresh) {
      _noteCatOrigin(c.id);
    }
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
        return xp >= kRanks[2].minXp;
      case CatTrigger.rankIoi:
        return xp >= kRanks.last.minXp;
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
      case CatTrigger.earlyBird:
        return false;
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
  /// each level opens when the previous one is solved. Levels already
  /// solved stay open even if new levels were inserted before them.
  bool isUnlocked(Level level, World world) {
    if (levels[level.id]?.solved ?? false) return true;
    final idx = world.levels.indexWhere((l) => l.id == level.id);
    if (idx <= 0) return true;
    return levels[world.levels[idx - 1].id]?.solved ?? false;
  }

  /// Campaign-only totals; Halloween event levels (hw*) count separately.
  Iterable<LevelProgress> get _campaign => levels.entries
      .where((e) =>
          !e.key.startsWith('hw') &&
          !e.key.startsWith('cp') &&
          !e.key.startsWith('cc') &&
          !e.key.startsWith('tr') &&
          !_offCampaign(e.key))
      .map((e) => e.value);

  int get totalStars => _campaign.fold(0, (s, p) => s + p.stars);

  int get solvedCount => _campaign.where((p) => p.solved).length;

  /// Reset only the ACTIVE profile's progress (start from zero).
  Future<void> reset() async {
    _belt = -1;
    beltFailDay = 0;
    beltStripesSeen = 0;
    xp = 0;
    coins = kStartCoins;
    streak = 0;
    unlockedCats.clear();
    catOrigin.clear();
    taughtBigO.clear();
    levels.clear();
    rot.clear();
    quiz.clear();
    days.clear();
    goldenCards.clear();
    badges.clear();
    equippedBadge = '';
    hatMade = List.filled(kHatTrade.length, 0);
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
  _SolveCtx(
      {required this.levelId,
      required this.stars,
      required this.codeMode,
      required this.boss});
  final String levelId;
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
  // Gold and above are meant to take months of steady practice.
  Rank('rank_gold', 12000, 0xFFFFD700),
  Rank('rank_platinum', 20000, 0xFF7FE7DC),
  Rank('rank_diamond', 30000, 0xFF6EC6FF),
  Rank('rank_ioi', 45000, 0xFFFF5252),
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
