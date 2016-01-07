library firebase_io;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

export 'src/encode.dart';
export 'src/jwt.dart' show createFirebaseJwtToken;

class FirebaseClient {
  final String credential;

  FirebaseClient(this.credential);

  const FirebaseClient.anonymous() : credential = null;

  Future<dynamic> get(Uri uri) => send('GET', uri);

  Future<dynamic> put(Uri uri, json) => send('PUT', uri, json: json);

  Future<dynamic> post(Uri uri, json) => send('POST', uri, json: json);

  Future<dynamic> delete(Uri uri) => send('DELETE', uri);

  Future<dynamic> send(String method, Uri uri, {json}) async {
    var params = new Map.from(uri.queryParameters);

    if (credential != null) {
      params['auth'] = credential;
    }

    uri = uri.replace(queryParameters: params);

    var request = new Request(method, uri);

    if (json != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = JSON.encode(json);
    }

    var client = new IOClient();

    Response response;
    try {
      var streamedResponse = await client.send(request);
      response = await Response.fromStream(streamedResponse);
    } finally {
      client.close();
    }

    var bodyJson;
    try {
      bodyJson = JSON.decode(response.body);
    } on FormatException {
      var contentType = response.headers['content-type'];
      if (contentType != null && !contentType.contains('application/json')) {
        // TODO: throw a real error here
        throw 'Returned value was not JSON. Did the uri end with ".json"?';
      }
      rethrow;
    }

    if (response.statusCode != 200) {
      if (bodyJson is Map) {
        var error = bodyJson['error'];
        if (error != null) {
          // TODO: wrap this in something helpful?
          throw error;
        }
      }
      throw bodyJson;
    }

    return bodyJson;
  }
}
