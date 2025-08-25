import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app_theme.dart';
import 'core/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carga variables de entorno
  await dotenv.load(fileName: ".env");

  // Inicializa Supabase
  final url = dotenv.env['SUPABASE_URL'];
  final anon = dotenv.env['SUPABASE_ANON_KEY'];
  assert(
    url != null && anon != null,
    'Faltan SUPABASE_URL o SUPABASE_ANON_KEY en .env',
  );

  await Supabase.initialize(url: url!, anonKey: anon!);

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ El router ya incorpora el guard de Auth + Roles y se refresca con RouterRefresh
    final router = ref.watch(
      goRouterProvider,
    ); // si lo nombraste distinto, cámbialo aquí

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: fluentLightTheme(),
      darkTheme: fluentDarkTheme(),
      routerConfig: router,
    );
  }
}
