class AuthenticityResult {
  final int authenticityScore;
  final String verdict;
  final bool priceAnomaly;
  final List<String> riskFactors;

  AuthenticityResult({
    required this.authenticityScore,
    required this.verdict,
    required this.priceAnomaly,
    required this.riskFactors,
  });

  factory AuthenticityResult.fromJson(Map<String, dynamic> json) {
    return AuthenticityResult(
      authenticityScore: json['authenticity_score'] ?? 0,
      verdict: json['verdict'] ?? 'Unknown',
      priceAnomaly: json['price_anomaly'] ?? false,
      riskFactors: List<String>.from(json['risk_factors'] ?? []),
    );
  }
}
