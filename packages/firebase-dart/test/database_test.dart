@TestOn('browser')
import 'package:firebase/firebase.dart' as fb;
import 'package:firebase/src/assets/assets.dart';
import 'package:test/test.dart';
import 'package:firebase/firebase.dart';

import 'test_util.dart';

void main() {
  App app;

  setUpAll(() async {
    await config();
  });

  setUp(() async {
    app = initializeApp(
        apiKey: apiKey,
        authDomain: authDomain,
        databaseURL: databaseUrl,
        storageBucket: storageBucket);
  });

  tearDown(() async {
    if (app != null) {
      await app.delete();
      app = null;
    }
  });

  group("Database", () {
    Database database;

    setUp(() {
      database = fb.database();
    });

    group("instance", () {
      test("App exists", () {
        expect(database, isNotNull);
        expect(database.app, isNotNull);
        expect(database.app.name, fb.app().name);
      });
    });

    group("DatabaseReference", () {
      DatabaseReference ref;
      String key;

      setUp(() {
        ref = database.ref(validDatePath());
        key = ref.push({"text": "hello"}).key;
        expect(key, isNotNull);
      });

      tearDown(() async {
        await ref.remove();
        ref = null;
        key = null;
      });

      test("remove", () async {
        var eventFuture = ref.onValue.first;

        await ref.remove();
        var event = await eventFuture;

        expect(event.snapshot.val(), isNull);
      });

      test("child and once on value", () async {
        var childRef = ref.child(key);
        var event = await childRef.once("value");
        expect(event.snapshot.key, key);
        expect(event.snapshot.val()["text"], "hello");

        childRef = childRef.child("text");
        event = await childRef.once("value");
        expect(event.snapshot.key, "text");
        expect(event.snapshot.val(), "hello");
      });

      test("key", () {
        var childRef = ref.child(key);
        expect(key, childRef.key);
      });

      test("parent", () {
        var childRef = ref.child("text");
        expect(childRef.parent.toString(), ref.toString());
      });

      test("root", () {
        var childRef = ref.child("text");
        expect(childRef.root.toString(), contains(databaseUrl));
      });

      test("empty push and set", () async {
        var childRef = ref.push();
        expect(childRef.key, isNotNull);
        childRef.set({"text": "ahoj"});

        var event = await childRef.once("value");
        expect(event.snapshot.val()["text"], "ahoj");
      });

      test("wrong value push", () {
        expect(() => ref.push(new _TestClass()), throwsArgumentError);
      });

      test("transaction", () async {
        var childRef = ref.child("todos");
        childRef.set("Cooking");

        await childRef
            .transaction((currentValue) => "$currentValue delicious dinner!");

        var event = await childRef.once("value");
        var val = event.snapshot.val();
        expect(val, isNot("Cooking"));
        expect(val, "Cooking delicious dinner!");
      });

      test("onValue", () async {
        var childRef = ref.child("todos");
        childRef.set(["Programming", "Cooking", "Walking with dog"]);

        var subscription = childRef.onValue.listen(expectAsync1((event) {
          var todos = event.snapshot.val();
          expect(todos, isNotNull);
          expect(todos.length, 3);
          expect(todos, contains("Programming"));
        }, count: 1));

        await subscription.cancel();
      });

      test("onChildAdded", () async {
        var childRef = ref.child("todos");

        var todos = [];
        var eventsCount = 0;
        var subscription = childRef.onChildAdded.listen(expectAsync1((event) {
          var val = event.snapshot.val();
          todos.add(val);
          eventsCount++;
          expect(eventsCount, isNonZero);
          expect(eventsCount, lessThan(4));
          expect(val, anyOf("Programming", "Cooking", "Walking with dog"));
        }, count: 3));

        childRef.push("Programming");
        childRef.push("Cooking");
        childRef.push("Walking with dog");

        await subscription.cancel();
      });

      test("onChildRemoved", () async {
        var childRef = ref.child("todos");
        var childKey = childRef.push("Programming").key;
        childRef.push("Cooking");
        childRef.push("Walking with dog");

        var subscription = childRef.onChildRemoved.listen(expectAsync1((event) {
          var val = event.snapshot.val();
          expect(val, "Programming");
          expect(val, isNot("Cooking"));
        }, count: 1));

        childRef.child(childKey).remove();
        await subscription.cancel();
      });

      test("onChildChanged", () async {
        var childRef = ref.child("todos");
        var childKey = childRef.push("Programming").key;
        childRef.push("Cooking");
        childRef.push("Walking with dog");

        var subscription = childRef.onChildChanged.listen(expectAsync1((event) {
          var val = event.snapshot.val();
          expect(val, "Programming a Firebase lib");
          expect(val, isNot("Programming"));
          expect(val, isNot("Cooking"));
        }, count: 1));

        childRef.child(childKey).set("Programming a Firebase lib");
        await subscription.cancel();
      });

      test("onChildMoved", () async {
        var childRef = ref.child("todos");
        var childPushRef = childRef.push("Programming");
        childPushRef.setPriority(5);
        childRef.push("Cooking").setPriority(10);
        childRef.push("Walking with dog").setPriority(15);

        var subscription =
            childRef.orderByPriority().onChildMoved.listen(expectAsync1((event) {
                  var val = event.snapshot.val();
                  expect(val, "Programming");
                  expect(val, isNot("Cooking"));
                }, count: 1));

        childPushRef.setPriority(100);
        await subscription.cancel();
      });

      test("endAt", () async {
        var childRef = ref.child("flowers");
        childRef.push("rose");
        childRef.push("tulip");
        childRef.push("chicory");
        childRef.push("sunflower");

        var event = await childRef.orderByValue().endAt("rose").once("value");
        var flowers = [];
        event.snapshot.forEach((snapshot) {
          flowers.add(snapshot.val());
        });

        expect(flowers.length, 2);
        expect(flowers.contains("chicory"), isTrue);
        expect(flowers.contains("sunflower"), isFalse);
      });

      test("endAt with wrong parameter", () {
        var childRef = ref.child("flowers");
        childRef.push({"name": "rose"});

        expect(() => childRef.orderByValue().endAt({"name": "rose"}), throws);
      });

      test("startAt", () async {
        var childRef = ref.child("flowers");
        childRef.push("rose");
        childRef.push("tulip");
        childRef.push("chicory");
        childRef.push("sunflower");

        var event = await childRef.orderByValue().startAt("rose").once("value");
        var flowers = [];
        event.snapshot.forEach((snapshot) {
          flowers.add(snapshot.val());
        });

        expect(flowers.length, 3);
        expect(flowers.contains("sunflower"), isTrue);
        expect(flowers.contains("chicory"), isFalse);
      });

      test("startAt with wrong parameter", () {
        var childRef = ref.child("flowers");
        childRef.push({"name": "chicory"});

        expect(
            () => childRef.orderByValue().startAt({"name": "chicory"}), throws);
      });

      test("equalTo", () async {
        var childRef = ref.child("flowers");
        childRef.push("rose");
        childRef.push("tulip");

        var event = await childRef.orderByValue().equalTo("rose").once("value");
        var flowers = [];
        event.snapshot.forEach((snapshot) {
          flowers.add(snapshot.val());
        });

        expect(flowers, isNotNull);
        expect(flowers.length, 1);
        expect(flowers.first, "rose");
      });

      test("equalTo with wrong parameter", () async {
        var childRef = ref.child("flowers");
        childRef.push({"name": "sunflower"});

        expect(() => childRef.orderByValue().equalTo({"name": "sunflower"}),
            throws);
      });

      test("isEqual", () async {
        var childRef = ref.child("flowers");
        childRef.push("rose");
        childRef.push("tulip");
        childRef.push("chicory");
        childRef.push("sunflower");

        expect(ref.isEqual(childRef), isFalse);
        expect(ref.child("flowers").isEqual(childRef), isTrue);
        expect(childRef.parent.isEqual(ref), isTrue);

        var childQuery = childRef.limitToFirst(2);
        expect(childRef.limitToFirst(2).isEqual(childQuery), isTrue);
        expect(childRef.limitToLast(2).isEqual(childQuery), isFalse);
        expect(childRef.orderByValue().limitToFirst(2).isEqual(childQuery),
            isFalse);
      });

      test("limitToFirst", () async {
        var childRef = ref.child("flowers");
        childRef.push("rose");
        childRef.push("tulip");
        childRef.push("chicory");
        childRef.push("sunflower");

        var event = await childRef.orderByValue().limitToFirst(2).once("value");
        var flowers = [];
        event.snapshot.forEach((snapshot) {
          flowers.add(snapshot.val());
        });

        expect(flowers, isNotEmpty);
        expect(flowers.length, 2);
        expect(flowers, contains("chicory"));
        expect(flowers, contains("rose"));
      });

      test("limitToLast", () async {
        var childRef = ref.child("flowers");
        childRef.push("rose");
        childRef.push("tulip");
        childRef.push("chicory");
        childRef.push("sunflower");

        var event = await childRef.orderByValue().limitToLast(1).once("value");
        var flowers = [];
        event.snapshot.forEach((snapshot) {
          flowers.add(snapshot.val());
        });

        expect(flowers, isNotEmpty);
        expect(flowers.length, 1);
        expect(flowers, contains("tulip"));
      });

      test("orderByKey", () async {
        var childRef = ref.child("flowers");
        childRef.child("one").set("rose");
        childRef.child("two").set("tulip");
        childRef.child("three").set("chicory");
        childRef.child("four").set("sunflower");

        var event = await childRef.orderByKey().once("value");
        var flowers = [];
        event.snapshot.forEach((snapshot) {
          flowers.add(snapshot.key);
        });

        expect(flowers, isNotEmpty);
        expect(flowers.length, 4);
        expect(flowers, ["four", "one", "three", "two"]);
      });

      test("orderByValue", () async {
        var childRef = ref.child("flowers");
        childRef.push("rose");
        childRef.push("tulip");
        childRef.push("chicory");
        childRef.push("sunflower");

        var event = await childRef.orderByValue().once("value");
        var flowers = [];
        event.snapshot.forEach((snapshot) {
          flowers.add(snapshot.val());
        });

        expect(flowers, isNotEmpty);
        expect(flowers.length, 4);
        expect(flowers, ["chicory", "rose", "sunflower", "tulip"]);
      });

      test("orderByChild", () async {
        var childRef = ref.child("people");
        childRef.push({"name": "Alex", "age": 27});
        childRef.push({"name": "Andrew", "age": 43});
        childRef.push({"name": "James", "age": 12});

        var event = await childRef.orderByChild("age").once("value");
        var people = [];
        event.snapshot.forEach((snapshot) {
          people.add(snapshot.val());
        });

        expect(people, isNotEmpty);
        expect(people.first["name"], "James");
        expect(people.last["name"], "Andrew");
      });

      test("orderByPriority", () async {
        var childRef = ref.child("people");
        childRef.child("one").setWithPriority({"name": "Alex", "age": 27}, 10);
        childRef.child("two").setWithPriority({"name": "Andrew", "age": 43}, 5);
        childRef
            .child("three")
            .setWithPriority({"name": "James", "age": 12}, 700);

        var event = await childRef.orderByPriority().once("value");
        var people = [];
        event.snapshot.forEach((snapshot) {
          people.add(snapshot.val());
        });

        expect(people, isNotEmpty);
        expect(people.first["name"], "Andrew");
        expect(people.last["name"], "James");
      });

      test("set with priority", () async {
        var childRef = ref.child("people");
        childRef.child("one").setWithPriority({"name": "Alex", "age": 27}, 1.0);
        childRef
            .child("two")
            .setWithPriority({"name": "Andrew", "age": 43}, "A");
        childRef
            .child("three")
            .setWithPriority({"name": "James", "age": 12}, null);

        var event = await childRef.once("value");
        var priorities = [];
        event.snapshot.forEach((snapshot) {
          priorities.add(snapshot.getPriority());
        });

        expect(priorities, isNotEmpty);
        expect(priorities.contains(1.0), isTrue);
        expect(priorities.contains("A"), isTrue);
        expect(priorities.contains(null), isTrue);
      });

      test("set with wrong priority type", () {
        var childRef = ref.child("people");

        expect(
            () => childRef
                .child("one")
                .setWithPriority({"name": "Alex", "age": 27}, {"priority": 10}),
            throws);
        expect(
            () => childRef
                .child("two")
                .setWithPriority({"name": "Andrew", "age": 43}, true),
            throws);
      });
    });
  });
}

class _TestClass {}
