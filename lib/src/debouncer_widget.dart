import 'package:flutter/widgets.dart';
import 'package:tap_debouncer/src/debouncer_handler.dart';

typedef TapDebouncerFunc = Future<void> Function();

/// Tap debouncer widget
class TapDebouncer extends StatefulWidget {
  const TapDebouncer({
    super.key,
    required this.builder,
    this.waitBuilder,
    this.onTap,
    this.cooldown,
  });

  /// Pass this time to constructor if want to allow only one tap and
  /// then disable button forever
  static const Duration kNeverCooldown = Duration(days: 100000000);

  /// Main button builder function
  /// context is current context
  /// onTap is function to pass to SomeButton or InkWell
  final Widget Function(BuildContext context, TapDebouncerFunc? onTap) builder;

  /// Waiting button builder function
  /// context is current context
  /// child is widget returning from builder method with onTap equal null
  final Widget Function(BuildContext context, Widget child)? waitBuilder;

  /// Function to call on tap
  final Future<void> Function()? onTap;

  /// Cooldown duration - delay after onTap executed (successfully or not)
  final Duration? cooldown;

  @override
  State<TapDebouncer> createState() => _TapDebouncerState();
}

class _TapDebouncerState extends State<TapDebouncer> {
  final DebouncerHandler _tapDebouncerHandler = DebouncerHandler();

  @override
  void dispose() {
    _tapDebouncerHandler.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<bool>(
        initialData: false,
        stream: _tapDebouncerHandler.busyStream,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasError) {
            throw StateError(
              '_tapDebouncerHandler.busy has error=${snapshot.error}',
            );
          }

          final isBusy = snapshot.data!;

          if (!isBusy) {
            return widget.builder(
              context,
              widget.onTap == null
                  ? null
                  : () async {
                      await _tapDebouncerHandler.onTap(
                        () async {
                          await widget.onTap!();

                          if (widget.cooldown != null) {
                            await Future<void>.delayed(widget.cooldown!);
                          }
                        },
                      );
                    },
            );
          }

          final disabledChild = widget.builder(context, null);

          if (widget.waitBuilder == null) {
            return disabledChild;
          } else {
            return widget.waitBuilder!(context, disabledChild);
          }
        },
      );
}
