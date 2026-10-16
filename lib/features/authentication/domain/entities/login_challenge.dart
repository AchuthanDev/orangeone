class LoginChallenge {
  const new({
    required this.challenge,
    required this.nonce,
    required this.posSessionId,
    required this.posConfigId,
    required this.backendOrigin,
    required this.expiresAt,
  });

  final String challenge;
  final String nonce;
  final int posSessionId;
  final int posConfigId;
  final Uri backendOrigin;
  final DateTime expiresAt;

  @override
  String toString() => 'LoginChallenge(redacted)';
}
