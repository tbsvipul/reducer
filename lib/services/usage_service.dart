import 'package:shared_preferences/shared_preferences.dart';
import '../ads/remote_config_service.dart';
import '../providers/premium_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UsageService {
  static const String _usageKey = 'daily_usage_count';
  static const String _dateKey = 'usage_date';

  static Future<bool> canUseFeature(bool isPremium) async {
    if (isPremium) return true;

    // Check if free use is enabled from Remote Config
    final freeUse = RemoteConfigService().getInt(RemoteConfigService.freeUse);
    if (freeUse == 1) return true;

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = prefs.getString(_dateKey);

    if (lastDate != today) {
      // New day, reset counter
      await prefs.setString(_dateKey, today);
      await prefs.setInt(_usageKey, 0);
      return true;
    }

    final usageCount = prefs.getInt(_usageKey) ?? 0;
    final limit = RemoteConfigService().getInt(RemoteConfigService.perDayCall);

    return usageCount < limit;
  }

  static Future<void> incrementUsage(bool isPremium) async {
    if (isPremium) return;

    final prefs = await SharedPreferences.getInstance();
    final usageCount = prefs.getInt(_usageKey) ?? 0;
    await prefs.setInt(_usageKey, usageCount + 1);
  }

  static Future<int> getRemainingUsage(bool isPremium) async {
    if (isPremium) return -1; // -1 means unlimited

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = prefs.getString(_dateKey);
    
    if (lastDate != today) return RemoteConfigService().getInt(RemoteConfigService.perDayCall);

    final usageCount = prefs.getInt(_usageKey) ?? 0;
    final limit = RemoteConfigService().getInt(RemoteConfigService.perDayCall);
    return (limit - usageCount).clamp(0, limit);
  }
}
