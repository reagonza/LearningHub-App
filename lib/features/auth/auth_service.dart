import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants.dart';

part 'auth_service.g.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String normalizeIdentifier(String input) {
    final lower = input.trim().toLowerCase();
    final filtered = lower.replaceAll(RegExp(r'[^a-z0-9]'), '');
    return filtered; // NO quitar ceros a la izquierda
  }

  /// ID -> "correo alias" determinista
  String aliasEmailFromId(String idRaw) {
    final n = normalizeIdentifier(idRaw);
    return '$kAliasEmailPrefix.$n@$kAliasEmailDomain';
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (_) {
      throw Exception('Error inesperado al iniciar sesión.');
    }
  }

  Future<void> signInWithIdentifier({
    required String identifier,
    required String password,
  }) async {
    final alias = aliasEmailFromId(identifier);
    await signInWithEmail(email: alias, password: password);
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (_) {
      throw Exception('Error inesperado al cerrar sesión.');
    }
  }
}

@Riverpod(keepAlive: true)
AuthService authService(ref) => AuthService();
