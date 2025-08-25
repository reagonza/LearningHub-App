/// Modelo de un registro de asistencia.
///
/// - Campos principales mapeados desde la tabla `attendance_logs`.
/// - Parseo **robusto** para evitar errores por `null` o tipos inesperados.
/// - Incluye `createdAt` y dos getters derivados:
///     - [totalWorkedDuration]: duración total trabajada.
///     - [formattedTotalHours]: duración formateada como "Hh MMm".
class AttendanceLog {
  /// ID del registro (UUID).
  final String id;

  /// ID del usuario dueño del registro.
  final String userId;

  /// Fecha/hora de check-in (convertido a zona local).
  final DateTime checkIn;

  /// Fecha/hora de check-out (convertido a zona local), si existe.
  final DateTime? checkOut;

  /// Estado: 'open' | 'closed' | 'needs_review'
  final String status;

  /// Minutos trabajados (puede ser null si el registro está abierto).
  final int? minutesWorked;

  /// Nombre del punto (si hay join con attendance_points) o null.
  final String? pointName;

  /// Fecha/hora de creación del registro (convertido a zona local).
  /// Si no viene `created_at`, se usa `checkOut` o, como último recurso, `checkIn`.
  final DateTime createdAt;

  const AttendanceLog({
    required this.id,
    required this.userId,
    required this.checkIn,
    required this.status,
    required this.createdAt,
    this.checkOut,
    this.minutesWorked,
    this.pointName,
  });

  // ========= Getters derivados =========

  /// Duración total trabajada.
  ///
  /// Prioriza `minutesWorked` (si viene pre-calculado desde el backend).
  /// Si no está, intenta calcular con `checkOut - checkIn`.
  /// Si no hay datos suficientes, devuelve `Duration.zero`.
  Duration get totalWorkedDuration {
    if (minutesWorked != null) {
      return Duration(minutes: minutesWorked!);
    }
    if (checkOut != null) {
      return checkOut!.difference(checkIn);
    }
    return Duration.zero;
  }

  /// Duración formateada tipo "2h 05m".
  ///
  /// Si no hay datos suficientes, devuelve "-".
  String get formattedTotalHours {
    final d = totalWorkedDuration;
    if (d == Duration.zero) return '-';
    final h = d.inHours;
    final m = d.inMinutes % 60;
    String two(int x) => x.toString().padLeft(2, '0');
    return '${h}h ${two(m)}m';
  }

  // ========= Utilidades de parseo =========

  /// Parser flexible para DateTime:
  /// - Acepta `String` ISO8601, `DateTime` o `null`.
  /// - Convierte a zona local.
  static DateTime? _parseTs(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v.toLocal();
    if (v is String && v.isNotEmpty) {
      final dt = DateTime.tryParse(v);
      return dt?.toLocal();
    }
    return null;
  }

  /// Lee `point_name` directo o `point: { name: ... }` si viene por join.
  static String? _parsePointName(Map<String, dynamic> json) {
    final pn = json['point_name'];
    if (pn is String && pn.isNotEmpty) return pn;
    final point = json['point'];
    if (point is Map && point['name'] is String) {
      final name = point['name'] as String;
      return name.isNotEmpty ? name : null;
    }
    return null;
  }

  /// Creador desde JSON del backend (Supabase).
  factory AttendanceLog.fromJson(Map<String, dynamic> json) {
    // Campos obligatorios con fallback seguro
    final id = (json['id'] as String?) ?? '';
    final userId = (json['user_id'] as String?) ?? '';

    // Timestamps
    final checkIn = _parseTs(json['check_in']);
    final checkOut = _parseTs(json['check_out']);
    final createdAt = _parseTs(json['created_at']) ?? checkOut ?? checkIn;

    if (checkIn == null) {
      throw StateError('AttendanceLog.check_in es requerido y vino null');
    }
    if (createdAt == null) {
      throw StateError(
        'AttendanceLog.created_at/check_out/check_in vinieron null',
      );
    }

    return AttendanceLog(
      id: id,
      userId: userId,
      checkIn: checkIn,
      checkOut: checkOut,
      status: (json['status'] as String?) ?? '',
      minutesWorked: json['minutes_worked'] is int
          ? json['minutes_worked'] as int
          : (json['minutes_worked'] == null
                ? null
                : int.tryParse(json['minutes_worked'].toString())),
      pointName: _parsePointName(json),
      createdAt: createdAt,
    );
  }

  /// Serialización a JSON (útil si necesitas enviar/guardar en cliente).
  Map<String, dynamic> toJson() {
    String _iso(DateTime? d) => d?.toUtc().toIso8601String() ?? '';
    return {
      'id': id,
      'user_id': userId,
      'check_in': _iso(checkIn),
      'check_out': _iso(checkOut),
      'status': status,
      'minutes_worked': minutesWorked,
      if (pointName != null) 'point_name': pointName,
      'created_at': _iso(createdAt),
    };
  }
}
