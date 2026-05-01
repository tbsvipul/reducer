import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class ExifCreditState {
  final int availableCredits;
  final bool isLoading;

  const ExifCreditState({this.availableCredits = 2, this.isLoading = true});

  ExifCreditState copyWith({int? availableCredits, bool? isLoading}) {
    return ExifCreditState(
      availableCredits: availableCredits ?? this.availableCredits,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final exifCreditProvider =
    StateNotifierProvider<ExifCreditController, ExifCreditState>((ref) {
      return ExifCreditController();
    });

class ExifCreditController extends StateNotifier<ExifCreditState> {
  static const _storageKey = 'exif_eraser_credits_v1';
  static const _secureStorage = FlutterSecureStorage();

  ExifCreditController() : super(const ExifCreditState()) {
    _loadCredits();
  }

  Future<void> _loadCredits() async {
    try {
      final storedValue = await _secureStorage.read(key: _storageKey);
      if (storedValue == null) {
        // First time user: 2 credits
        await _secureStorage.write(key: _storageKey, value: '2');
        state = state.copyWith(availableCredits: 2, isLoading: false);
      } else {
        state = state.copyWith(
          availableCredits: int.tryParse(storedValue) ?? 0,
          isLoading: false,
        );
      }
    } catch (e) {
      debugPrint('[Security] Failed to load EXIF credits: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> useCredit() async {
    if (state.availableCredits <= 0) return;

    final newVal = state.availableCredits - 1;
    state = state.copyWith(availableCredits: newVal);

    try {
      await _secureStorage.write(key: _storageKey, value: newVal.toString());
    } catch (e) {
      debugPrint('[Security] Failed to save EXIF credit consumption: $e');
    }
  }

  Future<void> resetForPro() async {
    // If user becomes Pro, we might want to reset their credits to full for when they downgrade,
    // though usually isPro check happens first in the UI.
    state = state.copyWith(availableCredits: 2);
    await _secureStorage.write(key: _storageKey, value: '2');
  }
}
