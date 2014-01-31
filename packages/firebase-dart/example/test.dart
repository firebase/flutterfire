import 'dart:async';
import 'package:firebase/firebase.dart';

Future authFailTest(Firebase f) {
  var authF = f.auth('foobar');
  return authF.then((foo){print('AUTH EM! $foo'); f.unauth();})
              .catchError((foo){print(foo);});
}

Future authPassTest(Firebase f) {
  var authF = f.auth('');
  return authF.then((foo){print('AUTH SUCCEEDED! $foo'); f.unauth();})
              .catchError((foo){print(foo);});
}

Future setTest(Firebase f) {
  var setF = f.set({'foo': 'bar'});
  return setF.then((foo){print('SET EM! ');});
}

Future setStringTest(Firebase f) {
  var ssetF = f.child('bar').set('foo');
  return ssetF.then((foo){print('SET STRING EM!');});
}

Future updateTest(Firebase f) {
  var updateF = f.update({'foo': 'oof'});
  return updateF.then((foo){print('UPDATED EM!');});
}

Future updateStringTest(Firebase f) {
  try {
    var supdateF = f.child('foo').update('foobar');
  } catch(e) {
    var c = new Completer();
    Timer.run(() {
      print('TESTED UPDATE STRING!');
      c.complete(null);
    });
    return c.future;
  }
}

Future testPush(Firebase f) {
  var pushRef = f.push();
  print('TESTING PUSH!');
  return pushRef.set('HAHA');
}

Future testPriorities(Firebase f) {
  var testRef = f.child('ZZZ');
  print('TESTING PRIORITIES');
  return testRef.setWithPriority(1, 1).then((foo) {
    testRef.setPriority(100);
  });
}

Future testTransaction(Firebase f) {
  var testRef = f.child('ZZZ');
  return testRef.transaction((curVal) {
    if (curVal == null) {
      return 0;
    } else {
      return curVal + 1;
    }
  }).then((var status) {
    print('TESTED TRANSACTIONS! GOT');
    print(status['snapshot'].val());
  });
}

Future testValue(Firebase f) {
  var c = new Completer();
  f.onValue.listen((Event e) {
    print('GOT VALUE!');
    print(e.snapshot.val());
    c.complete(null);
  });
  return c.future;
}

void testChild(Firebase f) {
  var child = f.child('trad');
  print('CHILD NAME: ${child.name()}');

  var parent = child.parent();
  print('PARENT NAME: ${parent.name()}');

  var root = child.root();
  print('ROOT: ');
  print(root);

  f.remove();
}

main() {
  // NOTE: auth() doesn't work on demo Firebases.
  var f = new Firebase('https://dart-test.firebaseio-demo.com/test/');

  testChild(f);
  authFailTest(f).then((_) => authPassTest(f))
             .then((_) => setTest(f))
             .then((_) => setStringTest(f))
             .then((_) => updateTest(f))
             .then((_) => updateStringTest(f))
             .then((_) => testPush(f))
             .then((_) => testPriorities(f))
             .then((_) => testTransaction(f))
             .then((_) => testValue(f));

  print('HELLO!!!!');
}