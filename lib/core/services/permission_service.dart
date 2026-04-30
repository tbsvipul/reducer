import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Centralized permission helper to avoid repeated prompts and
/// provide consistent UX for camera/photo access.
class PermissionService {
  PermissionService._();
  static final PermissionService instance = PermissionService._();

  // Session cache to avoid re-requesting once granted.
  bool _cameraGranted = false;
  bool _photosGranted = false;
  bool _isRequestingCamera = false;
  bool _isRequestingPhotos = false;

  Future<bool> ensureCameraPermission(BuildContext context) async {
    if (_isRequestingCamera) return false;
    _isRequestingCamera = true;
    try {
      if (_cameraGranted) return true;

      var status = await Permission.camera.status;
      if (status.isGranted) {
        _cameraGranted = true;
        return true;
      }
      if (status.isPermanentlyDenied) {
        if (context.mounted) {
          _showSettingsSnack(
            context,
            'Camera access is blocked. Enable it in Settings.',
          );
        }
        return false;
      }

      status = await Permission.camera.request();
      if (status.isGranted) {
        _cameraGranted = true;
        return true;
      }
      if (status.isPermanentlyDenied) {
        if (context.mounted) {
          _showSettingsSnack(
            context,
            'Camera access is blocked. Enable it in Settings.',
          );
        }
      }
      return false;
    } finally {
      _isRequestingCamera = false;
    }
  }

  Future<bool> ensurePhotosPermission(BuildContext context) async {
    if (_isRequestingPhotos) return false;
    _isRequestingPhotos = true;
    try {
      if (_photosGranted) return true;

      final permissions = _photoPermissions();

      for (final permission in permissions) {
        final status = await permission.status;
        if (status.isGranted || status.isLimited) {
          _photosGranted = true;
          return true;
        }
        if (status.isPermanentlyDenied) {
          if (context.mounted) {
            _showSettingsSnack(
              context,
              'Photo access is blocked. Enable it in Settings.',
            );
          }
          return false;
        }
      }

      for (final permission in permissions) {
        final status = await permission.request();
        if (status.isGranted || status.isLimited) {
          _photosGranted = true;
          return true;
        }
        if (status.isPermanentlyDenied) {
          if (context.mounted) {
            _showSettingsSnack(
              context,
              'Photo access is blocked. Enable it in Settings.',
            );
          }
          return false;
        }
      }

      final blocked = await Future.wait(
        permissions.map((permission) => permission.isPermanentlyDenied),
      );
      if (blocked.any((isBlocked) => isBlocked)) {
        if (context.mounted) {
          _showSettingsSnack(
            context,
            'Photo access is blocked. Enable it in Settings.',
          );
        }
      }
      return false;
    } finally {
      _isRequestingPhotos = false;
    }
  }

  List<Permission> _photoPermissions() {
    if (Platform.isIOS) {
      return [Permission.photos];
    }
    if (Platform.isAndroid) {
      // Android 13+ uses photos; older versions still use storage.
      return [Permission.photos, Permission.storage];
    }
    return [Permission.storage];
  }

  void _showSettingsSnack(BuildContext context, String message) {
    debugPrint('PERMISSION ERROR: $message');
  }
}

