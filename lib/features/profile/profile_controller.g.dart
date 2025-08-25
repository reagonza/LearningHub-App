// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

/// Controller (Riverpod) con defensas contra UnmountedRefException:
/// - Chequeo de `ref.mounted` antes de setear `state` tras awaits/callbacks.
/// - Token de operación (_opToken) para invalidar trabajos viejos.
/// - Limpieza de canales en `onDispose`/`dispose`.
@ProviderFor(ProfileController)
const profileControllerProvider = ProfileControllerProvider._();

/// Controller (Riverpod) con defensas contra UnmountedRefException:
/// - Chequeo de `ref.mounted` antes de setear `state` tras awaits/callbacks.
/// - Token de operación (_opToken) para invalidar trabajos viejos.
/// - Limpieza de canales en `onDispose`/`dispose`.
final class ProfileControllerProvider
    extends $AsyncNotifierProvider<ProfileController, Profile?> {
  /// Controller (Riverpod) con defensas contra UnmountedRefException:
  /// - Chequeo de `ref.mounted` antes de setear `state` tras awaits/callbacks.
  /// - Token de operación (_opToken) para invalidar trabajos viejos.
  /// - Limpieza de canales en `onDispose`/`dispose`.
  const ProfileControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileControllerHash();

  @$internal
  @override
  ProfileController create() => ProfileController();
}

String _$profileControllerHash() => r'1ec93f121f7764b6c582c1f4fd44a086e9e4a29a';

abstract class _$ProfileController extends $AsyncNotifier<Profile?> {
  FutureOr<Profile?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<Profile?>, Profile?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Profile?>, Profile?>,
              AsyncValue<Profile?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
