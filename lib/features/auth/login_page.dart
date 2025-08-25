import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../profile/profile_controller.dart';
import 'auth_controller.dart';

enum LoginMode { email, id }

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = useState(LoginMode.email);
    final emailOrIdCtrl = useTextEditingController();
    final passwordCtrl = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);
    final passwordVisible = useState(false);

    final state = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);

    useEffect(() {
      final err = state.errorMessage;
      if (err != null && err.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(err)));
        });
      }
      return null;
    }, [state.errorMessage]);

    Future<void> submit() async {
      if (!(formKey.currentState?.validate() ?? false)) return;
      final idOrEmail = emailOrIdCtrl.text.trim();
      final password = passwordCtrl.text;

      if (mode.value == LoginMode.email) {
        await controller.signInWithEmail(
          email: idOrEmail,
          password: password,
          onSuccess: () async {
            await ref.read(profileControllerProvider.notifier).refresh();
            if (!context.mounted) return;
            context.go('/home');
          },
        );
      } else {
        await controller.signInWithIdentifier(
          identifier: idOrEmail,
          password: password,
          onSuccess: () async {
            await ref.read(profileControllerProvider.notifier).refresh();
            if (!context.mounted) return;
            context.go('/home');
          },
        );
      }
    }

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FluentIcons.hat_graduation_12_filled,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Learning Hub',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Inicia sesión para continuar',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: SegmentedButton<LoginMode>(
                        segments: const [
                          ButtonSegment(
                            value: LoginMode.email,
                            label: Text('Correo'),
                            icon: Icon(Icons.mail_outline),
                          ),
                          ButtonSegment(
                            value: LoginMode.id,
                            label: Text('ID (cédula/pasaporte)'),
                            icon: Icon(Icons.badge_outlined),
                          ),
                        ],
                        selected: {mode.value},
                        showSelectedIcon: false,
                        onSelectionChanged: state.isLoading
                            ? null
                            : (sel) => mode.value = sel.first,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: emailOrIdCtrl,
                      enabled: !state.isLoading,
                      textInputAction: TextInputAction.next,
                      keyboardType: mode.value == LoginMode.email
                          ? TextInputType.emailAddress
                          : TextInputType.text,
                      decoration: InputDecoration(
                        labelText: mode.value == LoginMode.email
                            ? 'Correo'
                            : 'ID (cédula/pasaporte)',
                        hintText: mode.value == LoginMode.email
                            ? 'tucorreo@dominio.com'
                            : 'Ejem: 8-888-888 o pasaporte',
                        prefixIcon: Icon(
                          mode.value == LoginMode.email
                              ? Icons.mail_outline
                              : Icons.badge_outlined,
                        ),
                      ),
                      validator: (v) {
                        final text = (v ?? '').trim();
                        if (text.isEmpty) {
                          return mode.value == LoginMode.email
                              ? 'Ingresa tu correo'
                              : 'Ingresa tu ID';
                        }
                        if (mode.value == LoginMode.email) {
                          final emailRx = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                          if (!emailRx.hasMatch(text)) {
                            return 'Correo no válido';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: passwordCtrl,
                      enabled: !state.isLoading,
                      obscureText: !passwordVisible.value,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => submit(),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              passwordVisible.value = !passwordVisible.value,
                          icon: Icon(
                            passwordVisible.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          tooltip: passwordVisible.value
                              ? 'Ocultar'
                              : 'Mostrar',
                        ),
                      ),
                      validator: (v) {
                        final text = (v ?? '');
                        if (text.isEmpty) return 'Ingresa tu contraseña';
                        if (text.length < 6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: state.isLoading ? null : submit,
                        child: state.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Iniciar sesión'),
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (mode.value == LoginMode.id &&
                        state.aliasPreview != null)
                      Text(
                        'Se usará: ${state.aliasPreview}',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
