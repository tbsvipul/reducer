import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:reducer/core/services/remote_config_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateService {
  static final ForceUpdateService _instance = ForceUpdateService._internal();
  factory ForceUpdateService() => _instance;
  ForceUpdateService._internal();

  bool _isShowingDialog = false;

  Future<void> checkAndEnforce(BuildContext context) async {
    if (_isShowingDialog) return;

    final config = RemoteConfigService();

    // 1. Check Maintenance Mode
    if (config.maintenanceMode) {
      _isShowingDialog = true;
      _showMaintenanceScreen(context);
      return;
    }

    // 2. Check Force Update
    if (config.forceUpdateEnabled) {
      final packageInfo = await PackageInfo.fromPlatform();
      if (!context.mounted) return;
      final currentVersion = packageInfo.version;
      final minVersion = config.forceUpdateMinVersion;

      if (_isVersionOlder(currentVersion, minVersion)) {
        _isShowingDialog = true;
        _showUpdateDialog(context, config.appStoreUrl);
      }
    }
  }

  bool _isVersionOlder(String current, String target) {
    List<int> parse(String v) => v
        .split('.')
        .map((e) => int.tryParse(e.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        .toList();

    final List<int> currentParts = parse(current);
    final List<int> targetParts = parse(target);

    final maxLength = currentParts.length > targetParts.length
        ? currentParts.length
        : targetParts.length;

    for (int i = 0; i < maxLength; i++) {
      final int currentPart = i < currentParts.length ? currentParts[i] : 0;
      final int targetPart = i < targetParts.length ? targetParts[i] : 0;

      if (currentPart < targetPart) return true;
      if (currentPart > targetPart) return false;
    }
    return false;
  }

  void _showMaintenanceScreen(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PopScope(
        canPop: false,
        child: Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.build_circle_outlined,
                    size: 80,
                    color: Colors.blueGrey,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Under Maintenance',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'We are currently performing scheduled maintenance to improve your experience. Please check back later.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, String appStoreUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Update Required'),
          content: const Text(
            'A newer version of Reducer is available. Please update to continue using the app.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final url = Uri.parse(appStoreUrl);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text('Update Now'),
            ),
          ],
        ),
      ),
    );
  }
}
