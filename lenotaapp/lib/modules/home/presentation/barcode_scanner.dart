import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lenotaapp/modules/home/presentation/buttons/switch_camera_button.dart';
import 'package:lenotaapp/modules/home/presentation/buttons/toggle_flashlight_button.dart';
import 'package:lenotaapp/modules/home/presentation/overlay/scan_window_painter.dart';
import 'package:lenotaapp/modules/home/service/home_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner({super.key});

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  final homeService = Modular.get<HomeService>();
  bool scanBarCode = false;
  MobileScannerController controller = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  Rect get scanMode => scanBarCode ? scanWindowBarCode : scanWindowQRCode;

  late final scanWindowQRCode = Rect.fromCenter(
    center: MediaQuery.sizeOf(context).center(const Offset(0, 0)),
    width: MediaQuery.sizeOf(context).width * 0.9,
    height: MediaQuery.sizeOf(context).width * 0.9,
  );

  late final scanWindowBarCode = Rect.fromCenter(
    center: MediaQuery.sizeOf(context).center(const Offset(0, 0)),
    width: MediaQuery.sizeOf(context).width * 0.35,
    height: MediaQuery.sizeOf(context).height * 0.8,
  );

  Future<void> _showDialogOnDetect(BarcodeCapture data) async {
    if (data.barcodes.isNotEmpty) {
      final String? last = data.barcodes.last.rawValue;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Barcode detected"),
          content: Text(last ?? "No data"),
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
  }

  @override
  void initState() {
    super.initState();
    unawaited(controller.start());
    controller.barcodes.listen(_showDialogOnDetect);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
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
            placeholderBuilder: (p0, p1) => const Center(
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
