import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/profile/profile_model.dart';

/// Cache local para guardar/leer el Profile actual.
/// - Rápido para mostrar datos instantáneamente.
/// - No es fuente de verdad (siempre se refresca desde el server).
class LocalUserCache {
  static const _kKey = 'current_profile_v1';

  Future<void> save(Profile p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, jsonEncode(p.toMap()));
  }

  Future<Profile?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return Profile.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kKey);
  }
}
