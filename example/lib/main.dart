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
                const Text('Tap detected by debounced button this many times:'),
                Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.headline4,
                ),
                const SizedBox(height: 24),
                const Text('Cooldown:'),
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
            child: SizedBox(
              width: 80,
              height: 80,
              child: TapDebouncer(
                cooldown: const Duration(milliseconds: kCooldownShort_ms),
                onTap: () async {
                  _startCooldownIndicator(kCooldownShort_ms);

                  _incrementCounter();
                },
                builder: (BuildContext context, TapDebouncerFunc onTap) {
                  return RaisedButton(
                    color: Colors.blue,
                    onPressed: onTap,
                    // variant with manual test onTap for null in builder
                    child: onTap == null
                        ? const Text('Wait...')
                        : const Text('Short'),
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: SizedBox(
              width: 80,
              height: 80,
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
                    onPressed: onTap,
                    child: const Center(child: Text('Long')),
                  );
                },
                // variant with using waitBuilder instead of test onTap for null
                waitBuilder: (BuildContext context, Widget child) {
                  return Stack(
                    children: <Widget>[
                      child,
                      const Center(child: CircularProgressIndicator()),
                    ],
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: SizedBox(
              width: 80,
              height: 80,
              child: TapDebouncer(
                cooldown: TapDebouncer.kNeverCooldown,
                onTap: () async {
                  _incrementCounter();
                },
                builder: (BuildContext context, TapDebouncerFunc onTap) {
                  return RaisedButton(
                    color: Colors.pink,
                    onPressed: onTap,
                    child: const Text('OneShot'),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Builder(
              // Builder is needed just to get context for showSnackBar
              builder: (BuildContext context) {
                return SizedBox(
                  width: 80,
                  height: 80,
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
                        Scaffold.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.red.withAlpha(0x80),
                          content: Text('Caught $error'),
                          duration: const Duration(milliseconds: 500),
                        ));
                      }
                    },
                    builder: (BuildContext context, TapDebouncerFunc onTap) {
                      return RaisedButton(
                        color: Colors.red,
                        onPressed: onTap,
                        child: Center(
                            child: onTap == null
                                ? const Text('Wait\nfail...')
                                : const Text('Faulty')),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 20,
            left: 100,
            right: 100,
            child: Center(
              child: SizedBox(
                width: 80,
                height: 80,
                child: TapDebouncer(
                  onTap: null,
                  builder: (BuildContext context, TapDebouncerFunc onTap) {
                    return RaisedButton(
                      color: Colors.black26,
                      onPressed: onTap,
                      child: const Text('Null'),
                    );
                  },
                ),
              ),
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
