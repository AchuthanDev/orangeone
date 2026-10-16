import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:orange_one/shared/widgets/code_camera.dart';

typedef QrCameraBuilder = Widget Function(
  BuildContext context,
  ValueChanged<String> onCode,
  ValueChanged<String> onStatus,
);

final qrCameraBuilderProvider = Provider<QrCameraBuilder>(
  (ref) =>
      (context, onCode, onStatus) =>
          QrCamera(onCode: onCode, onStatus: onStatus),
  name: 'qrCameraBuilderProvider',
);

class QrCamera extends StatelessWidget {
  const new({required this.onCode, required this.onStatus, super.key});
  final ValueChanged<String> onCode;
  final ValueChanged<String> onStatus;

  @override
  Widget build(BuildContext context) => CodeCamera(
    onCode: onCode,
    onStatus: onStatus,
    formats: const [BarcodeFormat.qrCode],
    instructions:
        'Allow camera access to scan the QR code on your POS machine.',
    readyMessage: 'Camera on · Looking for QR code…',
  );
}
