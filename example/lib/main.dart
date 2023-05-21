import 'package:flutter/material.dart';
import 'package:tap_debouncer/tap_debouncer.dart';

const int kCooldownLongMs = 3000;
const int kCooldownShortMs = 1200;

const double kButtonSize = 100;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
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
  Widget build(BuildContext context) => Scaffold(
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
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  const Text('Cooldown:'),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: LinearProgressIndicator(value: _cooldown),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: SizedBox(
                width: kButtonSize,
                height: kButtonSize,
                child: TapDebouncer(
                  cooldown: const Duration(milliseconds: kCooldownShortMs),
                  onTap: () async {
                    _startCooldownIndicator(kCooldownShortMs);

                    _incrementCounter();
                  },
                  builder: (_, TapDebouncerFunc? onTap) => ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: onTap,
                    // alternative with manual test onTap for null in builder
                    child: onTap == null
                        ? const Text('Wait...')
                        : const Text('Short'),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: SizedBox(
                width: kButtonSize,
                height: kButtonSize,
                child: TapDebouncer(
                  onTap: () async {
                    _startCooldownIndicator(kCooldownLongMs);

                    _incrementCounter();

                    await Future<void>.delayed(
                      const Duration(milliseconds: kCooldownLongMs),
                    );
                  },
                  builder: (_, TapDebouncerFunc? onTap) => ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: onTap,
                    child: const Center(child: Text('Long')),
                  ),
                  // alternative with using waitBuilder
                  // instead of test onTap for null
                  waitBuilder: (_, Widget child) => Stack(
                    children: <Widget>[
                      child,
                      const Center(child: CircularProgressIndicator()),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: SizedBox(
                width: kButtonSize,
                height: kButtonSize,
                child: TapDebouncer(
                  cooldown: TapDebouncer.kNeverCooldown,
                  onTap: () async {
                    _incrementCounter();
                  },
                  builder: (_, TapDebouncerFunc? onTap) => ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                    onPressed: onTap,
                    child: const Text('OneShot'),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: Builder(
                // Builder is needed just to get context for showSnackBar
                builder: (BuildContext context) => SizedBox(
                  width: kButtonSize,
                  height: kButtonSize,
                  child: TapDebouncer(
                    cooldown: const Duration(milliseconds: kCooldownShortMs),
                    onTap: () async {
                      _startCooldownIndicator(kCooldownShortMs * 2);

                      await Future<void>.delayed(
                        const Duration(milliseconds: kCooldownShortMs),
                      );

                      try {
                        throw Exception('Some error');
                      } on Exception catch (error) {
                        if (!mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red.withAlpha(0x80),
                            content: Text('Caught $error'),
                            duration: const Duration(milliseconds: 500),
                          ),
                        );
                      }
                    },
                    builder: (_, TapDebouncerFunc? onTap) => ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: onTap,
                      child: Center(
                        child: onTap == null
                            ? const Text('Wait\nfail...')
                            : const Text('Faulty'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 100,
              right: 100,
              child: Center(
                child: SizedBox(
                  width: kButtonSize,
                  height: kButtonSize,
                  child: TapDebouncer(
                    builder: (_, TapDebouncerFunc? onTap) => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black26,
                      ),
                      onPressed: onTap,
                      child: const Text('Null'),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  void _startCooldownIndicator(int timeMs) {
    _cooldownStarted = DateTime.now().millisecondsSinceEpoch;
    _updateCooldown(timeMs);
  }

  void _updateCooldown(int timeMs) {
    final current = DateTime.now().millisecondsSinceEpoch;
    var delta = current - _cooldownStarted;
    if (delta > timeMs) {
      delta = timeMs;
    }

    setState(() {
      _cooldown = delta.roundToDouble() / timeMs;
    });

    Future<void>(() {
      if (delta < timeMs) {
        _updateCooldown(timeMs);
      } else {
        setState(() {
          _cooldown = 0.0;
        });
      }
    });
  }
}
