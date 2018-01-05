@JS()
library firebase.js_interop;

import 'package:js/js.dart';
import 'package:js/js_util.dart' as util;

@JS("JSON.stringify")
external String stringify(Object obj);

@JS("Object.keys")
external List<String> objectKeys(Object obj);

@JS("Date")
class JsDate {
  // https://github.com/dart-lang/linter/issues/864
  // ignore: avoid_unused_constructor_parameters
  external factory JsDate(Object millisecondsSinceEpochOr8601String);
  external int getTime();
}

DateTime dartifyDate(Object jsObject) {
  if (util.hasProperty(jsObject, "toDateString")) {
    var date = jsObject as JsDate;
    return new DateTime.fromMillisecondsSinceEpoch(date.getTime());
  }
  return null;
}

Object jsifyDate(Object dartObject) {
  if (dartObject is DateTime) {
    try {
      return new JsDate(dartObject.toIso8601String());
    } on TypeError {
// Likely running on Dartium.
// Work-around until Dartium support is dropped
      return dartObject;
    }
  }
  return null;
}
