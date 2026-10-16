import 'dart:convert';

import 'package:orange_one/core/config/api_configuration.dart';
import 'package:orange_one/core/errors/app_failure.dart';
import 'package:orange_one/core/formatting/utc_timestamp.dart';
import 'package:orange_one/features/authentication/domain/entities/login_challenge.dart';

const validateChallengePath = '/mupi/mobile/auth/challenge/validate';
const checkTokenPath = '/mupi/mobile/auth/token/check';

class LoginQrModel {
  static LoginChallenge parse(
    String raw,
    ApiConfiguration configuration,
    DateTime now,
  ) {
    try {
      if (raw.isEmpty || raw.length > 8192) throw invalidQr;
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) throw invalidQr;
      // The supplied contract has no version field. Reject future versions.
      if (json.containsKey('version')) {
        throw const AppFailure(
          FailureKind.unsupportedQr,
          'This QR code version is not supported. Generate a compatible '
          'POS QR code.',
        );
      }
      final challenge = json['challenge'];
      final nonce = json['nonce'];
      final session = json['pos_session_id'];
      final config = json['pos_config_id'];
      final backend = json['backend_url'];
      final endpoint = json['rest_endpoint_url'];
      final expiry = json['expires_at'];
      final tokenPattern = RegExp(r'^[A-Za-z0-9_-]{43}$');
      if (challenge is! String ||
          !tokenPattern.hasMatch(challenge) ||
          nonce is! String ||
          !tokenPattern.hasMatch(nonce) ||
          session is! int ||
          session <= 0 ||
          config is! int ||
          config <= 0 ||
          backend is! String ||
          endpoint is! String ||
          expiry is! String ||
          !RegExp(r'(Z|[+-]\d{2}:\d{2})$').hasMatch(expiry)) {
        throw invalidQr;
      }
      final origin = configuration.validateOrigin(backend);
      if (Uri.parse(endpoint) != origin.resolve(validateChallengePath)) {
        throw const AppFailure(
          FailureKind.unsupportedQr,
          'The QR login endpoint does not match its Odoo server. '
          'Generate a new QR code on your POS machine.',
        );
      }
      final expiresAt = parseUtcTimestamp(expiry);
      if (!expiresAt.isAfter(now)) {
        throw const AppFailure(
          FailureKind.expiredQr,
          'This QR code has expired. Generate a new QR code '
          'on your POS machine.',
        );
      }
      return LoginChallenge(
        challenge: challenge,
        nonce: nonce,
        posSessionId: session,
        posConfigId: config,
        backendOrigin: origin,
        expiresAt: expiresAt,
      );
    } on FormatException {
      throw invalidQr;
    }
  }
}
