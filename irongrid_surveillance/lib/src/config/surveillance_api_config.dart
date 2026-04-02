class SurveillanceApiConfig {
  static const String configuredBaseUrl = String.fromEnvironment(
    'SURVEILLANCE_API_BASE_URL',
    defaultValue: 'http://192.168.1.139:8081',
  );

  static String _activeBaseUrl = configuredBaseUrl;

  static String get baseUrl => _activeBaseUrl;

  static void setActiveBaseUrl(String rawUrl) {
    final normalized = _normalizeBaseUrl(rawUrl);
    if (normalized.isNotEmpty) {
      _activeBaseUrl = normalized;
    }
  }

  static List<String> get candidateBaseUrls {
    final candidates = <String>[];

    void addCandidate(String? rawUrl) {
      final normalized = _normalizeBaseUrl(rawUrl);
      if (normalized.isEmpty || candidates.contains(normalized)) {
        return;
      }
      candidates.add(normalized);
    }

    addCandidate(_activeBaseUrl);
    addCandidate(configuredBaseUrl);
    addCandidate('http://127.0.0.1:8081');
    addCandidate('http://127.0.0.1:8080');

    void addVariants(String source) {
      final uri = Uri.tryParse(source);
      if (uri == null || uri.host.isEmpty) {
        return;
      }

      final scheme = uri.scheme.isEmpty ? 'http' : uri.scheme;
      final ports = <int>{
        if (uri.hasPort) uri.port,
        8081,
        8080,
      };

      for (final port in ports) {
        addCandidate('$scheme://${uri.host}:$port');
      }
    }

    addVariants(_activeBaseUrl);
    addVariants(configuredBaseUrl);

    return candidates;
  }

  static String _normalizeBaseUrl(String? rawUrl) {
    final clean = (rawUrl ?? '').trim();
    if (clean.isEmpty) {
      return '';
    }
    return clean.endsWith('/') ? clean.substring(0, clean.length - 1) : clean;
  }
}
