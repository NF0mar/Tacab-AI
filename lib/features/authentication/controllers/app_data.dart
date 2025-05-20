// lib/common/app_data.dart

import 'package:flutter/material.dart';

class AppData {
  static ValueNotifier<int> navbarCurrentIndexNotifier = ValueNotifier(0);
  static ValueNotifier<bool> onboardingPageNotifier = ValueNotifier(true);
}
