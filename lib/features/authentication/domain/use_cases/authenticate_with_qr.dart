import 'package:orange_one/features/authentication/domain/entities/auth_session.dart';
import 'package:orange_one/features/authentication/domain/repositories/auth_repository.dart';

class AuthenticateWithQr {
  const new(this._repository);
  final AuthRepository _repository;

  Future<AuthSession> call(String payload) {
    if (payload.trim().isEmpty || payload.length > 8192) {
      throw const FormatException('Invalid login QR input');
    }
    return _repository.signIn(payload);
  }
}
