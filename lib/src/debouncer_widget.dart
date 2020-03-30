import 'package:flutter/widgets.dart';

import 'debouncer_handler.dart';

typedef DebouncerOnTap = Future<void> Function();

/// Debouncer wrapper widget
class Debouncer extends StatefulWidget {
  const Debouncer({
    Key key,
    @required this.builder,
    @required this.onTap,
  }) : super(key: key);

  /// Pass this time to constructor if want to allow only one tap and
  /// then disable button forever
  static const Duration kNeverCooldown = Duration(days: 100000000);

  /// Builder function
  /// context is current context
  /// onTap is Function to call
  final Widget Function(
    BuildContext context,
    DebouncerOnTap onTap,
  ) builder;

  /// Function to call on tap
  final Future<void> Function() onTap;

  @override
  _DebouncerState createState() => _DebouncerState();
}

class _DebouncerState extends State<Debouncer> {
  final DebouncerHandler _tapDebouncerHandler = DebouncerHandler();

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
