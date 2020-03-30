import 'package:flutter/widgets.dart';

import 'tap_debouncer_handler.dart';

/// Debouncer wrapper widget
class TapDebouncer extends StatefulWidget {
  const TapDebouncer({
    Key key,
    @required this.builder,
    this.onTapCooldown,
    @required this.onTap,
  }) : super(key: key);

  /// Builder function
  /// context is current context
  /// debouncer is Debouncer instance that you can use to debounce in your
  /// inner widgets
  final Widget Function(
    BuildContext context,
    void Function() onTap,
  ) builder;

  /// Single tap cooldown
  final Duration onTapCooldown;
  final void Function() onTap;

  @override
  _DebouncerState createState() => _DebouncerState();
}

class _DebouncerState extends State<TapDebouncer> {
  TapDebouncerHandler _tapDebouncerHandler;

  @override
  void initState() {
    super.initState();

    _tapDebouncerHandler =
        TapDebouncerHandler(onTapCooldown: widget.onTapCooldown);
  }

  @override
  void didUpdateWidget(TapDebouncer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.onTapCooldown != oldWidget.onTapCooldown) {
      _tapDebouncerHandler =
          TapDebouncerHandler(onTapCooldown: widget.onTapCooldown);
    }
  }

  @override
  void dispose() {
    _tapDebouncerHandler.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TapDebounceState>(
        stream: _tapDebouncerHandler.state,
        builder:
            (BuildContext context, AsyncSnapshot<TapDebounceState> snapshot) {
          if (snapshot.hasError) {
            throw StateError('TapDebounceState has error=${snapshot.error}');
          }

          if (snapshot.hasData && snapshot.data == TapDebounceState.waitTap) {
            return widget.builder(
              context,
              () => _tapDebouncerHandler.onTap(widget.onTap),
            );
          }

          return widget.builder(context, null);
        });
  }
}
