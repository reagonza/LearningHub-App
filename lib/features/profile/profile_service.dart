import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_model.dart';

/// Service: se encarga SOLO de hablar con Supabase (HTTP + Realtime).
class ProfileService {
  final SupabaseClient sb;
  ProfileService(this.sb);

  /// Consulta compuesta:
  /// - Lee `profiles` por id
  /// - Resuelve roles a través de `user_roles(role_id, roles(id, name))`
  ///   y lo devuelve ya "aplanado" como lista de {id, name}
  Future<Profile> fetchMyProfile(String userId) async {
    // 1) Traemos profile + user_roles + roles en UNA consulta
    final res = await sb
        .from('profiles')
        .select('''
          id,
          email,
          first_names,
          last_names,
          is_active,
          user_roles: user_roles (
            role_id,
            roles (
              id, name
            )
          )
        ''')
        .eq('id', userId)
        .single();

    // 2) Aplanamos los roles de la estructura anidada user_roles.roles -> roles[]
    final List roles = (res['user_roles'] as List? ?? const [])
        .map((ur) => ur['roles'])
        .where((r) => r != null)
        .toList();

    final profileMap = {
      'id': res['id'],
      'email': res['email'] ?? (sb.auth.currentUser?.email ?? ''),
      'first_names': res['first_names'],
      'last_names': res['last_names'],
      'is_active': res['is_active'] ?? false,
      'roles': roles, // lista de {id, name}
    };

    return Profile.fromMap(profileMap);
  }

  /// Suscripción a cambios en `profiles` (solo la fila del usuario actual).
  RealtimeChannel subscribeProfile({
    required String userId,
    required void Function(Map<String, dynamic> newRow) onChange,
  }) {
    return sb
        .channel('profiles_user_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'profiles',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: userId,
          ),
          callback: (payload) => onChange(payload.newRecord),
        )
        .subscribe();
  }

  /// Suscripción a cambios en user_roles del usuario (alta/baja de roles).
  /// Si cambian los roles, el Controller hará un refresh completo para resolver
  /// los nombres desde `roles`.
  RealtimeChannel subscribeUserRoles({
    required String userId,
    required Future<void> Function() onAnyChange, // insert/update/delete
  }) {
    final ch = sb.channel('user_roles_user_$userId');

    void _common() {
      // Ejecutamos refresh (externo) ante cualquier cambio en la tabla intermedia
      onAnyChange();
    }

    ch.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'user_roles',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (_) => _common(),
    );

    ch.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'user_roles',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (_) => _common(),
    );

    ch.onPostgresChanges(
      event: PostgresChangeEvent.delete,
      schema: 'public',
      table: 'user_roles',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (_) => _common(),
    );

    return ch.subscribe();
  }
}
