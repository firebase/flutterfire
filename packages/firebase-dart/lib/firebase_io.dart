import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

/// FirebaseClient wraps a REST client for a Firebase realtime database.
///
/// The client supports authentication and GET, PUT, POST, DELETE
/// and PATCH methods.
class FirebaseClient {
  /// Auth credential.
  final String credential;
  final BaseClient _client;

  /// Creates a new FirebaseClient with [credential] and optional [client].
  ///
  /// For credential you can either use Firebase app's secret or
  /// an authentication token.
  /// See: <https://firebase.google.com/docs/reference/rest/database/user-auth>.
  FirebaseClient(this.credential, {BaseClient client})
      : _client = client ?? Client();

  /// Creates a new anonymous FirebaseClient with optional [client].
  FirebaseClient.anonymous({BaseClient client})
      : credential = null,
        _client = client ?? Client();

  /// Reads data from database using a HTTP GET request.
  /// The response from a successful request contains a data being retrieved.
  ///
  /// See: <https://firebase.google.com/docs/reference/rest/database/#section-get>.
  Future<dynamic> get(uri) => send('GET', uri);

  /// Writes or replaces data in database using a HTTP PUT request.
  /// The response from a successful request contains a data being written.
  ///
  /// See: <https://firebase.google.com/docs/reference/rest/database/#section-put>.
  Future<dynamic> put(uri, json) => send('PUT', uri, json: json);

  /// Pushes data to database using a HTTP POST request.
  /// The response from a successful request contains a key of the new data
  /// being added.
  ///
  /// See: <https://firebase.google.com/docs/reference/rest/database/#section-post>.
  Future<dynamic> post(uri, json) => send('POST', uri, json: json);

  /// Updates specific children at a location without overwriting existing data
  /// using a HTTP PATCH request.
  /// The response from a successful request contains a data being written.
  ///
  /// See: <https://firebase.google.com/docs/reference/rest/database/#section-patch>.
  Future<dynamic> patch(uri, json) => send('PATCH', uri, json: json);

  /// Deletes data from database using a HTTP DELETE request.
  /// The response from a successful request contains a JSON with [:null:].
  ///
  /// See: <https://firebase.google.com/docs/reference/rest/database/#section-delete>.
  Future<dynamic> delete(uri) => send('DELETE', uri);

  /// Creates a request with a HTTP [method], [url] and optional data.
  /// The [url] can be either a `String` or `Uri`.
  Future<dynamic> send(String method, url, {json}) async {
    Uri uri = url is String ? Uri.parse(url) : url;

    var request = Request(method, uri);
    if (credential != null) {
      request.headers['Authorization'] = 'Bearer $credential';
    }

    if (json != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(json);
    }

    var streamedResponse = await _client.send(request);
    var response = await Response.fromStream(streamedResponse);

    Object bodyJson;
    try {
      bodyJson = jsonDecode(response.body);
    } on FormatException {
      var contentType = response.headers['content-type'];
      if (contentType != null && !contentType.contains('application/json')) {
        throw Exception(
            "Returned value was not JSON. Did the uri end with '.json'?");
      }
      rethrow;
    }

    if (response.statusCode != 200) {
      if (bodyJson is Map) {
        var error = bodyJson['error'];
        if (error != null) {
          throw FirebaseClientException(response.statusCode, error.toString());
        }
      }

      throw FirebaseClientException(response.statusCode, bodyJson.toString());
    }

    return bodyJson;
  }

  /// Closes the client and cleans up any associated resources.
  void close() => _client.close();
}

class FirebaseClientException implements Exception {
  final int statusCode;
  final String message;

  FirebaseClientException(this.statusCode, this.message);

  @override
  String toString() => '$message ($statusCode)';
}
