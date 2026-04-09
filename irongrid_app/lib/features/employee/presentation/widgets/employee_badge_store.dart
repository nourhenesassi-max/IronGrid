import 'package:flutter/foundation.dart';

class EmployeeBadgeStore {
  static final ValueNotifier<int> unreadMessages = ValueNotifier<int>(0);

  static void setUnreadMessages(int value) {
    unreadMessages.value = value < 0 ? 0 : value;
  }

  static void clear() {
    unreadMessages.value = 0;
  }
}