import 'dart:io';

import 'package:flutter/services.dart';

class NativePlatformService {
  static const platform = MethodChannel('com.tarurinfotech.reducer/native');

  Future<int?> getWifiSignalStrength() async {
    if (!Platform.isAndroid) return null;
    try {
      final int result = await platform.invokeMethod('getSignalStrength');
      return result;
    } on PlatformException catch (_) {
      return null;
    }
  }
}
