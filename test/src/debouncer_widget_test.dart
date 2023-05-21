import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tap_debouncer/src/debouncer_widget.dart';

class _MockOnTap extends Mock {
  Future<void> call();
}

void main() {
  final mockOnTap = _MockOnTap();

  setUp(() {
    when(mockOnTap.call).thenAnswer((_) async {});
  });

  tearDown(() {
    reset(mockOnTap);
  });

  group(
    'TapDebouncer tests - ',
    () {
      group(
        'TapDebouncer basics tests - ',
        () {
          testWidgets(
            'WHEN widget tapped 3 times '
            'THEN should call mockOnTap 3 times',
            (tester) async {
              await tester.pumpWidget(
                _TestWidget(
                  child: TapDebouncer(
                    onTap: mockOnTap.call,
                    builder: (context, onTap) => _TapTarget(onTap: onTap),
                  ),
                ),
              );

              await tester.tap(_findButton);
              await tester.tap(_findButton);
              await tester.tap(_findButton);

              verify(mockOnTap.call).called(3);
            },
          );

          testWidgets(
            'WHEN widget tapped 3 times while waiting for 1st tap complete '
            'THEN should call mockOnTap once',
            (tester) async {
              final busy = Completer<void>();

              when(mockOnTap.call).thenAnswer(
                (_) async => busy.future,
              );

              await tester.pumpWidget(
                _TestWidget(
                  child: TapDebouncer(
                    onTap: mockOnTap.call,
                    builder: (context, onTap) => _TapTarget(onTap: onTap),
                  ),
                ),
              );

              await tester.tap(_findButton);
              await tester.pumpAndSettle();

              await tester.tap(_findButton);
              await tester.pumpAndSettle();

              await tester.tap(_findButton);
              await tester.pumpAndSettle();

              busy.complete();
              await tester.pumpAndSettle();

              verify(mockOnTap.call).called(1);
            },
          );

          testWidgets(
            'WHEN widget tapped once then wait and tapped again '
            'THEN should call mockOnTap twice',
            (tester) async {
              final busy = Completer<void>();

              when(mockOnTap.call).thenAnswer((_) => busy.future);

              await tester.pumpWidget(
                _TestWidget(
                  child: TapDebouncer(
                    onTap: mockOnTap.call,
                    builder: (context, onTap) => _TapTarget(onTap: onTap),
                  ),
                ),
              );

              await tester.tap(_findButton);
              await tester.pumpAndSettle();

              verify(mockOnTap.call).called(1);

              busy.complete();
              await tester.pumpAndSettle();

              await tester.tap(_findButton);
              await tester.pumpAndSettle();

              verify(mockOnTap.call).called(1);
            },
          );
        },
      );

      group(
        'TapDebouncer cooldown tests - ',
        () {
          testWidgets(
            'WHEN there is a cooldown '
            'THEN should ignore taps in that period',
            (tester) async {
              await tester.runAsync(
                () async {
                  await tester.pumpWidget(
                    _TestWidget(
                      child: TapDebouncer(
                        cooldown: const Duration(milliseconds: 250),
                        onTap: mockOnTap.call,
                        builder: (context, onTap) => _TapTarget(onTap: onTap),
                      ),
                    ),
                  );

                  await tester.tap(_findButton);
                  await tester.pumpAndSettle();

                  await Future.delayed(const Duration(milliseconds: 100));

                  await tester.tap(_findButton);
                  await tester.pumpAndSettle();

                  await Future.delayed(const Duration(milliseconds: 100));

                  await tester.tap(_findButton);
                  await tester.pumpAndSettle();

                  verify(mockOnTap.call).called(1);
                },
              );
            },
          );

          testWidgets(
            'WHEN there is a cooldown '
            'THEN should ignore taps in that period and process taps after',
            (tester) async {
              await tester.runAsync(
                () async {
                  await tester.pumpWidget(
                    _TestWidget(
                      child: TapDebouncer(
                        cooldown: const Duration(milliseconds: 100),
                        onTap: mockOnTap.call,
                        builder: (context, onTap) => _TapTarget(onTap: onTap),
                      ),
                    ),
                  );

                  await tester.tap(_findButton);
                  await tester.pumpAndSettle();

                  verify(mockOnTap.call).called(1);

                  await Future.delayed(const Duration(milliseconds: 150));
                  await tester.pumpAndSettle();

                  await tester.tap(_findButton);
                  await tester.pumpAndSettle();

                  verify(mockOnTap.call).called(1);
                },
              );
            },
          );
        },
      );

      group(
        'TapDebouncer waitBuilder tests - ',
        () {
          testWidgets(
            'WHEN there is a waitBuilder '
            'THEN should show widget built with waitBuilder while wait',
            (tester) async {
              final busy = Completer<void>();

              when(mockOnTap.call).thenAnswer((_) async => busy.future);

              await tester.pumpWidget(
                _TestWidget(
                  child: TapDebouncer(
                    waitBuilder: (context, child) => Opacity(
                      opacity: 0.5,
                      child: child,
                    ),
                    onTap: mockOnTap.call,
                    builder: (context, onTap) => _TapTarget(onTap: onTap),
                  ),
                ),
              );

              expect(find.byType(Opacity), findsNothing);

              await tester.tap(_findButton);
              await tester.pumpAndSettle();

              expect(find.byType(Opacity), findsOneWidget);

              busy.complete();
              await tester.pumpAndSettle();

              expect(find.byType(Opacity), findsNothing);
            },
          );
        },
      );
    },
  );
}

Finder get _findButton => find.text('Button');

class _TapTarget extends StatelessWidget {
  const _TapTarget({
    super.key,
    this.onTap,
  });

  final Future<void> Function()? onTap;

  @override
  Widget build(BuildContext context) => Material(
        child: InkWell(
          onTap: onTap,
          child: const Text('Button'),
        ),
      );
}

class _TestWidget extends StatelessWidget {
  const _TestWidget({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Center(child: child),
      );
}
