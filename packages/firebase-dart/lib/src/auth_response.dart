library firebase.auth_response;

import 'dart:convert' show JSON;
import 'dart:js';

/**
 * Converts authData response from JsObject to native Dart object.
 */
dynamic decodeAuthData(JsObject authData) {
  var json = context['JSON'].callMethod('stringify', [authData]);
  return JSON.decode(json);
}
