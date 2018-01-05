@TestOn('browser')
import 'dart:async';
import 'package:firebase/firebase.dart' as fb;
import 'package:firebase/firebase_firestore.dart' as fs;
import 'package:firebase/src/assets/assets.dart';
import 'package:test/test.dart';
import 'test_util.dart' show throwsToString, validDatePathComponent;

// Delete entire collection
// <https://firebase.google.com/docs/firestore/manage-data/delete-data#collections>
Future _deleteCollection(fs.Firestore db, fs.CollectionReference collectionRef,
    {int batchSize}) async {
  batchSize ??= 4;
  var query = collectionRef.orderBy('__name__').limit(batchSize);

  int snapshotSize;
  do {
    var snapshot = await query.get();
    snapshotSize = snapshot.size;

    // When there are no documents left, we are done
    if (snapshotSize == 0) {
      break;
    }

    // Delete documents in a batch
    var batch = db.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.ref);
    }

    await batch.commit();
  } while (snapshotSize > batchSize);
}

void main() {
  final testPath = 'pkg_firebase_test_${validDatePathComponent()}';

  fb.App app;
  fs.Firestore firestore;

  setUpAll(() async {
    await config();
  });

  setUp(() async {
    app = fb.initializeApp(
        apiKey: apiKey,
        authDomain: authDomain,
        databaseURL: databaseUrl,
        projectId: projectId,
        storageBucket: storageBucket);

    firestore = fb.firestore();
  });

  tearDown(() async {
    if (app != null) {
      await app.delete();
      app = null;
    }
  });

  group("instance", () {
    test("App exists", () {
      expect(firestore, isNotNull);
      expect(firestore.app, isNotNull);
      expect(firestore.app.name, fb.app().name);
    });
  });

  group("Collections and documents", () {
    fs.CollectionReference ref;

    setUp(() {
      ref = firestore.collection(testPath);
    });

    tearDown(() async {
      if (ref != null) {
        await _deleteCollection(firestore, ref);
        ref = null;
      }
    });

    test("collection exists", () {
      expect(ref, isNotNull);
      expect(ref.id, ref.path);
      expect(ref.path, ref.path);
    });

    test("create document with auto generated ID", () {
      var docRef = ref.doc();

      expect(docRef, isNotNull);
      expect(docRef.id, isNotEmpty);
    });

    test("create document", () {
      var docRef = ref.doc("message1");

      expect(docRef, isNotNull);
      expect(docRef.id, "message1");
      expect(docRef.path, "${ref.path}/message1");
      expect(docRef.parent.id, ref.id);
    });

    test("get document in collection", () {
      var docRef = ref.doc("message2");
      var docRefSecond = firestore.doc("messages/message2");
      expect(docRefSecond, isNotNull);
      expect(docRefSecond.id, docRef.id);
    });

    test("get document in collection of document", () {
      var docRef = ref.doc("message3").collection("words").doc("word1");
      expect(docRef, isNotNull);
      expect(docRef.id, "word1");
    });

    test("collection path", () {
      var childRef = firestore.collection("${ref.path}/message4/words");
      expect(childRef, isNotNull);
      expect(childRef.id, "words");
      expect(childRef.parent.id, "message4");
    });
  });

  group("DocumentReference", () {
    fs.CollectionReference ref;

    setUp(() {
      ref = firestore.collection(testPath);
    });

    tearDown(() async {
      if (ref != null) {
        await _deleteCollection(firestore, ref);
        ref = null;
      }
    });

    test("delete collection", () async {
      var nycRef = ref.doc("NYC");
      await nycRef.set({"name": "NYC"});
      var sfRef = ref.doc("SF");
      await sfRef.set({"name": "SF", "population": 0});
      var laRef = ref.doc("LA");
      await laRef.set({"name": "LA"});

      await _deleteCollection(firestore, ref);

      var snapshot = await ref.get();
      expect(snapshot.empty, isTrue);
      expect(snapshot.docs.isEmpty, isTrue);
    });

    test("delete", () async {
      var nycRef = ref.doc("NYC");
      await nycRef.set({"name": "NYC"});

      await nycRef.delete();
      nycRef = ref.doc("NYC");

      var snapshot = await nycRef.get();
      expect(snapshot.exists, isFalse);
    });

    test("delete fields", () async {
      var nycRef = ref.doc("NYC");
      await nycRef.set({"name": "New York", "population": 1000});

      var snapshot = await nycRef.get();
      var snapshotData = snapshot.data();
      expect(snapshotData["name"], "New York");
      expect(snapshotData["population"], 1000);

      await nycRef.update(data: {"population": fs.FieldValue.delete()});

      snapshot = await nycRef.get();
      snapshotData = snapshot.data();
      expect(snapshotData["name"], "New York");
      expect(snapshotData["population"], isNull);
    });

    test("set document", () async {
      var docRef = ref.doc("message1");
      await docRef.set({"text": "Hi!"});

      var snapshot = await docRef.get();
      expect(snapshot.id, "message1");
      expect(snapshot.exists, true);
    });

    test("set overwrites document", () async {
      var docRef = ref.doc("message2");

      await docRef.set({"text": "Message2"});
      var snapshot = await docRef.get();
      var snapshotData = snapshot.data();

      expect(snapshotData, new isInstanceOf<Map>());
      expect(snapshotData["text"], "Message2");

      await docRef.set({"title": "Ahoj"});
      snapshot = await docRef.get();
      snapshotData = snapshot.data();

      expect(snapshotData["text"], isNull);
      expect(snapshotData["title"], "Ahoj");
    });

    test("set with merge", () async {
      var docRef = ref.doc("message3");

      await docRef.set({"text": "Message3"});
      var snapshot = await docRef.get();
      var snapshotData = snapshot.data();

      await docRef.set({"text": "MessageNew", "title": "Ahoj"},
          new fs.SetOptions(merge: true));
      snapshot = await docRef.get();
      snapshotData = snapshot.data();

      expect(snapshotData["text"], "MessageNew");
      expect(snapshotData["title"], "Ahoj");
    });

    group('validate types', () {
      var map = <String, Object>{
        "string": "Hello world!",
        "bool": true,
        "numm": 3.14159265,
        "array": [5, true, "hello"],
        "null": null,
        "map": {
          "a": 5,
          "b": {"nested": "foo"}
        },
        "dateTime": new DateTime.fromMillisecondsSinceEpoch(123456789),
        "dateTimeUtc":
            new DateTime.fromMillisecondsSinceEpoch(123456789, isUtc: true),
      };

      void expectSammeMoment(DateTime value, DateTime expected) {
        expect(value.isAtSameMomentAs(expected), isTrue,
            reason: [
              value.toUtc(),
              'should be the same moment as',
              expected.toUtc(),
              '– ignoring timezone.'
            ].join(' '));
      }

      for (var key in map.keys) {
        final value = map[key];
        test(key, () async {
          var ref = firestore.collection(testPath);
          var docRef = ref.doc("types");
          await docRef.set({'value': map[key]});
          var snapshot = await docRef.get();

          var snapshotDataValue = snapshot.data()['value'];
          var snapshotGetValue = snapshot.get('value');

          if (value is DateTime) {
            expectSammeMoment(snapshotDataValue, value);
            expectSammeMoment(snapshotGetValue, value);
          } else {
            expect(snapshotDataValue, value);
            expect(snapshotGetValue, value);
          }
        });
      }
    });

    test("get field", () async {
      var docRef = ref.doc("message4");

      var map = {
        "stringExample": "Hello world!",
        "innerMap": {"someNumber": 3.14159265}
      };

      await docRef.set(map);
      var snapshot = await docRef.get();

      expect(snapshot.get("stringExample"), "Hello world!");
      expect(snapshot.get("innerMap.someNumber"), 3.14159265);
      expect(
          snapshot.get(new fs.FieldPath("innerMap", "someNumber")), 3.14159265);
      expect(snapshot.get("someNotExistentValue"), isNull);
    });

    test("add document", () async {
      var docRef = await ref.add({"text": "MessageAdd"});

      expect(docRef, isNotNull);
      expect(docRef.id, isNotNull);
      expect(docRef.parent.id, ref.id);
    });

    test("update document with Map", () async {
      var docRef = await ref.add({"text": "Ahoj"});
      await docRef.update(data: {"text": "Ahoj2"});

      var snapshot = await docRef.get();
      var snapshotData = snapshot.data();

      expect(snapshotData["text"], "Ahoj2");

      await docRef.update(data: {"text": "Ahoj", "text_en": "Hi"});

      snapshot = await docRef.get();
      snapshotData = snapshot.data();

      expect(snapshotData["text"], "Ahoj");
      expect(snapshotData["text_en"], "Hi");
    });

    test("update with serverTimestamp", () async {
      var docRef = await ref.add({"text": "Good night"});
      await docRef.update(data: {"timestamp": fs.FieldValue.serverTimestamp()});

      var snapshot = await docRef.get();
      var snapshotData = snapshot.data();

      expect(snapshotData["timestamp"], isNotNull);
    });

    test("update nested with dot notation", () async {
      var docRef = await ref.add({
        "greeting": {"text": "Good Morning"}
      });
      await docRef.update(data: {"greeting.text": "Good Morning after update"});

      var snapshot = await docRef.get();
      var snapshotData = snapshot.data();

      expect(snapshotData["greeting"]["text"], "Good Morning after update");
    });

    test("update with FieldPath", () async {
      var docRef = await ref.add({
        "greeting": {"text": "Good Evening"}
      });
      await docRef.update(fieldsAndValues: [
        new fs.FieldPath("greeting", "text"),
        "Good Evening after update",
        new fs.FieldPath("greeting", "text_cs"),
        "Dobry vecer po uprave"
      ]);

      var snapshot = await docRef.get();
      var snapshotData = snapshot.data();

      expect(snapshotData["greeting"]["text"], "Good Evening after update");
      expect(snapshotData["greeting"]["text_cs"], "Dobry vecer po uprave");
    });

    test("update with alternating fields as Strings and values", () async {
      var docRef = await ref.add({
        "greeting": {"text": "Hello"}
      });
      await docRef.update(fieldsAndValues: [
        "greeting.text",
        "Hello after update",
        "greeting.text_cs",
        "Ahoj po uprave"
      ]);

      var snapshot = await docRef.get();
      var snapshotData = snapshot.data();

      expect(snapshotData["greeting"]["text"], "Hello after update");
      expect(snapshotData["greeting"]["text_cs"], "Ahoj po uprave");
    });

    test("transaction", () async {
      var docRef = ref.doc("message5");
      await docRef.set({"text": "Hi"});

      await firestore.runTransaction((transaction) async {
        transaction.update(docRef, data: {"text": "Hi from transaction"});
      });

      var snapshot = await docRef.get();
      var snapshotData = snapshot.data();

      expect(snapshotData["text"], "Hi from transaction");
    });

    test("transaction returns updated value", () async {
      var docRef = ref.doc("message6");
      await docRef.set({"text": "Hi"});

      var newValue = await firestore.runTransaction((transaction) async {
        var documentSnapshot = await transaction.get(docRef);
        var value = documentSnapshot.data()["text"] + " val from transaction";
        transaction.update(docRef, data: {"text": value});
        return value;
      });

      expect(newValue, "Hi val from transaction");

      var snapshot = await docRef.get();
      var snapshotData = snapshot.data();

      expect(snapshotData["text"], newValue);
    });

    test("transaction fails", () async {
      // update is before get -> transaction fails
      var docRef = ref.doc("message7");
      await docRef.set({"text": "Hi"});

      expect(firestore.runTransaction((transaction) async {
        transaction.update(docRef, data: {"text": "Some value"});
        await transaction.get(docRef);
      }),
          throwsToString(
              contains('Transactions lookups are invalid after writes.')));
    });

    test("transaction with FieldPath", () async {
      var docRef = ref.doc("message8");
      await docRef.set({
        "description": {"text": "Good morning!!!"}
      });

      await firestore.runTransaction((transaction) async {
        transaction.update(docRef, fieldsAndValues: [
          new fs.FieldPath("description", "text"),
          "Good morning after update!!!",
          new fs.FieldPath("description", "text_cs"),
          "Dobre rano po uprave!!!"
        ]);
      });

      var snapshot = await docRef.get();
      var snapshotData = snapshot.data();

      expect(
          snapshotData["description"]["text"], "Good morning after update!!!");
      expect(snapshotData["description"]["text_cs"], "Dobre rano po uprave!!!");
    });

    test("transaction with alternating fields as Strings and values", () async {
      var docRef = ref.doc("message8");
      await docRef.set({
        "description": {"text": "Good morning!!!"}
      });

      await firestore.runTransaction((transaction) async {
        transaction.update(docRef, fieldsAndValues: [
          "description.text",
          "Good morning after update!!!",
          "description.text_cs",
          "Dobre rano po uprave!!!"
        ]);
      });

      var snapshot = await docRef.get();
      var snapshotData = snapshot.data();

      expect(
          snapshotData["description"]["text"], "Good morning after update!!!");
      expect(snapshotData["description"]["text_cs"], "Dobre rano po uprave!!!");
    });

    test("WriteBatch operations", () async {
      var nycRef = ref.doc("NYC");
      await nycRef.set({"name": "NYC"});
      var sfRef = ref.doc("SF");
      await sfRef.set({"name": "SF", "population": 0});
      var laRef = ref.doc("LA");
      await laRef.set({"name": "LA"});

      var collectionSnapshot = await ref.get();
      expect(collectionSnapshot.size, 3);

      var batch = firestore.batch();
      batch.set(nycRef, {"name": "New York"});
      batch.update(sfRef, data: {"population": 1000000});
      batch.delete(laRef);
      await batch.commit();

      var snapshot = await nycRef.get();
      var snapshotData = snapshot.data();
      expect(snapshotData["name"], "New York");

      snapshot = await sfRef.get();
      snapshotData = snapshot.data();
      expect(snapshotData["population"], 1000000);

      collectionSnapshot = await ref.get();
      expect(collectionSnapshot.size, 2);
    });

    test("WriteBatch operations with FieldPath", () async {
      var sfRef = ref.doc("SF");
      await sfRef.set({
        "name": {"short": "SF"},
        "population": 0
      });

      var batch = firestore.batch();
      batch.update(sfRef, fieldsAndValues: [
        new fs.FieldPath("name", "long"),
        "San Francisco",
        new fs.FieldPath("population"),
        1000000
      ]);
      await batch.commit();

      var snapshot = await sfRef.get();
      var snapshotData = snapshot.data();

      expect(snapshotData["name"]["long"], "San Francisco");
      expect(snapshotData["population"], 1000000);
    });

    test("WriteBatch with alternating fields as Strings and values", () async {
      var sfRef = ref.doc("SF");
      await sfRef.set({
        "name": {"short": "SF"},
        "population": 0
      });

      var batch = firestore.batch();
      batch.update(sfRef, fieldsAndValues: [
        "name.long",
        "San Francisco",
        "population",
        1000000
      ]);
      await batch.commit();

      var snapshot = await sfRef.get();
      var snapshotData = snapshot.data();

      expect(snapshotData["name"]["long"], "San Francisco");
      expect(snapshotData["population"], 1000000);
    });
  });

  group("Quering data", () {
    fs.CollectionReference ref;

    setUp(() async {
      ref = firestore.collection('$testPath/with/index');

      await _deleteCollection(firestore, ref);

      await ref
          .doc("message1")
          .set({"text": "hello", "lang": "en", "new": true});
      await ref.doc("message2").set({
        "text": "hi",
        "lang": "en",
        "description": {"text": "description text"}
      });
      await ref
          .doc("message3")
          .set({"text": "ahoj", "lang": "cs", "new": true});
      await ref.doc("message4").set({"text": "cau", "lang": "cs"});
    });

    tearDown(() async {
      if (ref != null) {
        await _deleteCollection(firestore, ref);
        ref = null;
      }
    });

    test("get document data", () async {
      var docRef = ref.doc("message1");
      var snapshot = await docRef.get();
      expect(snapshot, isNotNull);
      expect(snapshot.exists, isTrue);

      var data = snapshot.data();
      expect(data, isNotNull);
      expect(data["text"], "hello");
    });

    test("get nonexistent document", () async {
      var docRef = ref.doc("message0");
      var snapshot = await docRef.get();
      expect(snapshot.exists, isFalse);
    });

    test("get documents where", () async {
      var snapshot = await ref.where("new", "==", true).get();
      expect(snapshot.size, 2);
    });

    test("get documents where with FieldPath", () async {
      var snapshot = await ref.where(new fs.FieldPath("new"), "==", true).get();
      expect(snapshot.size, 2);
    });

    test("get documents using compound query", () async {
      var snapshot =
          await ref.where("new", "==", true).where("text", "==", "hello").get();
      expect(snapshot.size, 1);
      expect(snapshot.docs.length, 1);
      expect(snapshot.docs[0].data()["text"], "hello");
    });

    test("get all documents", () async {
      var snapshot = await ref.get();
      expect(snapshot.size, 4);
      expect(snapshot.docs, isNotEmpty);
      expect(snapshot.docs.length, snapshot.size);
      expect(
          snapshot.docs[0].data()["text"], anyOf("hello", "hi", "ahoj", "cau"));
    });

    test("onSnapshot", () async {
      StreamSubscription subscription;

      subscription = ref.onSnapshot.listen((snapshot) {
        expect(snapshot, isNotNull);
        expect(snapshot.docChanges, isNotEmpty);

        snapshot.forEach(expectAsync1((doc) {
          expect(doc.id, anyOf("message1", "message2", "message3", "message4"));
          expect(doc.metadata, isNotNull);
        }, count: 4));

        subscription.cancel();
      });
    });

    test("onSnapshot view changes", () async {
      ref.onSnapshot.listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == "added") {
            expect(change.doc.id,
                anyOf("message1", "message2", "message3", "message4"));
          }
        }
      });
    });

    test("onSnapshot document", () async {
      ref.doc("message1").onSnapshot.listen((doc) {
        if (doc.exists) {
          expect(doc.data()["text"], "hello");
        }
      });
    });

    test("onSnapshot document", () async {
      ref.doc("message1").onSnapshot.listen((doc) {
        if (doc.exists) {
          expect(doc.data()["text"], "hello");
        }
      });
    });

    test("order by", () async {
      var snapshot = await ref.orderBy("text").get();

      expect(snapshot.size, 4);
      expect(snapshot.docs[0].data()["text"], "ahoj");
      expect(snapshot.docs[3].data()["text"], "hi");

      snapshot = await ref.orderBy("text", "desc").get();

      expect(snapshot.size, 4);
      expect(snapshot.docs[0].data()["text"], "hi");
      expect(snapshot.docs[3].data()["text"], "ahoj");
    });

    test("limit", () async {
      var snapshot = await ref.get();
      expect(snapshot.size, 4);

      snapshot = await ref.limit(2).get();
      expect(snapshot.size, 2);
    });

    test("get documents where with limit", () async {
      var snapshot = await ref.where("new", "==", true).limit(1).get();
      expect(snapshot.size, 1);
    });

    // !!!IMPORTANT: You need to build index for lang and text under `index`
    // collection to be able to run these tests.
    // (You can do this in Firebase console)
    test("startAt", () async {
      var snapshot = await ref
          .orderBy("lang")
          .orderBy("text")
          .startAt(fieldValues: ["cs", "cau"]).get();
      expect(snapshot.size, 3);
      expect(snapshot.docs[0].data()["text"], "cau");
      expect(snapshot.docs[2].data()["text"], "hi");

      snapshot = await ref.orderBy("description").startAt(fieldValues: [
        {"text": "description text"}
      ]).get();

      expect(snapshot.size, 1);
      expect(
          snapshot.docs[0].data()["description"], {"text": "description text"});

      var message2Snapshot = await ref.doc("message2").get();
      snapshot =
          await ref.orderBy("text").startAt(snapshot: message2Snapshot).get();

      // message2 text = "hi" => it is the last one
      expect(snapshot.size, 1);
      expect(snapshot.docs[0].data()["text"], "hi");
    });

    test("startAfter", () async {
      var snapshot = await ref
          .orderBy("lang")
          .orderBy("text")
          .startAfter(fieldValues: ["cs", "cau"]).get();
      expect(snapshot.size, 2);
      expect(snapshot.docs[0].data()["text"], "hello");
      expect(snapshot.docs[1].data()["text"], "hi");

      snapshot = await ref.orderBy("description").startAfter(fieldValues: [
        {"text": "description text"}
      ]).get();

      expect(snapshot.empty, isTrue);

      var message2Snapshot = await ref.doc("message2").get();
      snapshot = await ref
          .orderBy("text")
          .startAfter(snapshot: message2Snapshot)
          .get();

      // message2 text = "hi"
      expect(snapshot.empty, isTrue);
    });

    test("endBefore", () async {
      var snapshot = await ref
          .orderBy("lang")
          .orderBy("text")
          .endBefore(fieldValues: ["en", "hello"]).get();
      expect(snapshot.size, 2);
      expect(snapshot.docs[0].data()["text"], "ahoj");
      expect(snapshot.docs[1].data()["text"], "cau");

      snapshot = await ref.orderBy("description").endBefore(fieldValues: [
        {"text": "description text"}
      ]).get();

      expect(snapshot.empty, isTrue);

      var message2Snapshot = await ref.doc("message2").get();
      snapshot =
          await ref.orderBy("text").endBefore(snapshot: message2Snapshot).get();

      // message2 text = "hi"
      expect(snapshot.size, 3);
      expect(snapshot.docs[0].data()["text"], "ahoj");
      expect(snapshot.docs[2].data()["text"], "hello");
    });

    test("endAt", () async {
      var snapshot = await ref
          .orderBy("lang")
          .orderBy("text")
          .endAt(fieldValues: ["en", "hello"]).get();
      expect(snapshot.size, 3);
      expect(snapshot.docs[0].data()["text"], "ahoj");
      expect(snapshot.docs[2].data()["text"], "hello");

      snapshot = await ref.orderBy("description").endAt(fieldValues: [
        {"text": "description text"}
      ]).get();

      expect(snapshot.size, 1);
      expect(
          snapshot.docs[0].data()["description"], {"text": "description text"});

      var message2Snapshot = await ref.doc("message2").get();
      snapshot =
          await ref.orderBy("text").endAt(snapshot: message2Snapshot).get();

      // message2 text = "hi"
      expect(snapshot.size, 4);
      expect(snapshot.docs[0].data()["text"], "ahoj");
      expect(snapshot.docs[3].data()["text"], "hi");
    });
  });
}
