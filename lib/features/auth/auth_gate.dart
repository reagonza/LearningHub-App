import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/router/app_router.dart';

/// AuthGate:
/// - Expone el `MaterialApp.router` con el GoRouter configurado.
/// - No tiene lógica extra; el "gate" real está en el `redirect` de GoRouter.
/// - Puedes usar este widget como raíz de tu app (`runApp(ProviderScope(child: AuthGate()))`).
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
    );
  }
}
