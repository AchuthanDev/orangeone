import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:orange_one/features/home/presentation/widgets/product_camera.dart';
import 'package:orange_one/shared/widgets/code_camera.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const permissions = MethodChannel('flutter.baseflow.com/permissions/methods');
  const scanner = MethodChannel(
    'dev.steenbakker.mobile_scanner/scanner/method',
  );
  const events = MethodChannel('dev.steenbakker.mobile_scanner/scanner/event');
  const orientation = MethodChannel(
    'dev.steenbakker.mobile_scanner/scanner/deviceOrientation',
  );
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() {
    for (final channel in [permissions, scanner, events, orientation]) {
      messenger.setMockMethodCallHandler(channel, null);
    }
  });

  for (final singleScan in [true, false]) {
    testWidgets('camera filters formats with singleScan=', (tester) async {
      final codes = <String>[];
      final calls = <MethodCall>[];
      messenger
        ..setMockMethodCallHandler(
          permissions,
          (call) async =>
              call.method == 'requestPermissions' ? <int, int>{1: 1} : 1,
        )
        ..setMockMethodCallHandler(scanner, (call) async {
          calls.add(call);
          if (call.method == 'state') return 1;
          if (call.method == 'request') return true;
          if (call.method == 'start') {
            return <String, Object?>{
              'textureId': 1,
              'size': {'width': 640.0, 'height': 480.0},
              'numberOfCameras': 1,
              'cameraDirection': 1,
              'handlesCropAndRotation': true,
              'naturalDeviceOrientation': 'PORTRAIT_UP',
              'sensorOrientation': 90,
            };
          }
          return null;
        })
        ..setMockMethodCallHandler(events, (call) async => null)
        ..setMockMethodCallHandler(orientation, (call) async => null);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CodeCamera(
              singleScan: singleScan,
              onCode: codes.add,
              onStatus: (status) {},
              formats: supportedProductFormats,
              instructions: 'Allow product scanning',
              readyMessage: 'Ready',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final camera = tester.widget<MobileScanner>(find.byType(MobileScanner));
      camera.onDetect!(
        const BarcodeCapture(
          barcodes: [
            Barcode(rawValue: 'login-qr', format: BarcodeFormat.qrCode),
          ],
        ),
      );
      expect(codes, isEmpty);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      camera.onDetect!(
        const BarcodeCapture(
          barcodes: [
            Barcode(rawValue: 'background-code', format: BarcodeFormat.ean13),
          ],
        ),
      );
      expect(codes, isEmpty);
      await tester.pumpAndSettle();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      for (final format in supportedProductFormats) {
        camera.onDetect!(
          BarcodeCapture(
            barcodes: [Barcode(rawValue: '0010101010', format: format)],
          ),
        );
      }
      expect(
        codes,
        List.filled(
          singleScan ? 1 : supportedProductFormats.length,
          '0010101010',
        ),
      );
      expect(camera.controller?.formats, supportedProductFormats);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(calls.any((call) => call.method == 'stop'), isTrue);
      expect(tester.takeException(), isNull);
    });
  }
  for (final status in [0, 2, 4]) {
    testWidgets('product camera handles permission state $status', (
      tester,
    ) async {
      messenger
        ..setMockMethodCallHandler(
          permissions,
          (call) async => call.method == 'requestPermissions'
              ? <int, int>{1: status}
              : status,
        )
        ..setMockMethodCallHandler(scanner, (call) async => null);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CodeCamera(
              onCode: (code) => fail('Denied camera must not emit a barcode'),
              onStatus: (status) {},
              formats: supportedProductFormats,
              instructions: 'Allow product scanning',
              readyMessage: 'Ready',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MobileScanner), findsNothing);
      expect(
        find.text(
          status == 2
              ? 'Camera access is restricted on this device.'
              : 'Allow product scanning',
        ),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('camera startup failure reports a safe retryable camera state', (
    tester,
  ) async {
    final statuses = <String>[];
    var failStart = true;
    messenger
      ..setMockMethodCallHandler(
        permissions,
        (call) async =>
            call.method == 'requestPermissions' ? <int, int>{1: 1} : 1,
      )
      ..setMockMethodCallHandler(scanner, (call) async {
        if (call.method == 'state') return 1;
        if (call.method == 'start' && failStart) {
          throw PlatformException(
            code: 'camera-error',
            message: 'private platform detail',
          );
        }
        if (call.method == 'start') {
          return <String, Object?>{
            'textureId': 1,
            'cameraDirection': 1,
            'handlesCropAndRotation': true,
            'naturalDeviceOrientation': 'PORTRAIT_UP',
            'sensorOrientation': 90,
            'size': {'width': 640.0, 'height': 480.0},
            'numberOfCameras': 1,
          };
        }
        return null;
      })
      ..setMockMethodCallHandler(events, (call) async => null)
      ..setMockMethodCallHandler(orientation, (call) async => null);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CodeCamera(
            onCode: (code) => fail('Camera failure must not emit a code'),
            onStatus: statuses.add,
            formats: supportedProductFormats,
            instructions: 'Allow product scanning',
            readyMessage: 'Ready',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Allow camera / Retry'), findsOneWidget);
    expect(find.textContaining('private platform detail'), findsNothing);
    expect(statuses, contains('Camera unavailable'));
    failStart = false;
    await tester.tap(find.text('Allow camera / Retry'));
    await tester.pumpAndSettle();
    expect(find.byType(MobileScanner), findsOneWidget);
    expect(statuses.last, 'Ready');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
