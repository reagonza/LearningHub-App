import 'package:supabase_flutter/supabase_flutter.dart';

/// Cliente global de Supabase
final supabase = Supabase.instance.client;

/// Inicializa Supabase
Future<void> initSupabase() async {
  await Supabase.initialize(url: '', anonKey: '');
}
