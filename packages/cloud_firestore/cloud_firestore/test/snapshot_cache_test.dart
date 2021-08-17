import 'dart:async';

import 'package:cloud_firestore/src/snapshot_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:async/async.dart';

void main() {
  Future<void> waitForManualDelay() => Future.delayed(Duration.zero);

  setUp(() {
    if (snapshotCache.isNotEmpty) throw StateError('cache not empty');
  });

  group('getCachedSnapshot', () {
    test('does not add to cache the stream until listened', () {
      getCachedConnection(0, () => const Stream.empty());

      expect(snapshotCache, isEmpty);
    });

    test('first call returns a broadcast stream that emits all original events',
        () async {
      final controller = StreamController();
      addTearDown(controller.close);
      final stream = getCachedConnection(0, () => controller.stream);
      final queue = StreamQueue(stream);
      addTearDown(queue.cancel);

      controller.add(1);
      controller.add(2);
      controller.add(3);
      controller.addError(4);
      controller.addError(5);

      expect(stream.isBroadcast, true);
      await expectLater(queue.next, completion(1));
      await expectLater(queue.next, completion(2));
      await expectLater(queue.next, completion(3));
      await expectLater(queue.next, throwsA(4));
      await expectLater(queue.next, throwsA(5));
    });

    test(
        'late listeners receive the latest value, if any, then the rest of the stream',
        () async {
      final controller = StreamController();
      addTearDown(controller.close);
      final stream = getCachedConnection(0, () => controller.stream);

      // listening to the stream otherwise the native bridge isn't started
      final sub = stream.listen((event) {}, onError: (err) {});
      addTearDown(sub.cancel);

      controller.add(1);
      controller.add(2);

      await expectLater(stream, emitsInAnyOrder([1, 2]));

      final stream2 = getCachedConnection(0, () => controller.stream);
      final queue = StreamQueue(stream2);
      addTearDown(queue.cancel);

      await expectLater(queue.next, completion(2));

      controller.add(42);
      controller.addError(43);
      controller.add(44);

      await expectLater(queue.next, completion(42));
      await expectLater(queue.next, throwsA(43));
      await expectLater(queue.next, completion(44));
    });

    test(
        'late listeners receive the latest error, if any, then the rest of the stream',
        () async {
      final controller = StreamController.broadcast();
      addTearDown(controller.close);
      final stream = getCachedConnection(0, () => controller.stream);

      // listening to the stream otherwise the native bridge isn't started
      final sub = stream.listen((event) {}, onError: (err) {});
      addTearDown(sub.cancel);

      controller.add(1);
      await expectLater(stream, emits(1));

      controller.addError(2);
      await expectLater(stream, emitsError(2));

      final stream2 = getCachedConnection(0, () => controller.stream);
      final queue = StreamQueue(stream2);
      addTearDown(queue.cancel);

      await expectLater(queue.next, throwsA(2));

      controller.add(42);
      controller.addError(43);
      controller.add(44);

      await expectLater(queue.next, completion(42));
      await expectLater(queue.next, throwsA(43));
      await expectLater(queue.next, completion(44));
    });

    test('keeps the cache active until all listeners are removed', () async {
      final controller = StreamController();
      addTearDown(controller.close);
      final stream = getCachedConnection(0, () => controller.stream);

      final sub = stream.listen((event) {});
      final sub2 = stream.listen((event) {});

      expect(snapshotCache, {0: anything});
      expect(controller.hasListener, true);

      await sub.cancel();
      await waitForManualDelay();

      expect(snapshotCache, {0: anything});
      expect(controller.hasListener, true);

      await sub2.cancel();
      await waitForManualDelay();

      expect(snapshotCache, isEmpty);
      expect(snapshotCache, isEmpty);
      expect(controller.hasListener, false);
    });
  });

  group('SnapshotParameters', () {
    test('overrides ==', () {
      expect(
        SnapshotParameter(42, false),
        SnapshotParameter(42, false),
      );
      expect(
        SnapshotParameter(42, false),
        isNot(SnapshotParameter(42, true)),
      );
      expect(
        SnapshotParameter(42, false),
        isNot(SnapshotParameter(41, false)),
      );
    });
  });
}
