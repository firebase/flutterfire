library firebase.auth_response;

import 'dart:js';

/**
 * A successful authentication response.
 */
class AuthResponse {
  final int expires;
  final JsObject auth;

  AuthResponse(JsObject response)
      : expires = response['expires'],
        auth = response['auth'];

  String toString() => 'expires: $expires, auth: $auth';
}
