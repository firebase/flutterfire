library firebase.auth_response;

import 'dart:js';

/**
 * A successful authentication response.
 */
class AuthResponse {
  final int expires;
  final String auth;

  AuthResponse(JsObject response)
      : expires = response['expires'],
        auth = response['auth'];

  String toString() => 'expires: $expires, auth: $auth';
}
