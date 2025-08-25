import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/attendance/attendance_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/home/home_page.dart';

import '../../features/profile/profile_controller.dart';
import '../../features/profile/profile_model.dart';
import 'router_refresh_provider.dart';

/// (Opcional) Página simple cuando el usuario no tiene permisos de rol.
class ForbiddenPage extends StatelessWidget {
  const ForbiddenPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sin permiso')),
      body: const Center(
        child: Text('No tienes permiso para acceder a esta sección.'),
      ),
    );
  }
}

/// Helper: extrae los nombres de roles del perfil.
List<String> _roleNames(Profile? p) =>
    (p?.roles ?? const []).map((r) => r.name).toList();

/// Tabla de requisitos de rol por NOMBRE DE RUTA.
/// - Usa los `name:` de tus GoRoute para mapear.
/// - Si una ruta no aparece aquí, no exige rol.
const Map<String, List<String>> _requiredRolesByRouteName = {
  // 'adminOnly': ['admin'],
  // 'reports': ['admin', 'manager'],
};

/// Provider que crea/configura GoRouter.
/// - Usa `refreshListenable` para re-evaluar redirect en cambios de auth/perfil.
/// - `redirect` aplica las reglas de:
///   * auth: /login si no hay sesión; /home si intenta entrar a /login teniendo sesión
///   * roles: redirige a /forbidden si no cumple.
final goRouterProvider = Provider<GoRouter>((ref) {
  final refresher = ref.watch(routerRefreshProvider);

  String? _redirect(BuildContext context, GoRouterState state) {
    final auth = Supabase.instance.client.auth;
    final session = auth.currentSession;

    // Rutas de interés
    final goingToLogin = state.matchedLocation == '/login';
    final goingToForbidden = state.matchedLocation == '/forbidden';

    // 1) No hay sesión -> forzamos a /login (excepto si ya está en /login)
    if (session == null) {
      return goingToLogin ? null : '/login';
    }

    // 2) Hay sesión -> impedir que "/login" sea visible
    if (goingToLogin) return '/home';

    // 3) Roles: si la ruta tiene requisitos, validarlos.
    final routeName = state.name; // name definido en GoRoute
    if (routeName != null && _requiredRolesByRouteName.containsKey(routeName)) {
      final req = _requiredRolesByRouteName[routeName]!;
      // Leer perfil (puede estar cargando). Usamos read (no watch) dentro de redirect.
      final profileAsync = ref.read(profileControllerProvider);
      final profile = profileAsync.asData?.value;

      // Si aún no cargó el perfil, evitamos "saltar" -> no redirigimos.
      if (profile == null) return null;

      final roles = _roleNames(profile);
      final hasAccess = roles.any((r) => req.contains(r));
      if (!hasAccess && !goingToForbidden) {
        return '/forbidden';
      }
    }

    // 4) Sin cambios
    return null;
  }

  return GoRouter(
    initialLocation: '/home', // o '/login' si prefieres
    refreshListenable: refresher,
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (ctx, st) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (ctx, st) => const HomePage(),
      ),
      GoRoute(
        path: '/attendance',
        name: 'attendance',
        builder: (ctx, st) => const AttendancePage(),
      ),
      GoRoute(
        path: '/forbidden',
        name: 'forbidden',
        builder: (ctx, st) => const ForbiddenPage(),
      ),

      // 🔒 Ejemplos de rutas con roles (activa y ajusta nombres):
      // GoRoute(
      //   path: '/admin',
      //   name: 'adminOnly',
      //   builder: (ctx, st) => const AdminPage(),
      // ),
      // GoRoute(
      //   path: '/reports',
      //   name: 'reports',
      //   builder: (ctx, st) => const ReportsPage(),
      // ),
    ],
    redirect: _redirect,
  );
});
