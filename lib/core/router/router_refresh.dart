import 'dart:async';
import 'package:flutter/foundation.dart';

/// Convierte un Stream en un Listenable para usar en GoRouter.refreshListenable.
/// Útil para refrescar el router cuando cambia el estado de auth (login/logout).
class RouterRefreshStream extends ChangeNotifier {
  RouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) {
      notifyListeners(); // cada evento pide al router re-evaluar redirects
    });
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
