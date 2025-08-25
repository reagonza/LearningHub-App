import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'attendance_log_model.dart';
import 'attendance_service.dart';

part 'attendance_controller.g.dart';

/// Estructura que consumen las pantallas: estado + resumen + historial.
class AttendanceViewData {
  final Map<String, dynamic>
  status; // { openCount, lastOpenAt, lastOpenPoint, lastClosed }
  final Map<String, dynamic>
  weekSummary; // { totalMinutes, totalHours, daysWorked, averageMinutesPerDay }
  final List<AttendanceLog> history;

  const AttendanceViewData({
    required this.status,
    required this.weekSummary,
    required this.history,
  });

  /// ¿Hay al menos un check-in hoy sin cierre?
  bool get hasCheckInToday {
    final oc = status['openCount'] as int? ?? 0;
    if (oc > 0) return true;
    final now = DateTime.now();
    for (final log in history) {
      final d = log.checkIn;
      if (d.year == now.year &&
          d.month == now.month &&
          d.day == now.day &&
          log.status == 'open') {
        return true;
      }
    }
    return false;
  }

  /// ¿Existe un registro cerrado hoy?
  bool get hasCompleteToday {
    final lastClosed = status['lastClosed'] as AttendanceLog?;
    if (lastClosed == null) return false;
    final d = lastClosed.createdAt;
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }
}

/// Proveedor del servicio (inyecta el SupabaseClient activo).
@riverpod
AttendanceService attendanceService(Ref ref) {
  final client = Supabase.instance.client;
  return AttendanceService(client);
}

/// Controller principal que carga el estado de asistencia y expone acciones.
@Riverpod(keepAlive: true)
class AttendanceController extends _$AttendanceController {
  DateTime? _asDT(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v)?.toLocal();
    return null;
  }

  /// Normaliza el `status` que entrega el service para evitar casteos peligrosos.
  Map<String, dynamic> _normalizeStatus(Map<String, dynamic> raw) {
    final lc = raw['lastClosed'];
    AttendanceLog? lastClosed;
    if (lc is Map<String, dynamic>) {
      lastClosed = AttendanceLog.fromJson(lc);
    } else if (lc is AttendanceLog) {
      lastClosed = lc;
    }

    return {
      'openCount': raw['openCount'] ?? raw['openCountToday'] ?? 0,
      'lastOpenAt': _asDT(raw['lastOpenAt']),
      'lastOpenPoint': raw['lastOpenPoint']?.toString(),
      'lastClosed': lastClosed,
    };
  }

  @override
  Future<AttendanceViewData> build() async {
    final svc = ref.read(attendanceServiceProvider);
    final status = _normalizeStatus(await svc.getCurrentStatus());
    final week = await svc.getWeeklySummary();
    final hist = await svc.getAttendanceHistory(days: 14);
    return AttendanceViewData(status: status, weekSummary: week, history: hist);
  }

  /// Fuerza recarga completa (útil para pull-to-refresh).
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  /// Procesa un QR y recarga el estado.
  Future<void> scan(String code) async {
    final svc = ref.read(attendanceServiceProvider);
    state = const AsyncLoading();
    await svc.processQRScan(code);
    state = await AsyncValue.guard(build);
  }
}
