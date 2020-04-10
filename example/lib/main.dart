import 'package:flutter/material.dart';
import 'package:tap_debouncer/tap_debouncer.dart';

const int kCooldownLong_ms = 3000;
const int kCooldownShort_ms = 1200;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
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
            child: TapDebouncer(
              cooldown: const Duration(milliseconds: kCooldownShort_ms),
              onTap: () async {
                _startCooldownIndicator(kCooldownShort_ms);

                _incrementCounter();
              },
              builder: (BuildContext context, TapDebouncerFunc onTap) {
                return RaisedButton(
                  color: Colors.blue,
                  disabledColor: Colors.grey,
                  onPressed: onTap,
                  child: const Text('Short'),
                );
              },
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: TapDebouncer(
              onTap: () async {
                _startCooldownIndicator(kCooldownLong_ms);

                _incrementCounter();

                await Future<void>.delayed(
                  const Duration(milliseconds: kCooldownLong_ms),
                );
              },
              builder: (BuildContext context, TapDebouncerFunc onTap) {
                return RaisedButton(
                  color: Colors.green,
                  disabledColor: Colors.grey,
                  onPressed: onTap,
                  child: const Text('Long'),
                );
              },
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: TapDebouncer(
              onTap: () async {
                _incrementCounter();

                await Future<void>.delayed(TapDebouncer.kNeverCooldown);
              },
              builder: (BuildContext context, TapDebouncerFunc onTap) {
                return RaisedButton(
                  color: Colors.pink,
                  disabledColor: Colors.grey,
                  onPressed: onTap,
                  child: const Text('OneShot'),
                );
              },
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: TapDebouncer(
              cooldown: const Duration(milliseconds: kCooldownShort_ms),
              onTap: () async {
                _startCooldownIndicator(kCooldownShort_ms * 2);

                await Future<void>.delayed(
                  const Duration(milliseconds: kCooldownShort_ms),
                );

                try {
                  throw Exception('Some error');
                } on Exception catch (error) {
                  debugPrint('Caught $error');
                }
              },
              builder: (BuildContext context, TapDebouncerFunc onTap) {
                return RaisedButton(
                  color: Colors.red,
                  disabledColor: Colors.grey,
                  onPressed: onTap,
                  child: const Text('Faulty'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _startCooldownIndicator(int time_ms) {
    _cooldownStarted = DateTime.now().millisecondsSinceEpoch;
    _updateCooldown(time_ms);
  }

  void _updateCooldown(int time_ms) {
    final int current = DateTime.now().millisecondsSinceEpoch;
    int delta = current - _cooldownStarted;
    if (delta > time_ms) {
      delta = time_ms;
    }

    setState(() {
      _cooldown = delta.roundToDouble() / time_ms;
    });

    Future<void>(() {
      if (delta < time_ms) {
        _updateCooldown(time_ms);
      } else {
        setState(() {
          _cooldown = 0.0;
        });
      }
    });
  }
}
