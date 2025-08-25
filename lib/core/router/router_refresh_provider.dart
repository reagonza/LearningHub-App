import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/profile/profile_controller.dart';

/// Notificador que "despierta" a go_router cuando cambian:
/// 1) El estado de autenticación (login/logout/refresh token).
/// 2) El perfil/roles (para redirecciones por rol).
class RouterRefresh extends ChangeNotifier {
  final Ref ref;
  late final StreamSubscription<AuthState> _authSub;

  RouterRefresh(this.ref) {
    // Cualquier cambio de auth -> refrescar router
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners(); // permitido: estamos dentro de la subclase
    });
  }

  /// Método público seguro para disparar un refresh desde fuera de la clase.
  /// Úsalo en lugar de llamar notifyListeners() directamente desde el provider.
  void ping() {
    notifyListeners(); // permitido
  }

  @override
  void dispose() {
    try {
      _authSub.cancel();
    } catch (_) {}
    super.dispose();
  }
}

/// Provider que expone el ChangeNotifier a go_router.
///
/// Importante:
/// - Usamos `ref.listen` para observar cambios del `profileControllerProvider`
///   y disparar un refresh del router mediante rr.ping().
/// - `ref.listen` se auto-limpia cuando se dispose este provider.
final routerRefreshProvider = Provider<RouterRefresh>((ref) {
  final rr = RouterRefresh(ref);

  // Cuando cambie el perfil/roles -> refrescar router
  ref.listen(profileControllerProvider, (previous, next) {
    rr.ping(); // ✅ en vez de rr.notifyListeners() (que es protegido)
  });

  // Al destruirse el provider, cerramos el RouterRefresh
  ref.onDispose(rr.dispose);

  return rr;
});
