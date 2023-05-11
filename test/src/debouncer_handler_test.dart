import 'package:mocktail/mocktail.dart';
import 'package:tap_debouncer/src/debouncer_handler.dart';
import 'package:test/test.dart';

class _MockOnTap extends Mock {
  Future<void> call();
}

class _Exception extends Mock implements Exception {}

void main() {
  late DebouncerHandler debouncerHandler;
  final mockOnTap = _MockOnTap();

  setUp(() {
    debouncerHandler = DebouncerHandler();

    when(mockOnTap.call).thenAnswer((_) async {});
  });

  tearDown(() {
    debouncerHandler.dispose();

    reset(mockOnTap);
  });

  group('DebouncerHandler tests - ', () {
    test(
      'WHEN debouncerHandler created '
      'THEN should emit init value',
      () async {
        expect(
          debouncerHandler.busyStream,
          emitsInOrder(
            [
              emits(false),
            ],
          ),
        );
      },
    );

    test(
      'WHEN onTap called '
      'THEN should emit correct values',
      () async {
        await debouncerHandler.onTap(mockOnTap);

        expect(
          debouncerHandler.busyStream,
          emitsInOrder(
            [
              emits(false),
              emits(true),
              emits(false),
            ],
          ),
        );

        verify(mockOnTap.call).called(1);
      },
    );

    test(
      'WHEN onTap called and callback threw an exception '
      'THEN should emit correct values and throw the same exception',
      () async {
        when(mockOnTap.call).thenAnswer((_) async => throw _Exception());

        expect(
          () => debouncerHandler.onTap(mockOnTap),
          throwsA(isA<_Exception>()),
        );

        expect(
          debouncerHandler.busyStream,
          emitsInOrder(
            [
              emits(false),
              emits(true),
              emits(false),
            ],
          ),
        );

        verify(mockOnTap.call).called(1);
      },
    );
  });
}
