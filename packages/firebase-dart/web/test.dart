import 'firebase.dart';

main() {
  var f = new Firebase('https://anant.firebaseio.com/dart');
  var done = f.set('bar');
  done.then((var foo){print('SET EM!');});
  print('HELOO!!!!');
}