// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

/// Proveedor del servicio (inyecta el SupabaseClient activo).
@ProviderFor(attendanceService)
const attendanceServiceProvider = AttendanceServiceProvider._();

/// Proveedor del servicio (inyecta el SupabaseClient activo).
final class AttendanceServiceProvider
    extends
        $FunctionalProvider<
          AttendanceService,
          AttendanceService,
          AttendanceService
        >
    with $Provider<AttendanceService> {
  /// Proveedor del servicio (inyecta el SupabaseClient activo).
  const AttendanceServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attendanceServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attendanceServiceHash();

  @$internal
  @override
  $ProviderElement<AttendanceService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AttendanceService create(Ref ref) {
    return attendanceService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AttendanceService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AttendanceService>(value),
    );
  }
}

String _$attendanceServiceHash() => r'34989f1625db21d82daa96c87015cf73b80cffeb';

/// Controller principal que carga el estado de asistencia y expone acciones.
@ProviderFor(AttendanceController)
const attendanceControllerProvider = AttendanceControllerProvider._();

/// Controller principal que carga el estado de asistencia y expone acciones.
final class AttendanceControllerProvider
    extends $AsyncNotifierProvider<AttendanceController, AttendanceViewData> {
  /// Controller principal que carga el estado de asistencia y expone acciones.
  const AttendanceControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attendanceControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attendanceControllerHash();

  @$internal
  @override
  AttendanceController create() => AttendanceController();
}

String _$attendanceControllerHash() =>
    r'8edec7a128a95d07d592b035e077b833bfa08ecb';

abstract class _$AttendanceController
    extends $AsyncNotifier<AttendanceViewData> {
  FutureOr<AttendanceViewData> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<AttendanceViewData>, AttendanceViewData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AttendanceViewData>, AttendanceViewData>,
              AsyncValue<AttendanceViewData>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
