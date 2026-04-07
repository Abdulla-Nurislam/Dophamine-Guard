import 'package:flutter/foundation.dart';

class AppLimitData {
  final int instagramLimit;
  final int tiktokLimit;
  final int youtubeLimit;

  const AppLimitData({
    this.instagramLimit = 90,
    this.tiktokLimit = 60,
    this.youtubeLimit = 120,
  });
}

class AppState {
  // 'none', 'premium', 'lifetime'
  static final ValueNotifier<String> subscription = ValueNotifier<String>('none');

  static bool get isPremium => subscription.value == 'premium' || subscription.value == 'lifetime';
  static bool get isLifetime => subscription.value == 'lifetime';

  // User data – populated on login / register
  static final ValueNotifier<String> userName  = ValueNotifier<String>('');
  static final ValueNotifier<String> userEmail = ValueNotifier<String>('');

  // App limits – shared between dashboard and change_limit_screen
  static final ValueNotifier<AppLimitData> appLimits = ValueNotifier<AppLimitData>(
    const AppLimitData(),
  );
}
