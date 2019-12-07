@JS()
library firebase.js_interop;

import 'package:js/js.dart';
import 'package:js/js_util.dart' as util;

@JS('JSON.stringify')
external String stringify(Object obj);

@JS('Object.keys')
external List<String> objectKeys(Object obj);

@JS('Array.from')
external Object toJSArray(List source);

DateTime dartifyDate(Object jsObject) {
  if (util.hasProperty(jsObject, 'toDateString')) {
    try {
      var date = jsObject as dynamic;
      return DateTime.fromMillisecondsSinceEpoch(date.getTime());
    } on NoSuchMethodError {
      // so it's not a JsDate!
      return null;
    }
  }
  return null;
}
