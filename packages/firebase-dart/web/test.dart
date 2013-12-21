import 'dart:async';
import 'firebase.dart';

Future authTest(Firebase f) {
  var authF = f.auth('foobar');
  return authF.then((foo){print('AUTH EM! ' + foo); f.unauth();})
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
  var testRef = f.child("ZZZ");
  print('TESTING PRIORITIES');
  return testRef.setWithPriority(1, 1).then((foo) {
    testRef.setPriority(100);
  });
}

Future testTransaction(Firebase f) {
  var testRef = f.child("ZZZ");
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

void testChild(Firebase f) {
  var child = f.child('trad');
  print('CHILD NAME: ' + child.name());

  var parent = child.parent();
  print('PARENT NAME: ' + parent.name());

  var root = child.root();
  print('ROOT: ');
  print(root);

  f.remove();
}

main() {
  var f = new Firebase('https://anant.firebaseio.com/dart');

  testChild(f);
  authTest(f).then((Future) => setTest(f))
             .then((Future) => setStringTest(f))
             .then((Future) => updateTest(f))
             .then((Future) => updateStringTest(f))
             .then((Future) => testPush(f))
             .then((Future) => testPriorities(f))
             .then((Future) => testTransaction(f));

  print('HELLO!!!!');
}