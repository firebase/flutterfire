@TestOn('browser')
import 'package:firebase/firebase.dart' as fb;
import 'package:firebase/src/assets/assets.dart';
import 'package:test/test.dart';

import 'test_util.dart';

final _throwsInvalidKey = throwsToString(
  anyOf(
    contains('method not found'),
    contains('cannot be an object'),
  ),
);

void main() {
  fb.App app;
  fb.Database database;

  setUpAll(() async {
    await config();
  });

  setUp(() async {
    app = fb.initializeApp(
        apiKey: apiKey,
        authDomain: authDomain,
        databaseURL: databaseUrl,
        storageBucket: storageBucket);
    database = fb.database();
  });

  tearDown(() async {
    if (app != null) {
      await app.delete();
      app = null;
    }
  });

  group('instance', () {
    test('App exists', () {
      expect(database, isNotNull);
      expect(database.app, isNotNull);
      expect(database.app.name, fb.app().name);
    });
  });

  group('DatabaseReference', () {
    fb.DatabaseReference ref;
    String key;

    setUp(() {
      ref = database.ref(validDatePath());
      key = ref.push({'text': 'hello'}).key;
      expect(key, isNotNull);
    });

    tearDown(() async {
      await ref.remove();
      ref = null;
      key = null;
    });

    test('has toJson', () {
      var toJsonString = ref.toJson() as String;
      expect(toJsonString, startsWith(databaseUrl));

      var uri = Uri.parse(ref.toJson() as String);
      expect(uri.pathSegments, hasLength(1));
    });

    test('remove', () async {
      var eventFuture = ref.onValue.first;

      await ref.remove();
      var event = await eventFuture;

      expect(event.snapshot.val(), isNull);
      expect(event.snapshot.toJson(), isNull);
    });

    test('child and once on value', () async {
      var childRef = ref.child(key);

      var event = await childRef.once('value');
      expect(event.snapshot.key, key);
      expect(event.snapshot.val()['text'], 'hello');
      expect(event.snapshot.toJson(), {'text': 'hello'});

      childRef = childRef.child('text');
      event = await childRef.once('value');
      expect(event.snapshot.key, 'text');
      expect(event.snapshot.val(), 'hello');
      expect(event.snapshot.toJson(), 'hello');
    });

    test('key', () {
      var childRef = ref.child(key);
      expect(key, childRef.key);
    });

    test('parent', () {
      var childRef = ref.child('text');
      expect(childRef.parent.toString(), ref.toString());
    });

    test('root', () {
      var childRef = ref.child('text');
      expect(childRef.root.toString(), contains(databaseUrl));
    });

    test('empty push and set', () async {
      var childRef = ref.push();
      expect(childRef.key, isNotNull);
      await childRef.set({'text': 'ahoj'});

      var event = await childRef.once('value');
      expect(event.snapshot.val()['text'], 'ahoj');
    });

    test('wrong value push', () {
      expect(() => ref.push(_TestClass()), throwsArgumentError);
    });

    test('transaction', () async {
      var childRef = ref.child('todos');
      await childRef.set('Cooking');

      await childRef
          .transaction((currentValue) => '$currentValue delicious dinner!');

      var event = await childRef.once('value');
      var val = event.snapshot.val();
      expect(val, isNot('Cooking'));
      expect(val, 'Cooking delicious dinner!');
    });

    test('distinctListeners', () async {
      var sub1 = ref.onValue.listen(expectAsync1((event) {
        // print('first listener called.');
      }, count: 1));

      addTearDown(sub1.cancel);

      var sub2 = ref.onValue.listen(expectAsync1((event) {
        // print('second listener called.');
      }, count: 0));

      await sub2.cancel().then((_) {
        // print('second listener cancelled.')
      });

      var anotherRef = database.ref('test');
      var sub3 = anotherRef.onValue.listen(expectAsync1((event) {
        // print('third listener called.');
      }, count: 1));

      addTearDown(sub3.cancel);

      var yetAnotherRef = database.ref('test');
      var sub4 = yetAnotherRef.onValue.listen(expectAsync1((event) {
        // print('fourth listener called.');
      }, count: 0));

      await sub4.cancel().then((_) {
        // print('fourth listener cancelled.')
      });
    });

    test('onValue', () async {
      var childRef = ref.child('todos');
      // ignore: unawaited_futures
      childRef.set(['Programming', 'Cooking', 'Walking with dog']);

      var subscription = childRef.onValue.listen(expectAsync1((event) {
        var todos = event.snapshot.val();
        expect(todos, isNotNull);
        expect(todos.length, 3);
        expect(todos, contains('Programming'));
      }, count: 1));

      await subscription.cancel();
    });

    test('onChildAdded', () async {
      var childRef = ref.child('todos');

      var todos = [];
      var eventsCount = 0;
      var subscription = childRef.onChildAdded.listen(expectAsync1((event) {
        var val = event.snapshot.val();
        todos.add(val);
        eventsCount++;
        expect(eventsCount, isNonZero);
        expect(eventsCount, lessThan(4));
        expect(val, anyOf('Programming', 'Cooking', 'Walking with dog'));
      }, count: 3));

      childRef.push('Programming');
      childRef.push('Cooking');
      childRef.push('Walking with dog');

      await subscription.cancel();
    });

    test('onChildRemoved', () async {
      var childRef = ref.child('todos');
      var childKey = childRef.push('Programming').key;
      childRef.push('Cooking');
      childRef.push('Walking with dog');

      var subscription = childRef.onChildRemoved.listen(expectAsync1((event) {
        var val = event.snapshot.val();
        expect(val, 'Programming');
        expect(val, isNot('Cooking'));
      }, count: 1));

      await childRef.child(childKey).remove();
      await subscription.cancel();
    });

    test('onChildChanged', () async {
      var childRef = ref.child('todos');
      var childKey = childRef.push('Programming').key;
      childRef.push('Cooking');
      childRef.push('Walking with dog');

      var subscription = childRef.onChildChanged.listen(expectAsync1((event) {
        var val = event.snapshot.val();
        expect(val, 'Programming a Firebase lib');
        expect(val, isNot('Programming'));
        expect(val, isNot('Cooking'));
      }, count: 1));

      await childRef.child(childKey).set('Programming a Firebase lib');
      await subscription.cancel();
    });

    test('onChildMoved', () async {
      var childRef = ref.child('todos');
      var childPushRef = childRef.push('Programming');
      // ignore: unawaited_futures
      childPushRef.setPriority(5);
      // ignore: unawaited_futures
      childRef.push('Cooking').setPriority(10);
      // ignore: unawaited_futures
      childRef.push('Walking with dog').setPriority(15);

      var subscription =
          childRef.orderByPriority().onChildMoved.listen(expectAsync1((event) {
                var val = event.snapshot.val();
                expect(val, 'Programming');
                expect(val, isNot('Cooking'));
              }, count: 1));

      // ignore: unawaited_futures
      childPushRef.setPriority(100);
      await subscription.cancel();
    });

    test('endAt', () async {
      var childRef = ref.child('flowers');
      childRef.push('rose');
      childRef.push('tulip');
      childRef.push('chicory');
      childRef.push('sunflower');

      var event = await childRef.orderByValue().endAt('rose').once('value');
      var flowers = [];
      event.snapshot.forEach((snapshot) {
        flowers.add(snapshot.val());
      });

      expect(flowers.length, 2);
      expect(flowers.contains('chicory'), isTrue);
      expect(flowers.contains('sunflower'), isFalse);
    });

    test('endAt with wrong parameter', () {
      var childRef = ref.child('flowers');
      childRef.push({'name': 'rose'});

      expect(() => childRef.orderByValue().endAt({'name': 'rose'}),
          _throwsInvalidKey);
    });

    test('startAt', () async {
      var childRef = ref.child('flowers');
      childRef.push('rose');
      childRef.push('tulip');
      childRef.push('chicory');
      childRef.push('sunflower');

      var event = await childRef.orderByValue().startAt('rose').once('value');
      var flowers = [];
      event.snapshot.forEach((snapshot) {
        flowers.add(snapshot.val());
      });

      expect(flowers.length, 3);
      expect(flowers.contains('sunflower'), isTrue);
      expect(flowers.contains('chicory'), isFalse);
    });

    test('startAt with wrong parameter', () {
      var childRef = ref.child('flowers');
      childRef.push({'name': 'chicory'});

      expect(() => childRef.orderByValue().startAt({'name': 'chicory'}),
          _throwsInvalidKey);
    });

    test('equalTo', () async {
      var childRef = ref.child('flowers');
      childRef.push('rose');
      childRef.push('tulip');

      var event = await childRef.orderByValue().equalTo('rose').once('value');
      var flowers = [];
      event.snapshot.forEach((snapshot) {
        flowers.add(snapshot.val());
      });

      expect(flowers, isNotNull);
      expect(flowers.length, 1);
      expect(flowers.first, 'rose');
    });

    test('equalTo with wrong parameter', () async {
      var childRef = ref.child('flowers');
      childRef.push({'name': 'sunflower'});

      expect(() => childRef.orderByValue().equalTo({'name': 'sunflower'}),
          _throwsInvalidKey);
    });

    test('isEqual', () async {
      var childRef = ref.child('flowers');
      childRef.push('rose');
      childRef.push('tulip');
      childRef.push('chicory');
      childRef.push('sunflower');

      expect(ref.isEqual(childRef), isFalse);
      expect(ref.child('flowers').isEqual(childRef), isTrue);
      expect(childRef.parent.isEqual(ref), isTrue);

      var childQuery = childRef.limitToFirst(2);
      expect(childRef.limitToFirst(2).isEqual(childQuery), isTrue);
      expect(childRef.limitToLast(2).isEqual(childQuery), isFalse);
      expect(
          childRef.orderByValue().limitToFirst(2).isEqual(childQuery), isFalse);
    });

    test('limitToFirst', () async {
      var childRef = ref.child('flowers');
      childRef.push('rose');
      childRef.push('tulip');
      childRef.push('chicory');
      childRef.push('sunflower');

      var event = await childRef.orderByValue().limitToFirst(2).once('value');
      var flowers = [];
      event.snapshot.forEach((snapshot) {
        flowers.add(snapshot.val());
      });

      expect(flowers, isNotEmpty);
      expect(flowers.length, 2);
      expect(flowers, contains('chicory'));
      expect(flowers, contains('rose'));
    });

    test('limitToLast', () async {
      var childRef = ref.child('flowers');
      childRef.push('rose');
      childRef.push('tulip');
      childRef.push('chicory');
      childRef.push('sunflower');

      var event = await childRef.orderByValue().limitToLast(1).once('value');
      var flowers = [];
      event.snapshot.forEach((snapshot) {
        flowers.add(snapshot.val());
      });

      expect(flowers, isNotEmpty);
      expect(flowers.length, 1);
      expect(flowers, contains('tulip'));
    });

    test('orderByKey', () async {
      var childRef = ref.child('flowers');
      await childRef.child('one').set('rose');
      await childRef.child('two').set('tulip');
      await childRef.child('three').set('chicory');
      await childRef.child('four').set('sunflower');

      var event = await childRef.orderByKey().once('value');
      var flowers = [];
      event.snapshot.forEach((snapshot) {
        flowers.add(snapshot.key);
      });

      expect(flowers, isNotEmpty);
      expect(flowers.length, 4);
      expect(flowers, ['four', 'one', 'three', 'two']);
    });

    test('orderByValue', () async {
      var childRef = ref.child('flowers');
      childRef.push('rose');
      childRef.push('tulip');
      childRef.push('chicory');
      childRef.push('sunflower');

      var event = await childRef.orderByValue().once('value');
      var flowers = [];
      event.snapshot.forEach((snapshot) {
        flowers.add(snapshot.val());
      });

      expect(flowers, isNotEmpty);
      expect(flowers.length, 4);
      expect(flowers, ['chicory', 'rose', 'sunflower', 'tulip']);
    });

    test('orderByChild', () async {
      var childRef = ref.child('people');
      childRef.push({'name': 'Alex', 'age': 27});
      childRef.push({'name': 'Andrew', 'age': 43});
      childRef.push({'name': 'James', 'age': 12});

      var event = await childRef.orderByChild('age').once('value');
      var people = [];
      event.snapshot.forEach((snapshot) {
        people.add(snapshot.val());
      });

      expect(people, isNotEmpty);
      expect(people.first['name'], 'James');
      expect(people.last['name'], 'Andrew');
    });

    test('orderByPriority', () async {
      var childRef = ref.child('people');
      await childRef
          .child('one')
          .setWithPriority({'name': 'Alex', 'age': 27}, 10);
      await childRef
          .child('two')
          .setWithPriority({'name': 'Andrew', 'age': 43}, 5);
      await childRef
          .child('three')
          .setWithPriority({'name': 'James', 'age': 12}, 700);

      var event = await childRef.orderByPriority().once('value');
      var people = [];
      event.snapshot.forEach((snapshot) {
        people.add(snapshot.val());
      });

      expect(people, isNotEmpty);
      expect(people.first['name'], 'Andrew');
      expect(people.last['name'], 'James');
    });

    test('set with priority', () async {
      var childRef = ref.child('people');
      await childRef
          .child('one')
          .setWithPriority({'name': 'Alex', 'age': 27}, 1.0);
      await childRef
          .child('two')
          .setWithPriority({'name': 'Andrew', 'age': 43}, 'A');
      await childRef
          .child('three')
          .setWithPriority({'name': 'James', 'age': 12}, null);

      var event = await childRef.once('value');
      var priorities = [];
      event.snapshot.forEach((snapshot) {
        priorities.add(snapshot.getPriority());
      });

      expect(priorities, isNotEmpty);
      expect(priorities.contains(1.0), isTrue);
      expect(priorities.contains('A'), isTrue);
      expect(priorities.contains(null), isTrue);
    });

    test('update with complex object', () async {
      // Regression test for github.com/FirebaseExtended/firebase-dart/issues/173
      var childRef = ref.child('people');
      await childRef.child('one').update({
        'list': [
          {'key': 'value'}
        ]
      });
    });

    test('set with wrong priority type', () {
      var childRef = ref.child('people');

      expect(
          () => childRef
              .child('one')
              .setWithPriority({'name': 'Alex', 'age': 27}, {'priority': 10}),
          throwsToString(
              contains('Second argument must be a valid Firebase priority')));
      expect(
          () => childRef
              .child('two')
              .setWithPriority({'name': 'Andrew', 'age': 43}, true),
          throwsToString(
              contains('Second argument must be a valid Firebase priority')));
    });
  });
}

class _TestClass {}
