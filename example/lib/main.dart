import 'package:debouncer/debouncer.dart';
import 'package:flutter/material.dart';

const int kCooldown_ms = 1200;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _counterTaps = 0;
  double _cooldown = 0;
  int _cooldownStarted = DateTime.now().millisecondsSinceEpoch;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'You have pushed the debounced button this many times:',
                ),
                Text(
                  '$_counterTaps',
                  style: Theme.of(context).textTheme.display1,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Tap detected by debounced button this many times:',
                ),
                Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.display1,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Cooldown:',
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: LinearProgressIndicator(value: _cooldown),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Debouncer(
              onTapCooldown: const Duration(milliseconds: kCooldown_ms),
              builder: (BuildContext context, DebouncerHandler debouncer) {
                return FloatingActionButton(
                  onPressed: () {
                    final bool processed = debouncer.onTap(_incrementCounter);
                    debugPrint('processed=$processed');

                    _startCooldownIndicator();

                    _updateCounterTaps();
                  },
                  tooltip: 'DebouncerWidget',
                  child: Icon(Icons.add),
                );
              },
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: TapDebouncer(
              onTap: () {
                _incrementCounter();

                _startCooldownIndicator();

                _updateCounterTaps();
              },
              onTapCooldown: const Duration(milliseconds: kCooldown_ms),
              builder: (BuildContext context, void Function() onTap) {
                return FloatingActionButton(
                  backgroundColor: Colors.green,
                  onPressed: onTap,
                  tooltip: 'TapDebouncerWidget',
                  child: Icon(Icons.add),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _updateCounterTaps() {
    setState(() {
      ++_counterTaps;
    });
  }

  void _startCooldownIndicator() {
    _cooldownStarted = DateTime.now().millisecondsSinceEpoch;
    _processCooldown();
  }

  void _processCooldown() {
    final int current = DateTime.now().millisecondsSinceEpoch;
    int delta = current - _cooldownStarted;
    if (delta > kCooldown_ms) {
      delta = kCooldown_ms;
    }

    setState(() {
      _cooldown = delta.roundToDouble() / kCooldown_ms;
    });

    Future<void>(() {
      if (delta < kCooldown_ms) {
        _processCooldown();
      } else {
        setState(() {
          _cooldown = 0.0;
        });
      }
    });
  }
}
