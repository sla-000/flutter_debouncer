import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

enum TapDebounceState {
  waitTap,
  waitCooldown,
}

/// Single tap debouncer
class TapDebouncerHandler {
  TapDebouncerHandler({
    @required this.onTapCooldown,
  });

  /// Pass this time to constructor if want to allow only one tap and
  /// then disable button forever
  static const Duration kNeverCooldown = Duration(days: 1000000000);

  /// Next tap will be disabled before this time from previous tap ends
  Duration onTapCooldown;
  Timer _timer;
  final BehaviorSubject<TapDebounceState> _stateSubject =
      BehaviorSubject<TapDebounceState>.seeded(TapDebounceState.waitTap);

  /// State stream
  Stream<TapDebounceState> get state => _stateSubject.stream;

  /// Dispose resources
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
    }

    _stateSubject.close();
  }

  /// Process onTap
  /// returns true if tap is processed and false if skipped
  bool onTap(void Function() onTap) {
    bool pressed = false;

    switch (_stateSubject.value) {
      case TapDebounceState.waitTap:
        if (_timer == null) {
          onTap();
          pressed = true;

          _timer = Timer(onTapCooldown, _onTimer);
        }

        if (!_stateSubject.isClosed) {
          _stateSubject.add(TapDebounceState.waitCooldown);
        }
        break;

      case TapDebounceState.waitCooldown:
        _timer.cancel();
        _timer = Timer(onTapCooldown, _onTimer);
        break;
    }

    return pressed;
  }

  void _onTimer() {
    _timer = null;
    if (!_stateSubject.isClosed) {
      _stateSubject.add(TapDebounceState.waitTap);
    }
  }
}
