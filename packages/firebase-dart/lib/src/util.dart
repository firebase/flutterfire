library firebase.util;

import 'dart:js';

jsify(value) {
  if (value is Map || value is Iterable) {
    return new JsObject.jsify(value);
  }
  return value;
}
