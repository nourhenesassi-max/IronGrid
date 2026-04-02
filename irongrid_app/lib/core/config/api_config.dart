class ApiConfig {
  // IP du PC sur le réseau local pour les tests sur téléphone physique.
  // Override possible:
  // flutter run --dart-define=API_BASE_URL=http://192.168.1.xxx:8081
  static const String configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
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

    void addCandidate(String? value) {
      final normalized = _normalizeBaseUrl(value);
      if (normalized.isEmpty || candidates.contains(normalized)) {
        return;
      }
      candidates.add(normalized);
    }

    addCandidate(_activeBaseUrl);
    addCandidate('http://127.0.0.1:8081');
    addCandidate('http://127.0.0.1:8080');
    addCandidate(configuredBaseUrl);

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

  static String resolveUrl(String rawUrl) {
    var clean = rawUrl.trim().replaceAll('\\', '/');
    if (clean.isEmpty) {
      return clean;
    }

    final uploadsIndex = clean.toLowerCase().indexOf('/uploads/');
    if (uploadsIndex >= 0) {
      clean = clean.substring(uploadsIndex);
    } else {
      final uploadsNoSlashIndex = clean.toLowerCase().indexOf('uploads/');
      if (uploadsNoSlashIndex >= 0) {
        clean = '/${clean.substring(uploadsNoSlashIndex)}';
      }
    }

    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      final uri = Uri.parse(clean);
      const localHosts = {'localhost', '127.0.0.1', '10.0.2.2'};

      if (!localHosts.contains(uri.host)) {
        return clean;
      }

      final baseUri = Uri.parse(baseUrl);
      return uri
          .replace(
            scheme: baseUri.scheme,
            host: baseUri.host,
            port: baseUri.hasPort ? baseUri.port : null,
          )
          .toString();
    }

    if (clean.startsWith('/')) {
      return '$baseUrl$clean';
    }

    return '$baseUrl/$clean';
  }
}
