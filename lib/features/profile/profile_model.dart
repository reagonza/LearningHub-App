import 'rol_model.dart';

class Profile {
  final String id;
  final String email;
  final String firstNames;
  final String lastNames;
  final bool isActive;
  final List<Role> roles;

  const Profile({
    required this.id,
    required this.email,
    required this.firstNames,
    required this.lastNames,
    required this.isActive,
    required this.roles,
  });

  String get displayName {
    final f = firstNames.trim();
    final l = lastNames.trim();
    if (f.isEmpty && l.isEmpty) return email;
    return '$f $l'.trim();
  }

  factory Profile.fromMap(Map<String, dynamic> json) {
    final rolesRaw = (json['roles'] as List?) ?? const [];
    return Profile(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      firstNames: (json['first_names'] ?? '').toString(),
      lastNames: (json['last_names'] ?? '').toString(),
      isActive: (json['is_active'] ?? false) as bool,
      roles: rolesRaw
          .map((e) => Role.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'email': email,
    'first_names': firstNames,
    'last_names': lastNames,
    'is_active': isActive,
    'roles': roles.map((r) => r.toMap()).toList(),
  };
}
