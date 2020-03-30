import 'package:flutter/widgets.dart';

import 'tap_debouncer_handler.dart';

/// Debouncer wrapper widget
class TapDebouncer extends StatefulWidget {
  const TapDebouncer({
    Key key,
    @required this.builder,
    @required this.onTap,
  }) : super(key: key);

  /// Builder function
  /// context is current context
  /// debouncer is Debouncer instance that you can use to debounce in your
  /// inner widgets
  final Widget Function(
    BuildContext context,
    Future<void> Function() onTap,
  ) builder;

  final Future<void> Function() onTap;

  @override
  _DebouncerState createState() => _DebouncerState();
}

class _DebouncerState extends State<TapDebouncer> {
  TapDebouncerHandler _tapDebouncerHandler;

  @override
  void initState() {
    super.initState();

    _tapDebouncerHandler = TapDebouncerHandler();
  }

  @override
  void dispose() {
    _tapDebouncerHandler.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: _tapDebouncerHandler.busy,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasError) {
            throw StateError(
                '_tapDebouncerHandler.busy has error=${snapshot.error}');
          }

          if (snapshot.hasData && snapshot.data == false) {
            return widget.builder(
              context,
              () async => await _tapDebouncerHandler.onTap(widget.onTap),
            );
          }

          return widget.builder(context, null);
        });
  }
}
