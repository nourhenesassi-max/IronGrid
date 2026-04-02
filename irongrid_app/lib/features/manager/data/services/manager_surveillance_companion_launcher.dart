import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/storage/secure_store.dart';

class ManagerSurveillanceCompanionLauncher {
  ManagerSurveillanceCompanionLauncher._();

  static Future<void> open(BuildContext context) async {
    final token = await SecureStore.readToken();
    if (token == null || token.trim().isEmpty) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La session manager est introuvable. Reconnecte-toi puis reessaie.',
          ),
        ),
      );
      return;
    }

    final companionUri = Uri(
      scheme: 'irongridsurveillance',
      host: 'wall',
      queryParameters: <String, String>{
        'token': token,
        'baseUrl': ApiConfig.baseUrl,
      },
    );

    try {
      final opened = await launchUrl(
        companionUri,
        mode: LaunchMode.externalApplication,
      );

      if (opened) {
        return;
      }
    } catch (_) {
      // Fall through to the info message below.
    }

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Installe d abord IronGrid Surveillance pour ouvrir le mur video dedie.',
        ),
      ),
    );
  }
}
