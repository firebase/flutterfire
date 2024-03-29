// Copyright 2024 Google LLC
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

part of firebase_vertex_ai;

const _defaultLocation = 'us-central1';

class FirebaseVertexAI extends FirebasePluginPlatform {
  FirebaseVertexAI._({required this.app, required this.options})
      : super(app.name, 'plugins.flutter.io/firebase_vertex_ai');

  /// The [FirebaseApp] for this current [FirebaseVertexAI] instance.
  FirebaseApp app;

  RequestOptions options;

  static final Map<String, FirebaseVertexAI> _cachedInstances = {};

  /// Returns an instance using the default [FirebaseApp].
  static FirebaseVertexAI get instance {
    return FirebaseVertexAI.instanceFor(
      app: Firebase.app(),
    );
  }

  /// Returns an instance using a specified [FirebaseApp].
  ///
  /// If [app] is not provided, the default Firebase app will be used.
  static FirebaseVertexAI instanceFor({
    FirebaseApp? app,
    RequestOptions? options,
  }) {
    app ??= Firebase.app();

    if (_cachedInstances.containsKey(app.name)) {
      return _cachedInstances[app.name]!;
    }

    options ??=
        RequestOptions(apiKey: app.options.apiKey, location: _defaultLocation);
    FirebaseVertexAI newInstance =
        FirebaseVertexAI._(app: app, options: options);
    _cachedInstances[app.name] = newInstance;

    return newInstance;
  }

  GenerativeModel generativeModel(
      {required String modelName,
      List<SafetySetting>? safetySettings,
      GenerationConfig? generationConfig}) {
    return GenerativeModel(
        modelName: modelName,
        app: app,
        apiKey: options.apiKey,
        location: options.location,
        safetySettings: safetySettings,
        generationConfig: generationConfig);
  }
}

class RequestOptions {
  RequestOptions({
    required this.apiKey,
    required this.location,
  });

  final String apiKey;
  final String location;
}
