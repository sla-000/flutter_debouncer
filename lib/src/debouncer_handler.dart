import 'tap_debouncer_handler.dart';

/// Debouncer processor
class DebouncerHandler {
  DebouncerHandler({
    Duration onTapCooldown,
  }) : _tapDebouncer = TapDebouncerHandler(
            onTapCooldown: onTapCooldown ?? const Duration(milliseconds: 800));

  final TapDebouncerHandler _tapDebouncer;

  /// Process onTap
  /// Passed onTap function will be executed if debounce time is passed
  bool onTap(void Function() onTap) {
    return _tapDebouncer.onTap(onTap);
  }

  /// Dispose resources
  void dispose() {
    _tapDebouncer.dispose();
  }
}
