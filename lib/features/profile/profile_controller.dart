import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/local_storage/local_user_cache.dart';
import 'profile_model.dart';
import 'profile_service.dart';

part 'profile_controller.g.dart';

/// Controller (Riverpod) con defensas contra UnmountedRefException:
/// - Chequeo de `ref.mounted` antes de setear `state` tras awaits/callbacks.
/// - Token de operación (_opToken) para invalidar trabajos viejos.
/// - Limpieza de canales en `onDispose`/`dispose`.
@riverpod
class ProfileController extends _$ProfileController {
  final _cache = LocalUserCache();

  RealtimeChannel? _pCh; // suscripción a profiles
  RealtimeChannel? _urCh; // suscripción a user_roles

  // Token de operación: se incrementa cada vez que arranca una nueva carga.
  int _opToken = 0;

  @override
  FutureOr<Profile?> build() async {
    final sb = Supabase.instance.client;
    final service = ProfileService(sb);
    final userId = sb.auth.currentUser?.id;
    if (userId == null) return null;

    ref.onDispose(_teardown);
    // Limpieza automática si el provider se desecha.
    ref.onDispose(() {
      try {
        _pCh?.unsubscribe();
      } catch (_) {}
      try {
        _urCh?.unsubscribe();
      } catch (_) {}
      _pCh = null;
      _urCh = null;
      // incrementar token invalida callbacks/awaits viejos
      _opToken++;
    });

    // 1) Entrega caché inmediata si coincide ID.
    final cached = await _cache.read();
    if (cached != null && cached.id == userId) {
      // Iniciar suscripciones y refrescar en segundo plano de forma segura.
      _ensureRealtime(service, userId);
      // Dispara refresh asíncrono sin romper si nos desmontan.
      unawaited(_refreshFromServer(service, userId));
      return cached;
    }

    // 2) Sin caché → servidor
    final fresh = await service.fetchMyProfile(userId);
    await _cache.save(fresh);
    _ensureRealtime(service, userId);
    return fresh;
  }

  /// Forzar refresco desde servidor (p.ej. después de signIn).
  Future<void> refresh() async {
    final sb = Supabase.instance.client;
    final service = ProfileService(sb);
    final userId = sb.auth.currentUser?.id;

    // Si no hay usuario (por ejemplo tras signOut), limpia estado y sal.
    if (userId == null) {
      if (!ref.mounted) return;
      state = const AsyncData(null);
      return;
    }
    await _refreshFromServer(service, userId, setLoading: true);
  }

  Future<void> _refreshFromServer(
    ProfileService service,
    String userId, {
    bool setLoading = false,
  }) async {
    // Captura token actual para invalidar resultados viejos.
    final tokenAtStart = ++_opToken;

    try {
      if (setLoading) {
        if (!ref.mounted) return;
        state = const AsyncLoading();
      }

      final fresh = await service.fetchMyProfile(userId);

      // Si durante el await el provider se reconstruyó/dispusó, ignora.
      if (!ref.mounted || tokenAtStart != _opToken) return;

      state = AsyncData(fresh);
      await _cache.save(fresh);
    } catch (e, st) {
      if (!ref.mounted || tokenAtStart != _opToken) return;
      state = AsyncError(e, st);
    }
  }

  void _ensureRealtime(ProfileService service, String userId) {
    // Evitar dobles subs
    try {
      _pCh?.unsubscribe();
    } catch (_) {}
    try {
      _urCh?.unsubscribe();
    } catch (_) {}
    _pCh = null;
    _urCh = null;

    // 1) Cambios en profiles -> actualiza campos básicos conservando roles.
    _pCh = service.subscribeProfile(
      userId: userId,
      onChange: (row) async {
        // Ignora si ya no estamos montados.
        if (!ref.mounted) return;

        final email =
            Supabase.instance.client.auth.currentUser?.email ??
            (row['email'] ?? '');

        final current = state.value;
        final merged = {
          'id': row['id'],
          'email': email,
          'first_names': row['first_names'],
          'last_names': row['last_names'],
          'is_active': row['is_active'] ?? (current?.isActive ?? false),
          'roles': (current?.roles ?? const []).map((r) => r.toMap()).toList(),
        };

        // También protegemos con token para evitar carreras.
        final tokenAtStart = ++_opToken;
        if (!ref.mounted || tokenAtStart != _opToken) return;

        final p = Profile.fromMap(merged);
        if (!ref.mounted || tokenAtStart != _opToken) return;

        state = AsyncData(p);
        await _cache.save(p);
      },
    );

    // 2) Cambios en user_roles -> refresco completo (para resolver nombres).
    _urCh = service.subscribeUserRoles(
      userId: userId,
      onAnyChange: () async {
        await _refreshFromServer(service, userId);
      },
    );
  }

  // Llama a este método cuando necesites limpiar manualmente,
  // pero lo usual es que lo ejecute onDispose automáticamente.
  void _teardown() {
    try {
      _pCh?.unsubscribe();
    } catch (_) {}
    try {
      _urCh?.unsubscribe();
    } catch (_) {}
    _pCh = null;
    _urCh = null;
    _opToken++; // invalida trabajos en vuelo
  }
}
