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
  var supdateF = f.child('foo').update('foobar');
  return supdateF.then((foo){print('UPDATED STRING EM!');})
                 .catchError((foo){print(foo);});
}

testChild(Firebase f) {
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
             .then((Future) => updateStringTest(f));

  /*
  var childSetF = child.set('foobar');
  childSetF.then((foo){
    print('SET CHILD!');
    var removeF = child.remove();
    removeF.then((foo) {
      print('REMOVED CHILD!');
    });
   });

  var pushRef = child.push();
  pushRef.set('HAHA');
  */
  print('HELLO!!!!');
}