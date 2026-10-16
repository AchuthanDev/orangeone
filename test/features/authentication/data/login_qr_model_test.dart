import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:orange_one/core/config/api_configuration.dart';
import 'package:orange_one/core/config/app_environment.dart';
import 'package:orange_one/core/errors/app_failure.dart';
import 'package:orange_one/features/authentication/data/models/login_qr_model.dart';

import '../../../support/auth_fakes.dart';

void main() {
  const configuration = ApiConfiguration(
    baseUrl: '',
    environment: AppEnvironment.development,
  );
  test('maps the supplied POS QR contract without leaking secrets', () {
    final challenge = LoginQrModel.parse(validQr(), configuration, testNow);
    expect(challenge.posSessionId, 106);
    expect(challenge.backendOrigin, testOrigin);
    expect(challenge.toString(), 'LoginChallenge(redacted)');
  });
  for (final value in [
    '',
    'not json',
    '[]',
    '{}',
    'null',
    '{"challenge":true}',
  ]) {
    test('rejects malformed payload $value', () {
      expect(
        () => LoginQrModel.parse(value, configuration, testNow),
        throwsA(
          isA<AppFailure>().having(
            (e) => e.kind,
            'kind',
            FailureKind.validation,
          ),
        ),
      );
    });
  }
  for (final server in [
    'http://192.168.1.3:8080',
    'http://192.168.1.9:8069',
    'https://another-pos.example:8443',
  ]) {
    test('accepts matching dynamic POS origin $server', () {
      final challenge = LoginQrModel.parse(
        jsonEncode({
          ...qrFields(),
          'backend_url': server,
          'rest_endpoint_url': '$server$validateChallengePath',
        }),
        configuration,
        testNow,
      );
      expect(challenge.backendOrigin, Uri.parse(server));
    });
  }
  final mutations = <String, Map<String, dynamic>>{
    'unsupported scheme': {'backend_url': 'ftp://pos.example'},
    'invalid port': {'backend_url': 'https://pos.example:65536'},
    'backend path': {'backend_url': 'https://pos.example/another'},
    'backend query': {'backend_url': 'https://pos.example?server=other'},
    'backend fragment': {'backend_url': 'https://pos.example#other'},
    'expired': {'expires_at': testNow.toIso8601String()},
    'missing timezone': {'expires_at': '2030-01-01T13:00:00'},
    'calendar overflow': {'expires_at': '2030-02-31T13:00:00Z'},
    'hour overflow': {'expires_at': '2030-01-01T25:00:00Z'},
    'timezone overflow': {'expires_at': '2030-01-01T13:00:00+99:00'},
    'wrong challenge': {'challenge': 'short'},
    'nonpositive session': {'pos_session_id': 0},
    'boolean ID': {'pos_config_id': true},
    'future version': {'version': 2},
    'different host': {'backend_url': 'https://attacker.example'},
    'different port': {'backend_url': 'https://pos.example:444'},
    'user credentials': {'backend_url': 'https://user@pos.example'},
    'endpoint on another host': {
      'rest_endpoint_url':
          'https://attacker.example/mupi/mobile/auth/challenge/validate',
    },
    'different endpoint': {
      'rest_endpoint_url': '$testOrigin/mupi/mobile/api/ping',
    },
    'query string': {
      'rest_endpoint_url':
          '$testOrigin/mupi/mobile/auth/challenge/validate?x=1',
    },
  };
  for (final entry in mutations.entries) {
    test('rejects ${entry.key}', () {
      expect(
        () => LoginQrModel.parse(
          jsonEncode({...qrFields(), ...entry.value}),
          configuration,
          testNow,
        ),
        throwsA(isA<AppFailure>()),
      );
    });
  }
}
