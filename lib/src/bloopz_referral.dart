class BloopzReferral {
  BloopzReferral({
    required this.rawReferrer,
    required Map<String, String> params,
  }) : params = Map.unmodifiable(params);

  /// Raw Play Store install referrer string (after URL decoding).
  final String rawReferrer;

  /// Parsed query parameters from [rawReferrer].
  final Map<String, String> params;

  String? get utmSource => params['utm_source'];
  String? get utmMedium => params['utm_medium'];

  bool get isBloopz => utmSource?.toLowerCase() == 'bloopz' && (utmMedium?.isNotEmpty ?? false);
}

