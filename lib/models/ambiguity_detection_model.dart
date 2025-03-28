class AmbiguityDetectionResult {
  final bool isAmbiguous;
  final double confidenceScore;
  final String ambiguityType;
  final String originalQuery;

  const AmbiguityDetectionResult({
    required this.isAmbiguous,
    required this.confidenceScore,
    required this.ambiguityType,
    required this.originalQuery,
  });
} 