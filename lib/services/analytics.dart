import 'package:flutter/material.dart';

import '../ui/account_screen.dart';
import '../ui/admin_screen.dart';
import '../ui/coach_admin.dart';
import '../ui/collection.dart';
import '../ui/contest.dart';
import '../ui/departamental_screen.dart';
import '../ui/halloween_screen.dart';
import '../ui/level_screen.dart';
import '../ui/map_screen.dart';
import '../ui/obi_sim_screen.dart';
import '../ui/obi_video_screen.dart';
import '../ui/badge_shop.dart';
import '../ui/review_screen.dart';
import 'analytics_io.dart' if (dart.library.js_interop) 'analytics_web.dart';

/// Product analytics (PostHog, web production only) with an anonymous id.
/// Events carry the same data as the Supabase log, code included; only
/// emails, passwords and tokens are dropped.
class Analytics {
  Analytics._();

  /// True while an admin or sign-in screen is open: nothing is sent and
  /// the session recording is paused.
  static bool _paused = false;

  static const _skip = {'heartbeat', 'tts_miss', 'sign_in'};
  static final _private =
      RegExp(r'email|mail|pass|token', caseSensitive: false);

  static void event(String type,
      {String? levelId, Map<String, dynamic>? data}) {
    if (_paused || _skip.contains(type)) return;
    final props = <String, Object>{};
    if (levelId != null) props['level_id'] = levelId;
    data?.forEach((k, v) {
      if (_private.hasMatch(k)) return;
      if (v is num || v is bool) {
        props[k] = v as Object;
      } else if (v is String) {
        props[k] = v.length > 8000 ? v.substring(0, 8000) : v;
      } else if (v is List || v is Map) {
        props[k] = v as Object;
      }
    });
    phCapture(type, props);
  }

  static void screen(String name) {
    final pause = name == 'admin' || name == 'account';
    if (pause != _paused) {
      _paused = pause;
      phRecording(!pause);
    }
    if (!pause) phCapture('pantalla', {'screen': name});
  }
}

/// Reports which screen is on top, by widget type (works with minified
/// release builds, unlike runtimeType names). Screens opened from an admin
/// or account screen inherit its privacy.
class AnalyticsObserver extends NavigatorObserver {
  final _names = <Route<dynamic>, String>{};

  static bool _private(String? n) => n == 'admin' || n == 'account';

  String? _name(Widget w) {
    if (w is AdminScreen || w is CoachAdminScreen) return 'admin';
    if (w is AccountScreen) return 'account';
    if (w is MapScreen) return 'mapa';
    if (w is LevelScreen) return 'nivel';
    if (w is CollectionScreen) return 'gatoteca';
    if (w is BadgeShopScreen) return 'tienda';
    if (w is DepartamentalScreen) return 'departamental';
    if (w is ObiSimScreen) return 'simulador_obi';
    if (w is ObiVideoScreen) return 'video_obi';
    if (w is HalloweenScreen) return 'halloween';
    if (w is ContestScreen) return 'simulacro';
    if (w is ReviewScreen) return 'repaso';
    return null;
  }

  /// Finds the page widget inside the route's built subtree (no builder is
  /// rerun, so screens with side effects in their constructors are safe).
  String? _find(Element root) {
    String? found;
    var depth = 0;
    void visit(Element e) {
      if (found != null || depth > 60) return;
      found = _name(e.widget);
      depth++;
      e.visitChildElements(visit);
      depth--;
    }

    root.visitChildElements(visit);
    return found;
  }

  void _pushed(Route<dynamic> route, Route<dynamic>? below) {
    if (route is! PageRoute) return;
    if (_private(_names[below])) {
      _names[route] = _names[below]!;
      Analytics.screen(_names[route]!);
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = route.subtreeContext;
      if (ctx is! Element || !route.isActive) return;
      _names[route] = _find(ctx) ?? 'otra';
      if (route.isCurrent) Analytics.screen(_names[route]!);
    });
  }

  void _shown(Route<dynamic>? route) {
    final n = _names[route];
    if (route is PageRoute && n != null) Analytics.screen(n);
  }

  @override
  void didPush(Route route, Route? previousRoute) =>
      _pushed(route, previousRoute);
  @override
  void didPop(Route route, Route? previousRoute) {
    _names.remove(route);
    _shown(previousRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) => _names.remove(route);
  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (oldRoute != null) _names.remove(oldRoute);
    if (newRoute != null) _pushed(newRoute, null);
  }
}
