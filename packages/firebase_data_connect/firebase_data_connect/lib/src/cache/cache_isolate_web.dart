// Copyright 2026 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Stand-ins for the dart:isolate and path_provider APIs used by the background
// cache isolate, which only runs on native platforms: on the web, the cache
// never starts it, so none of these are called. The analyzer only checks
// cache.dart against cache_isolate_io.dart, so keep these in sync with what
// cache.dart uses; web builds fail otherwise.

class Isolate {
  static Future<Isolate> spawn<T>(
    void Function(T message) entryPoint,
    T message,
  ) => throw UnsupportedError(_unsupported);
}

abstract class SendPort {
  void send(Object? message);
}

abstract class ReceivePort implements Stream<dynamic> {
  factory ReceivePort() => throw UnsupportedError(_unsupported);

  SendPort get sendPort;

  void close();
}

Future<Never> getApplicationDocumentsDirectory() =>
    throw UnsupportedError(_unsupported);

const _unsupported = 'The background cache isolate is not supported on web.';
