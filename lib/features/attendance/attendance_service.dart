import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'attendance_log_model.dart';

/// Servicio de Asistencia
/// ----------------------
/// Centraliza las llamadas a Supabase y devuelve estructuras simples (Map/List)
/// que tus pantallas/controles ya consumen.
class AttendanceService {
  AttendanceService(this._sb);
  final SupabaseClient _sb;

  /// Escanea QR y decide check_in / check_out según si hay sesión abierta.
  Future<String> processQRScan(String qrCode) async {
    final user = _sb.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    // ¿Existe alguna sesión abierta? (lista de 0 o 1 elemento)
    final List<dynamic> openRows = await _sb
        .from('attendance_logs')
        .select('id')
        .eq('user_id', user.id)
        .filter('check_out', 'is', null)
        .order('check_in', ascending: false)
        .limit(1);

    final hasOpen = openRows.isNotEmpty;

    final payload = <String, dynamic>{
      'code': qrCode.trim(),
      'event_type': hasOpen ? 'check_out' : 'check_in',
    };

    final res = await _sb.functions.invoke('attendance-scan', body: payload);
    final map = _asMap(res.data);

    if (map['ok'] == true) {
      final action = (map['action'] as String?) ?? '';
      final point = (map['point_name'] as String?) ?? 'punto';
      return action == 'check_in'
          ? '¡Entrada registrada en $point!'
          : '¡Salida registrada en $point!';
    }
    throw Exception(map['error']?.toString() ?? 'No se pudo registrar.');
  }

  /// Estado actual del usuario.
  /// Retorna:
  /// {
  ///   openCount: int,
  ///   lastOpenAt: DateTime? (local),
  ///   lastOpenPoint: String?,
  ///   lastClosed: AttendanceLog?
  /// }
  Future<Map<String, dynamic>> getCurrentStatus() async {
    final user = _sb.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    // Sesiones abiertas (por seguridad limitamos varias, pero usamos la primera)
    final List<dynamic> openList = await _sb
        .from('attendance_logs')
        .select('id, check_in, point:attendance_points(name)')
        .eq('user_id', user.id)
        .filter('check_out', 'is', null)
        .order('check_in', ascending: false)
        .limit(10);

    // Último registro cerrado (para mostrar "último cierre")
    final List<dynamic> lastClosedList = await _sb
        .from('attendance_logs')
        .select(
          'id, user_id, check_in, check_out, status, minutes_worked, point:attendance_points(name), created_at',
        )
        .eq('user_id', user.id)
        .eq('status', 'closed')
        .order('check_out', ascending: false)
        .limit(1);

    AttendanceLog? lastClosed;
    if (lastClosedList.isNotEmpty) {
      lastClosed = AttendanceLog.fromJson(
        (lastClosedList.first as Map).cast<String, dynamic>(),
      );
    }

    // Parse seguro de lastOpenAt (puede venir null)
    DateTime? lastOpenAt;
    String? lastOpenPoint;
    if (openList.isNotEmpty) {
      final first = (openList.first as Map);
      final ci = first['check_in'];
      if (ci is String) {
        final parsed = DateTime.tryParse(ci);
        lastOpenAt = parsed?.toLocal();
      } else if (ci is DateTime) {
        lastOpenAt = ci.toLocal();
      }
      final p = first['point'];
      if (p is Map && p['name'] is String) {
        lastOpenPoint = p['name'] as String;
      }
    }

    return {
      'openCount': openList.length,
      'lastOpenAt': lastOpenAt,
      'lastOpenPoint': lastOpenPoint,
      'lastClosed': lastClosed,
    };
  }

  /// Resumen de 7 días (hoy inclusive).
  /// Retorna:
  /// {
  ///   totalMinutes: int,
  ///   totalHours: Duration,
  ///   daysWorked: int,
  ///   averageMinutesPerDay: int
  /// }
  Future<Map<String, dynamic>> getWeeklySummary() async {
    final user = _sb.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final today = DateTime.now();
    final from = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(const Duration(days: 6));

    final List<dynamic> rows = await _sb
        .from('attendance_logs')
        .select('minutes_worked, workday')
        .eq('user_id', user.id)
        .gte('workday', from.toIso8601String())
        .lte('workday', today.toIso8601String())
        .eq('status', 'closed');

    int totalMinutes = 0;
    final days = <String>{};
    for (final r in rows.cast<Map<String, dynamic>>()) {
      final mw = r['minutes_worked'] as int? ?? 0;
      totalMinutes += mw;
      final wd = r['workday']?.toString();
      if (wd != null) days.add(wd);
    }

    final daysWorked = days.length;
    final averageMinutesPerDay = daysWorked == 0
        ? 0
        : (totalMinutes ~/ daysWorked);

    return {
      'totalMinutes': totalMinutes,
      'totalHours': Duration(minutes: totalMinutes),
      'daysWorked': daysWorked,
      'averageMinutesPerDay': averageMinutesPerDay,
    };
  }

  /// Historial de los últimos [days] días (incluye hoy).
  Future<List<AttendanceLog>> getAttendanceHistory({int days = 7}) async {
    final user = _sb.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final today = DateTime.now();
    final from = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: days - 1));

    final List<dynamic> rows = await _sb
        .from('attendance_logs')
        .select(
          'id, user_id, check_in, check_out, status, minutes_worked, point:attendance_points(name), created_at',
        )
        .eq('user_id', user.id)
        .gte('workday', from.toIso8601String())
        .lte('workday', today.toIso8601String())
        .order('check_in', ascending: false);

    return rows
        .cast<Map<String, dynamic>>()
        .map((e) => AttendanceLog.fromJson(e))
        .toList();
  }

  Map<String, dynamic> _asMap(Object? data) {
    if (data == null) return {};
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return data.cast<String, dynamic>();
    if (data is String) return jsonDecode(data) as Map<String, dynamic>;
    try {
      return jsonDecode(data.toString()) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}
