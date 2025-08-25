// lib/features/auth/auth_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/local_storage/local_user_cache.dart';
import '../profile/profile_controller.dart';
import 'auth_service.dart';

part 'auth_controller.g.dart';

/// Estado de autenticación para controlar loading/errores y previsualizaciones.
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final String? aliasPreview;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.aliasPreview,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? aliasPreview,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      aliasPreview: aliasPreview ?? this.aliasPreview,
    );
  }
}

@riverpod
class AuthController extends _$AuthController {
  @override
  AuthState build() {
    return const AuthState();
  }

  /// Inicia sesión con email/contraseña
  Future<void> signInWithEmail({
    required String email,
    required String password,
    required void Function() onSuccess,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await ref
          .read(authServiceProvider)
          .signInWithEmail(email: email, password: password);
      onSuccess();
      state = state.copyWith(isLoading: false);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Inicia sesión con identificador (ID) + contraseña (alias de email)
  Future<void> signInWithIdentifier({
    required String identifier,
    required String password,
    required void Function() onSuccess,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final preview = ref
          .read(authServiceProvider)
          .aliasEmailFromId(identifier);
      state = state.copyWith(aliasPreview: preview);

      await ref
          .read(authServiceProvider)
          .signInWithIdentifier(identifier: identifier, password: password);

      onSuccess();
      state = state.copyWith(isLoading: false);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Cerrar sesión de forma segura (sin usar `ref` tras `await`)
  ///
  /// Puntos clave:
  /// - Capturamos dependencias ANTES del `await`.
  /// - Limpiamos cache local sin depender de `ref`.
  /// - Si el provider sigue montado, invalidamos los que dependen del usuario.
  Future<void> signOut() async {
    // 1) Capturar dependencias ANTES del await
    final auth = ref.read(authServiceProvider);
    final cache = LocalUserCache();

    try {
      // 2) Cerrar sesión en Supabase
      await auth.signOut();

      // 3) Limpiar cache local (no depende de `ref`)
      await cache.clear();
    } catch (e) {
      // Propaga para que la UI decida si mostrar algo
      rethrow;
    } finally {
      // 4) Solo si el provider sigue montado, invalidamos estados derivados
      if (ref.mounted) {
        // Esto fuerza a que la info de perfil se vuelva a cargar cuando corresponda
        ref.invalidate(profileControllerProvider);
      }
      // Navegación/redirect NO desde aquí: que la maneje el router
      // al detectar que la sesión es null.
    }
  }
}
