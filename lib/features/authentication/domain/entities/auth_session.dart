class AuthSession {
  const new({
    required this.accessToken,
    required this.backendOrigin,
    required this.expiresAt,
    required this.tokenId,
    required this.userId,
    required this.posSessionId,
    required this.posConfigId,
    required this.companyId,
    this.employeeId,
  });

  final String accessToken;
  final Uri backendOrigin;
  final DateTime expiresAt;
  final int tokenId;
  final int userId;
  final int posSessionId;
  final int posConfigId;
  final int companyId;
  final int? employeeId;

  bool isExpired(DateTime now) => !expiresAt.isAfter(now);

  @override
  String toString() => 'AuthSession(redacted)';
}
