import 'dart:async';

import 'package:rxdart/rxdart.dart';

/// Single tap debouncer
class TapDebouncerHandler {
  /// Pass this time to constructor if want to allow only one tap and
  /// then disable button forever
  static const Duration kNeverCooldown = Duration(days: 1000000000);

  final BehaviorSubject<bool> _busySubject =
      BehaviorSubject<bool>.seeded(false);

  /// State stream
  Stream<void> get busy => _busySubject.stream;

  /// Dispose resources
  void dispose() {
    _busySubject.close();
  }

  /// Process onTap
  /// returns true if tap is processed and false if skipped
  Future<void> onTap(Future<void> Function() onTap) async {
    try {
      if (!_busySubject.isClosed) {
        _busySubject.add(true);
      }

      await onTap();
    } on Exception catch (_) {
      rethrow;
    } finally {
      if (!_busySubject.isClosed) {
        _busySubject.add(false);
      }
    }
  }
}
