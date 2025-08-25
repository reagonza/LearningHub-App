import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Página de escaneo de QR usando `mobile_scanner`.
///
/// 🔁 Navegación (corregida):
/// - Si el caller **provee** `onQRScanned`, **NO** hacemos `Navigator.pop` aquí.
///   El caller decide cuándo y cómo cerrar (por ejemplo, para volver a AttendancePage).
/// - Si el caller **NO** provee `onQRScanned`, hacemos `Navigator.pop(code)` como
///   comportamiento por defecto, devolviendo el QR leído.
///
/// Esto evita el "doble pop" que podía mandarte hasta Home.
///
/// Otras notas:
/// - Manejo local de linterna/cámara para compatibilidad con distintas versiones.
/// - Bloqueo contra múltiples lecturas con `handled`.
class QRScannerPage extends HookConsumerWidget {
  const QRScannerPage({super.key, this.onQRScanned});

  /// Callback opcional que recibe el QR leído.
  /// Si está definido, esta página **no navega** (no hace pop); el caller decide.
  final Future<void> Function(String code)? onQRScanned;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Controlador de la cámara/escáner.
    final controller = useMemoized(
      () => MobileScannerController(
        facing: CameraFacing.back,
        torchEnabled: false,
        // Si tu versión no soporta estas opciones, elimínalas:
        // detectionSpeed: DetectionSpeed.noDuplicates,
        // returnImage: false,
        formats: const [BarcodeFormat.qrCode],
      ),
      const [],
    );

    // ===== Estado local =====
    final torchOn = useState(false); // Linterna encendida/apagada
    final isBackCamera = useState(true); // Cámara trasera/frontal
    final handled = useState(false); // Evitar lecturas múltiples

    // ===== Ciclo de vida / orientación =====
    useEffect(() {
      // Fuerza orientación vertical en móviles (opcional).
      if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      }
      // Limpieza al salir.
      return () async {
        try {
          await controller.stop();
        } catch (_) {}
        controller.dispose();
        if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
          SystemChrome.setPreferredOrientations(DeviceOrientation.values);
        }
      };
    }, const []);

    // ===== Handler de detección =====
    Future<void> _onDetect(BarcodeCapture capture) async {
      // Evitar reentradas o capturas vacías
      if (handled.value) return;
      if (capture.barcodes.isEmpty) return;

      final code = capture.barcodes.first.rawValue ?? '';
      if (code.isEmpty) return;

      handled.value = true; // Bloquea futuros eventos de esta sesión

      // Detén la cámara antes de navegar/ejecutar callback
      try {
        await controller.stop();
      } catch (_) {}

      try {
        if (onQRScanned != null) {
          // ✅ Caller decide cerrar: esto evita doble pop.
          await onQRScanned!(code);
        } else {
          // 🔙 Fallback: cerrar devolviendo el código si no hay callback.
          if (context.mounted) {
            Navigator.of(context).pop<String>(code);
          }
        }
      } catch (e) {
        // Si algo falla, permite un nuevo intento en esta sesión.
        handled.value = false;
        // (Opcional) mostrar un error visible:
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error procesando QR: $e')));
        }
        // Intenta reanudar la cámara si corresponde
        try {
          await controller.start();
        } catch (_) {}
      }
    }

    // ===== Controles =====
    Future<void> _toggleTorch() async {
      try {
        await controller.toggleTorch();
        torchOn.value = !torchOn.value; // reflejamos el estado localmente
      } catch (_) {
        // (Opcional) mostrar error
      }
    }

    Future<void> _switchCamera() async {
      try {
        await controller.switchCamera();
        isBackCamera.value = !isBackCamera.value;
      } catch (_) {
        // (Opcional) mostrar error
      }
    }

    // ===== UI =====
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Escanear código'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Vista de cámara + detección
          MobileScanner(controller: controller, onDetect: _onDetect),

          // Overlay con recorte central para guiar al usuario
          _ScannerOverlay(),

          // Controles (linterna / cambiar cámara)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                      ),
                      icon: Icon(
                        torchOn.value ? Icons.flash_on : Icons.flash_off,
                        color: torchOn.value ? Colors.yellow : Colors.white,
                      ),
                      onPressed: _toggleTorch,
                      tooltip: 'Linterna',
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                      ),
                      icon: const Icon(Icons.cameraswitch, color: Colors.white),
                      onPressed: _switchCamera,
                      tooltip: isBackCamera.value
                          ? 'Cámara frontal'
                          : 'Cámara trasera',
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Pie de ayuda
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              color: Colors.black45,
              child: const Text(
                'Apunta el QR dentro del recuadro',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Overlay de guía (cuadrado central con bordes redondeados + “sombra”)
class _ScannerOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final boxSide = size.width * 0.7; // Tamaño del cuadro de guía

    return Stack(
      children: [
        // Sombra con "agujero" central para enfocar el área del QR
        ColorFiltered(
          colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.srcOut),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(color: Colors.black.withOpacity(0.5)),
              Center(
                child: Container(
                  width: boxSide,
                  height: boxSide,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Borde blanco visible del recuadro
        Center(
          child: Container(
            width: boxSide,
            height: boxSide,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              border: Border.all(color: Colors.white, width: 3),
            ),
          ),
        ),
      ],
    );
  }
}
