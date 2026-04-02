import 'package:flutter/foundation.dart';

class ManagerBadgeStore {
  static final ValueNotifier<int> unreadAlerts = ValueNotifier<int>(0);

  /// Nombre total de messages non lus côté manager.
  static final ValueNotifier<int> unreadMessages = ValueNotifier<int>(0);

  static void setUnreadAlerts(int value) {
    unreadAlerts.value = value < 0 ? 0 : value;
  }

  static void setUnreadMessages(int value) {
    unreadMessages.value = value < 0 ? 0 : value;
  }

  /// Recalcule le badge à partir d'une liste de conversations.
  /// Chaque conversation doit idéalement exposer `unreadCount`.
  /// Si `unreadCount` n'existe pas, on retombe sur `hasUnread`.
  static void setUnreadMessagesFromConversations(List<dynamic> conversations) {
    int total = 0;

    for (final conversation in conversations) {
      try {
        final dynamic c = conversation;

        try {
          final unreadCount = c.unreadCount;
          if (unreadCount is int) {
            total += unreadCount;
            continue;
          }
          total += int.tryParse(unreadCount.toString()) ?? 0;
          continue;
        } catch (_) {
          // continue to fallback
        }

        try {
          final hasUnread = c.hasUnread == true;
          if (hasUnread) {
            total += 1;
          }
        } catch (_) {
          // ignore malformed item
        }
      } catch (_) {
        // ignore malformed item
      }
    }

    unreadMessages.value = total < 0 ? 0 : total;
  }

  static void clear() {
    unreadAlerts.value = 0;
    unreadMessages.value = 0;
  }
}