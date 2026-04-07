import 'package:flutter/foundation.dart';

class AppState {
  // 'none', 'premium', 'lifetime'
  static final ValueNotifier<String> subscription = ValueNotifier<String>('none');

  static bool get isPremium => subscription.value == 'premium' || subscription.value == 'lifetime';
  static bool get isLifetime => subscription.value == 'lifetime';

  // User data – populated on login / register
  static final ValueNotifier<String> userName  = ValueNotifier<String>('');
  static final ValueNotifier<String> userEmail = ValueNotifier<String>('');
}
