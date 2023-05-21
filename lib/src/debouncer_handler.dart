import 'dart:async';

/// Single tap debouncer
class DebouncerHandler {
  DebouncerHandler() : _busyController = StreamController<bool>()..add(false);

  final StreamController<bool> _busyController;

  /// Busy state stream
  Stream<bool> get busyStream => _busyController.stream;

  /// Dispose resources
  void dispose() => unawaited(_busyController.close());

  /// Process onTap function
  Future<void> onTap(Future<void> Function() function) async {
    try {
      _add(true);

      await function();
    } finally {
      _add(false);
    }
  }

  void _add(bool value) {
    if (!_busyController.isClosed) {
      _busyController.add(value);
    }
  }
}
