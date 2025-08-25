class Role {
  final int id;
  final String name;

  const Role({required this.id, required this.name});

  factory Role.fromMap(Map<String, dynamic> json) =>
      Role(id: json['id'] as int, name: (json['name'] ?? '').toString());

  Map<String, dynamic> toMap() => {'id': id, 'name': name};
}
