import 'package:orange_one/features/authentication/domain/entities/auth_session.dart';

abstract interface class AuthRepository {
  Future<AuthSession?> restore();
  Future<AuthSession> signIn(String qrPayload);
  Future<void> signOut();
}
