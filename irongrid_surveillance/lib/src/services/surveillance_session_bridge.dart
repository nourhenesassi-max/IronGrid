import 'dart:async';

import 'package:app_links/app_links.dart';

import '../config/surveillance_api_config.dart';
import '../storage/surveillance_secure_store.dart';

class SurveillanceSessionBridge {
  SurveillanceSessionBridge._();

  static final SurveillanceSessionBridge instance =
      SurveillanceSessionBridge._();

  final AppLinks _appLinks = AppLinks();
  final StreamController<void> _updates = StreamController<void>.broadcast();

  StreamSubscription<Uri>? _linkSubscription;
  bool _initialized = false;

  Stream<void> get updates => _updates.stream;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    final savedBaseUrl = await SurveillanceSecureStore.readApiBaseUrl();
    if (savedBaseUrl != null && savedBaseUrl.trim().isNotEmpty) {
      SurveillanceApiConfig.setActiveBaseUrl(savedBaseUrl);
    }

    final initialLink = await _appLinks.getInitialLink();
    await _consumeLink(initialLink, notify: false);

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) async {
      await _consumeLink(uri, notify: true);
    });
  }

  Future<void> _consumeLink(Uri? uri, {required bool notify}) async {
    if (uri == null || uri.scheme != 'irongridsurveillance') {
      return;
    }

    var changed = false;

    final token = uri.queryParameters['token']?.trim() ?? '';
    if (token.isNotEmpty) {
      await SurveillanceSecureStore.saveToken(token);
      changed = true;
    }

    final baseUrl = uri.queryParameters['baseUrl']?.trim() ?? '';
    if (baseUrl.isNotEmpty) {
      SurveillanceApiConfig.setActiveBaseUrl(baseUrl);
      await SurveillanceSecureStore.saveApiBaseUrl(
        SurveillanceApiConfig.baseUrl,
      );
      changed = true;
    }

    if (notify && changed) {
      _updates.add(null);
    }
  }

  Future<void> dispose() async {
    await _linkSubscription?.cancel();
    await _updates.close();
  }
}
