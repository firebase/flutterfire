// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:dart_cloud_functions/dart_cloud_functions.dart';
import 'package:dart_cloud_functions/src/context.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// The firebase_core test mocks give every app this project ID.
const _mockProjectId = '123';

Matcher _throwsCode(String code) {
  return throwsA(
    isA<DartFirebaseFunctionsException>().having((e) => e.code, 'code', code),
  );
}

/// A token provider that always returns [context].
CallableContextProvider _fixedContext([
  CallableContext context = const CallableContext(),
]) =>
    ({required limitedUseAppCheckToken}) async => context;

/// A client that never responds and records its requests and whether it was
/// closed.
///
/// Unlike `MockClient`, which copies each request, it keeps the request
/// itself, so tests can check its abort trigger.
class _HangingClient extends http.BaseClient {
  final requests = <http.BaseRequest>[];
  bool closed = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    requests.add(request);
    return Completer<http.StreamedResponse>().future;
  }

  @override
  void close() {
    closed = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  late FirebaseApp app;

  setUpAll(() async {
    app = await Firebase.initializeApp();
  });

  // Flutter tests run as Android by default, so only the
  // useFunctionsEmulator() tests turn on the Android host mapping.
  // Without a contextProvider, calls carry no tokens.
  DartFirebaseFunctions emulatorFunctions(
    MockClientHandler handler, {
    bool automaticHostMapping = false,
    CallableContextProvider? contextProvider,
  }) {
    return DartFirebaseFunctions.withHttpClient(
      MockClient(handler),
      app: app,
      contextProvider: contextProvider ?? _fixedContext(),
    )..useFunctionsEmulator(
      'localhost',
      5001,
      automaticHostMapping: automaticHostMapping,
    );
  }

  // Like emulatorFunctions(), but the handler gets the request itself,
  // including its abort trigger, and answers with a stream.
  DartFirebaseFunctions streamingFunctions(
    MockClientStreamHandler handler, {
    CallableContextProvider? contextProvider,
  }) {
    return DartFirebaseFunctions.withHttpClient(
      MockClient.streaming(handler),
      app: app,
      contextProvider: contextProvider ?? _fixedContext(),
    )..useFunctionsEmulator('localhost', 5001, automaticHostMapping: false);
  }

  /// A response that sends [chunks] of server-sent events, one after another.
  http.StreamedResponse sse(List<String> chunks, {int statusCode = 200}) {
    return http.StreamedResponse(
      Stream.fromIterable(chunks.map(utf8.encode)),
      statusCode,
    );
  }

  group('instanceFor()', () {
    test('returns one cached instance per app and region', () {
      expect(
        DartFirebaseFunctions.instanceFor(app: app),
        same(DartFirebaseFunctions.instance),
      );
      expect(
        DartFirebaseFunctions.instanceFor(app: app, region: 'europe-west1'),
        isNot(same(DartFirebaseFunctions.instance)),
      );
    });
  });

  group('DartHttpsCallable.call()', () {
    test('posts a callable request and returns the result', () async {
      late http.Request sent;
      final functions = emulatorFunctions((request) async {
        sent = request;
        return http.Response('{"result":["Apple"]}', 200);
      });

      final result = await functions.httpsCallable('listFruit').call({'n': 1});

      expect(result.data, ['Apple']);
      expect(sent.method, 'POST');
      expect(
        sent.url.toString(),
        'http://localhost:5001/$_mockProjectId/us-central1/listFruit',
      );
      expect(sent.headers['Content-Type'], startsWith('application/json'));
      expect(jsonDecode(sent.body), {
        'data': {'n': 1},
      });
    });

    test('uses a callable URL as is', () async {
      late Uri sentUrl;
      final functions = emulatorFunctions((request) async {
        sentUrl = request.url;
        return http.Response('{"result":null}', 200);
      });

      await functions
          .httpsCallableFromUrl('https://listfruits-abc123-uc.a.run.app')
          .call();

      expect(sentUrl.toString(), 'https://listfruits-abc123-uc.a.run.app');
    });

    test('throws the error from an HttpsError envelope', () async {
      final functions = emulatorFunctions((_) async {
        return http.Response(
          '{"error":{"message":"Nope.","status":"PERMISSION_DENIED"}}',
          403,
        );
      });

      await expectLater(
        functions.httpsCallable('listFruit').call(),
        throwsA(
          isA<DartFirebaseFunctionsException>()
              .having((e) => e.code, 'code', 'permission-denied')
              .having((e) => e.message, 'message', 'Nope.')
              .having((e) => e.plugin, 'plugin', 'dart_cloud_functions'),
        ),
      );
    });

    test('maps a timeout to deadline-exceeded', () async {
      final never = Completer<http.Response>();
      final functions = emulatorFunctions((_) => never.future);

      await expectLater(
        functions
            .httpsCallable(
              'listFruit',
              options: const DartHttpsCallableOptions(
                timeout: Duration(milliseconds: 10),
              ),
            )
            .call(),
        _throwsCode('deadline-exceeded'),
      );
    });

    test(
      'aborts a timed-out request without closing the shared client',
      () async {
        final client = _HangingClient();
        final functions = DartFirebaseFunctions.withHttpClient(
          client,
          app: app,
          contextProvider: _fixedContext(),
        )..useFunctionsEmulator('localhost', 5001, automaticHostMapping: false);

        await expectLater(
          functions
              .httpsCallable(
                'listFruit',
                options: const DartHttpsCallableOptions(
                  timeout: Duration(milliseconds: 10),
                ),
              )
              .call(),
          _throwsCode('deadline-exceeded'),
        );

        final request = client.requests.single as http.Abortable;
        await expectLater(request.abortTrigger, completes);
        expect(client.closed, isFalse);
      },
    );

    test('maps a network failure to unavailable', () async {
      final functions = emulatorFunctions((request) async {
        throw http.ClientException('Connection refused', request.url);
      });

      await expectLater(
        functions.httpsCallable('listFruit').call(),
        _throwsCode('unavailable'),
      );
    });
  });

  group('Auth token', () {
    test('is sent as a Bearer token', () async {
      late http.Request sent;
      final functions = emulatorFunctions(
        (request) async {
          sent = request;
          return http.Response('{"result":null}', 200);
        },
        contextProvider: _fixedContext(
          const CallableContext(authToken: 'id-token'),
        ),
      );

      await functions.httpsCallable('listFruit').call();

      expect(sent.headers['Authorization'], 'Bearer id-token');
    });

    test('is left out when nobody is signed in', () async {
      late http.Request sent;
      final functions = emulatorFunctions((request) async {
        sent = request;
        return http.Response('{"result":null}', 200);
      });

      await functions.httpsCallable('listFruit').call();

      expect(sent.headers, isNot(contains('Authorization')));
    });

    test('is fetched again for every call', () async {
      final tokens = ['first', 'second'].iterator;
      final sentTokens = <String?>[];
      final functions = emulatorFunctions(
        (request) async {
          sentTokens.add(request.headers['Authorization']);
          return http.Response('{"result":null}', 200);
        },
        contextProvider: ({required limitedUseAppCheckToken}) async {
          tokens.moveNext();
          return CallableContext(authToken: tokens.current);
        },
      );

      final callable = functions.httpsCallable('listFruit');
      await callable.call();
      await callable.call();

      expect(sentTokens, ['Bearer first', 'Bearer second']);
    });

    test('fails the call with unknown when it cannot be fetched', () async {
      var requests = 0;
      final functions = emulatorFunctions(
        (_) async {
          requests++;
          return http.Response('{"result":null}', 200);
        },
        contextProvider: ({required limitedUseAppCheckToken}) async =>
            throw FirebaseException(
              plugin: 'firebase_auth',
              code: 'network-request-failed',
              message: 'A network error has occurred.',
            ),
      );

      await expectLater(
        functions.httpsCallable('listFruit').call(),
        throwsA(
          isA<DartFirebaseFunctionsException>()
              .having((e) => e.code, 'code', 'unknown')
              .having(
                (e) => e.message,
                'message',
                'A network error has occurred.',
              ),
        ),
      );
      expect(requests, 0);
    });

    test('is never sent over HTTP to a non-loopback host', () async {
      var requests = 0;
      final functions = emulatorFunctions(
        (_) async {
          requests++;
          return http.Response('{"result":null}', 200);
        },
        contextProvider: _fixedContext(
          const CallableContext(authToken: 'id-token'),
        ),
      );

      await expectLater(
        functions
            .httpsCallableFromUrl('http://192.168.1.20:5001/listFruit')
            .call(),
        _throwsCode('unauthenticated'),
      );
      expect(requests, 0);
    });

    test('is sent over HTTP to a non-loopback host with '
        'allowInsecureTokenAttachment in debug builds', () async {
      late http.Request sent;
      final functions = emulatorFunctions(
        (request) async {
          sent = request;
          return http.Response('{"result":null}', 200);
        },
        contextProvider: _fixedContext(
          const CallableContext(authToken: 'id-token'),
        ),
      )..allowInsecureTokenAttachment = true;

      await functions
          .httpsCallableFromUrl('http://192.168.1.20:5001/listFruit')
          .call();

      expect(sent.headers['Authorization'], 'Bearer id-token');
    });
  });

  group('App Check token', () {
    test('is sent as X-Firebase-AppCheck', () async {
      late http.Request sent;
      final functions = emulatorFunctions(
        (request) async {
          sent = request;
          return http.Response('{"result":null}', 200);
        },
        contextProvider: _fixedContext(
          const CallableContext(appCheckToken: 'app-check-token'),
        ),
      );

      await functions.httpsCallable('listFruit').call();

      expect(sent.headers['X-Firebase-AppCheck'], 'app-check-token');
    });

    test('is requested as limited-use only when the option is set', () async {
      final requested = <bool>[];
      final functions = emulatorFunctions(
        (_) async => http.Response('{"result":null}', 200),
        contextProvider: ({required limitedUseAppCheckToken}) async {
          requested.add(limitedUseAppCheckToken);
          return const CallableContext();
        },
      );

      await functions.httpsCallable('listFruit').call();
      await functions
          .httpsCallable(
            'listFruit',
            options: const DartHttpsCallableOptions(
              limitedUseAppCheckToken: true,
            ),
          )
          .call();

      expect(requested, [false, true]);
    });
  });

  group('DartHttpsCallable.stream()', () {
    test('emits chunks, then the result', () async {
      final functions = streamingFunctions(
        (request, body) async => sse([
          'data: {"message":"Apple"}\n\n',
          ': ping\n\n',
          'data: {"message":"Banana"}\n\ndata: {"result":2}\n\n',
        ]),
      );

      final responses = await functions
          .httpsCallable('listFruit')
          .stream<String, int>()
          .toList();

      expect(responses, [
        isA<DartChunk<String, int>>().having(
          (r) => r.partialData,
          'partialData',
          'Apple',
        ),
        isA<DartChunk<String, int>>().having(
          (r) => r.partialData,
          'partialData',
          'Banana',
        ),
        isA<DartResult<String, int>>().having((r) => r.result.data, 'data', 2),
      ]);
    });

    test('asks for an event stream with the data and the tokens', () async {
      late http.BaseRequest sent;
      late String sentBody;
      final functions = streamingFunctions(
        (request, body) async {
          sent = request;
          sentBody = await body.bytesToString();
          return sse(['data: {"result":null}\n\n']);
        },
        contextProvider: _fixedContext(
          const CallableContext(authToken: 'id-token'),
        ),
      );

      await functions.httpsCallable('listFruit').stream<Object?, Object?>({
        'type': 'number',
      }).drain<void>();

      expect(sent.headers, containsPair('Accept', 'text/event-stream'));
      expect(sent.headers, containsPair('Authorization', 'Bearer id-token'));
      expect(jsonDecode(sentBody), {
        'data': {'type': 'number'},
      });
    });

    test('maps an error status before the stream starts', () async {
      final functions = streamingFunctions(
        (request, body) async => sse(['Not found'], statusCode: 404),
      );

      await expectLater(
        functions.httpsCallable('doesNotExist').stream<Object?, Object?>(),
        emitsError(
          isA<DartFirebaseFunctionsException>().having(
            (e) => e.code,
            'code',
            'not-found',
          ),
        ),
      );
    });

    test('emits an error event as an exception', () async {
      final functions = streamingFunctions(
        (request, body) async => sse([
          'data: {"message":"Apple"}\n\n',
          'data: {"error":{"status":"INVALID_ARGUMENT","message":"Bad."}}\n\n',
        ]),
      );

      await expectLater(
        functions.httpsCallable('listFruit').stream<String, Object?>(),
        emitsInOrder([
          isA<DartChunk<String, Object?>>(),
          emitsError(
            isA<DartFirebaseFunctionsException>().having(
              (e) => e.code,
              'code',
              'invalid-argument',
            ),
          ),
        ]),
      );
    });

    test('aborts the request when the listener cancels', () async {
      // The response stays open after the first chunk.
      final openBody = StreamController<List<int>>()
        ..add(utf8.encode('data: {"message":"Apple"}\n\n'));
      addTearDown(openBody.close);
      late http.Abortable request;
      final functions = streamingFunctions((sent, body) async {
        request = sent as http.Abortable;
        return http.StreamedResponse(openBody.stream, 200);
      });

      final first = await functions
          .httpsCallable('listFruit')
          .stream<String, int>()
          .first;

      expect(first, isA<DartChunk<String, int>>());
      await expectLater(request.abortTrigger, completes);
    });

    test(
      'fails with deadline-exceeded when nothing arrives, and aborts',
      () async {
        // The response starts but never sends anything.
        final silentBody = StreamController<List<int>>();
        addTearDown(silentBody.close);
        late http.Abortable request;
        final functions = streamingFunctions((sent, body) async {
          request = sent as http.Abortable;
          return http.StreamedResponse(silentBody.stream, 200);
        });

        await expectLater(
          functions
              .httpsCallable(
                'listFruit',
                options: const DartHttpsCallableOptions(
                  timeout: Duration(milliseconds: 20),
                ),
              )
              .stream<Object?, Object?>(),
          emitsError(
            isA<DartFirebaseFunctionsException>().having(
              (e) => e.code,
              'code',
              'deadline-exceeded',
            ),
          ),
        );
        await expectLater(request.abortTrigger, completes);
      },
      testOn: 'vm',
    );

    test('keeps a long stream going while heartbeats arrive', () async {
      Stream<List<int>> heartbeatsThenResult() async* {
        // 6 × 20 ms is longer than the 60 ms timeout, but no gap is.
        for (var i = 0; i < 6; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          yield utf8.encode(': ping\n\n');
        }
        yield utf8.encode('data: {"result":"done"}\n\n');
      }

      final functions = streamingFunctions(
        (request, body) async =>
            http.StreamedResponse(heartbeatsThenResult(), 200),
      );

      final responses = await functions
          .httpsCallable(
            'listFruit',
            options: const DartHttpsCallableOptions(
              timeout: Duration(milliseconds: 60),
            ),
          )
          .stream<Object?, String>()
          .toList();

      expect(responses.single, isA<DartResult<Object?, String>>());
    }, testOn: 'vm');

    test('has no timeout on web', () async {
      Stream<List<int>> slowResult() async* {
        await Future<void>.delayed(const Duration(milliseconds: 60));
        yield utf8.encode('data: {"result":"done"}\n\n');
      }

      final functions = streamingFunctions(
        (request, body) async => http.StreamedResponse(slowResult(), 200),
      );

      final responses = await functions
          .httpsCallable(
            'listFruit',
            options: const DartHttpsCallableOptions(
              timeout: Duration(milliseconds: 20),
            ),
          )
          .stream<Object?, String>()
          .toList();

      expect(responses.single, isA<DartResult<Object?, String>>());
    }, testOn: 'browser');
  });

  group('useFunctionsEmulator()', () {
    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    Future<Uri> sentUrlOn(TargetPlatform platform) async {
      debugDefaultTargetPlatformOverride = platform;
      late Uri sentUrl;
      final functions = emulatorFunctions((request) async {
        sentUrl = request.url;
        return http.Response('{"result":null}', 200);
      }, automaticHostMapping: true);
      await functions.httpsCallable('listFruit').call();
      return sentUrl;
    }

    test('maps localhost to 10.0.2.2 on Android', () async {
      expect((await sentUrlOn(TargetPlatform.android)).host, '10.0.2.2');
    }, testOn: 'vm');

    test('keeps localhost on web, even in an Android browser', () async {
      expect((await sentUrlOn(TargetPlatform.android)).host, 'localhost');
    }, testOn: 'browser');

    test('keeps localhost on other platforms', () async {
      expect((await sentUrlOn(TargetPlatform.macOS)).host, 'localhost');
    });
  });
}
