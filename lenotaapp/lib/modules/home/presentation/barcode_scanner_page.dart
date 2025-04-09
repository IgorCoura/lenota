import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lenotaapp/modules/home/domain/note.dart';
import 'package:lenotaapp/modules/home/exceptions/duplicate_exception.dart';
import 'package:lenotaapp/modules/home/presentation/buttons/switch_camera_button.dart';
import 'package:lenotaapp/modules/home/presentation/buttons/toggle_flashlight_button.dart';
import 'package:lenotaapp/modules/home/service/home_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final homeService = Modular.get<HomeService>();
  final audioPlayer = Modular.get<AudioPlayer>();
  bool scanBarCode = false;
  final _scannerEnabled = ValueNotifier(true);
  MobileScannerController controller = MobileScannerController(
    autoStart: false,
    facing: CameraFacing.back,
    torchEnabled: false,
    detectionSpeed: DetectionSpeed.normal,
    autoZoom: true,
  );

  Rect get scanMode => scanBarCode ? scanWindowBarCode : scanWindowQRCode;

  late final scanWindowQRCode = Rect.fromCenter(
    center: MediaQuery.sizeOf(context).center(const Offset(0, 0)),
    width: MediaQuery.sizeOf(context).width * 0.7,
    height: MediaQuery.sizeOf(context).width * 0.7,
  );

  late final scanWindowBarCode = Rect.fromCenter(
    center: MediaQuery.sizeOf(context).center(const Offset(0, 0)),
    width: MediaQuery.sizeOf(context).width * 0.35,
    height: MediaQuery.sizeOf(context).height * 0.8,
  );

  Future<void> _showDialogOnDetect(
      MobileScannerController controller, BarcodeCapture data) async {
    if (!_scannerEnabled.value) {
      return;
    }
    if (data.barcodes.isNotEmpty) {
      _scannerEnabled.value = false;
      final String? last = data.barcodes.last.displayValue;
      audioPlayer.play(AssetSource('audio/beep-07a.wav'));
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Codigo Detectado"),
          content: Text(last ?? "Erro. ente novamente."),
          actions: [
            TextButton(
              onPressed: () async {
                _scannerEnabled.value = true;
                if (last == null) {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                  return;
                }

                try {
                  await homeService.addScanner(Note(
                    id: const Uuid().v7(),
                    scannerFormat: data.barcodes.last.format.name,
                    data: last!,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ));
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                } on DuplicateException catch (error) {
                  if (mounted) {
                    Navigator.of(context).pop();
                    _showDialogOnError(error);
                  }
                }
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _showDialogOnError(Object error) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(error.toString()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    controller.barcodes
        .listen((barcode) => _showDialogOnDetect(controller, barcode));

    unawaited(controller.start());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Modular.to.navigate("/");
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                scanBarCode = !scanBarCode;
              });
            },
            icon: const Icon(Icons.qr_code_scanner),
          ),
          ToggleFlashlightButton(controller: controller),
          SwitchCameraButton(controller: controller),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            scanWindow: scanMode,
            controller: controller,
            fit: BoxFit.cover,
            overlayBuilder: (context, constraints) => CustomPaint(
              size: MediaQuery.sizeOf(context),
              painter: ScanWindowPainter(
                borderColor: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                borderStrokeCap: StrokeCap.butt,
                borderStrokeJoin: StrokeJoin.miter,
                borderStyle: PaintingStyle.stroke,
                borderWidth: 2.0,
                scanWindow: scanMode,
                color: const Color(0x80000000),
              ),
            ),
            placeholderBuilder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    // Finally, dispose of the controller.
    await controller.dispose();
  }
}
