import 'package:flutter/widgets.dart';

import 'debouncer_handler.dart';

/// Debouncer wrapper widget
class Debouncer extends StatefulWidget {
  const Debouncer({
    Key key,
    @required this.builder,
    this.onTapCooldown,
  }) : super(key: key);

  /// Builder function
  /// context is current context
  /// debouncer is Debouncer instance that you can use to debounce in your
  /// inner widgets
  final Widget Function(
    BuildContext context,
    DebouncerHandler debouncer,
  ) builder;

  /// Single tap cooldown
  final Duration onTapCooldown;

  @override
  _DebouncerState createState() => _DebouncerState();
}

class _DebouncerState extends State<Debouncer> {
  DebouncerHandler _debouncerHandler;

  @override
  void initState() {
    super.initState();

    _debouncerHandler = DebouncerHandler(onTapCooldown: widget.onTapCooldown);
  }

  @override
  void didUpdateWidget(Debouncer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.onTapCooldown != oldWidget.onTapCooldown) {
      _debouncerHandler = DebouncerHandler(onTapCooldown: widget.onTapCooldown);
    }
  }

  @override
  void dispose() {
    _debouncerHandler.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _debouncerHandler);
  }
}
