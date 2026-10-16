import 'dart:convert';

import 'package:orange_one/core/config/api_configuration.dart';
import 'package:orange_one/core/errors/app_failure.dart';
import 'package:orange_one/core/formatting/utc_timestamp.dart';
import 'package:orange_one/features/authentication/domain/entities/auth_session.dart';

class SessionModel {
  static AuthSession fromResult(
    Map<String, dynamic> json,
    Uri origin, {
    String? existingToken,
    int? employeeId,
  }) {
    final token = existingToken ?? json['access_token'];
    if (token is! String ||
        token.isEmpty ||
        token.length > 8192 ||
        RegExp(r'\s').hasMatch(token) ||
        (existingToken == null && json['token_type'] != 'Bearer')) {
      throw invalidResponse;
    }
    final rawExpiry = json['expires_at'];
    if (rawExpiry is! String) throw invalidResponse;
    // Odoo fields.Datetime.to_string returns a naive UTC datetime.
    late final DateTime expiresAt;
    try {
      expiresAt = parseUtcTimestamp(rawExpiry, allowOdooUtc: true);
    } on FormatException {
      throw invalidResponse;
    }
    final employee = json['employee_id'];
    if (employee != null &&
        employee != false &&
        (employee is! int || employee <= 0)) {
      throw invalidResponse;
    }
    return AuthSession(
      accessToken: token,
      backendOrigin: origin,
      expiresAt: expiresAt.toUtc(),
      tokenId: _id(json, 'token_id'),
      userId: _id(json, 'user_id'),
      posSessionId: _id(json, 'pos_session_id'),
      posConfigId: _id(json, 'pos_config_id'),
      companyId: _id(json, 'company_id'),
      employeeId: employee is int ? employee : employeeId,
    );
  }

  static int _id(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! int || value <= 0) throw invalidResponse;
    return value;
  }

  static String encode(AuthSession session) => jsonEncode({
    'access_token': session.accessToken,
    'token_type': 'Bearer',
    'backend_url': session.backendOrigin.toString(),
    'expires_at': session.expiresAt.toIso8601String(),
    'token_id': session.tokenId,
    'user_id': session.userId,
    'pos_session_id': session.posSessionId,
    'pos_config_id': session.posConfigId,
    'company_id': session.companyId,
    'employee_id': session.employeeId,
  });

  static AuthSession decode(String value, ApiConfiguration configuration) {
    final json = jsonDecode(value);
    if (json is! Map<String, dynamic> || json['backend_url'] is! String) {
      throw invalidResponse;
    }
    final origin = configuration.validateOrigin(json['backend_url'] as String);
    return fromResult(json, origin);
  }
}
