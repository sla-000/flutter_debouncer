import 'package:flutter/widgets.dart';

import 'debouncer_handler.dart';

typedef TapDebouncerFunc = Future<void> Function();

/// Debouncer wrapper widget
class TapDebouncer extends StatefulWidget {
  const TapDebouncer({
    Key key,
    @required this.builder,
    @required this.onTap,
    this.cooldown,
  }) : super(key: key);

  /// Pass this time to constructor if want to allow only one tap and
  /// then disable button forever
  static const Duration kNeverCooldown = Duration(days: 100000000);

  /// Builder function
  /// context is current context
  /// onTap is function to pass to XxxxButton or InkWell
  final Widget Function(
    BuildContext context,
    TapDebouncerFunc onTap,
  ) builder;

  /// Function to call on tap
  final Future<void> Function() onTap;

  /// Cooldown duration - delay after onTap executed (successfully or not)
  final Duration cooldown;

  @override
  _TapDebouncerState createState() => _TapDebouncerState();
}

class _TapDebouncerState extends State<TapDebouncer> {
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
              () async {
                await _tapDebouncerHandler.onTap(widget.onTap);

                if (widget.cooldown != null) {
                  await Future<void>.delayed(widget.cooldown);
                }
              },
            );
          }

          return widget.builder(context, null);
        });
  }
}
