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

part of firebase_vertexai;

const _defaultLocation = 'us-central1';

/// Default timeout duration, 30 minutes in millisecond
const int defaultTimeout = 1800000;

/// The entrypoint for [FirebaseVertexAI].
class FirebaseVertexAI extends FirebasePluginPlatform {
  FirebaseVertexAI._(
      {required this.app,
      required this.options,
      required this.location,
      this.appCheck})
      : super(app.name, 'plugins.flutter.io/firebase_vertexai');

  /// The [FirebaseApp] for this current [FirebaseVertexAI] instance.
  FirebaseApp app;

  /// The optional [FirebaseAppCheck] for this current [FirebaseVertexAI] instance.
  /// https://firebase.google.com/docs/app-check
  FirebaseAppCheck? appCheck;

  /// Configuration parameters for sending requests to the backend.
  RequestOptions options;

  /// The service location for this [FirebaseVertexAI] instance.
  String location;

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
  /// If pass in [appCheck], request session will get protected from abusing.
  static FirebaseVertexAI instanceFor({
    FirebaseApp? app,
    FirebaseAppCheck? appCheck,
    RequestOptions? options,
    String? location,
  }) {
    app ??= Firebase.app();

    if (_cachedInstances.containsKey(app.name)) {
      return _cachedInstances[app.name]!;
    }

    options ??=
        RequestOptions(timeout: const Duration(milliseconds: defaultTimeout));

    location ??= _defaultLocation;

    FirebaseVertexAI newInstance = FirebaseVertexAI._(
        app: app, options: options, location: location, appCheck: appCheck);
    _cachedInstances[app.name] = newInstance;

    return newInstance;
  }

  /// Create a [GenerativeModel] backed by the generative model named [model].
  ///
  /// The [model] argument can be a model name (such as `'gemini-pro'`) or a
  /// model code (such as `'models/gemini-pro'`).
  /// There is no creation time check for whether the `model` string identifies
  /// a known and supported model. If not, attempts to generate content
  /// will fail.
  ///
  /// The optional [safetySettings] and [generationConfig] can be used to
  /// control and guide the generation. See [SafetySetting] and
  /// [GenerationConfig] for details.
  GenerativeModel generativeModel(
      {required String model,
      List<SafetySetting>? safetySettings,
      GenerationConfig? generationConfig,
      Content? systemInstruction,
      List<Tool>? tools,
      ToolConfig? toolConfig}) {
    return GenerativeModel._(
        model: model,
        app: app,
        appCheck: appCheck,
        location: location,
        safetySettings: safetySettings,
        generationConfig: generationConfig,
        systemInstruction: systemInstruction,
        tools: tools,
        toolConfig: toolConfig);
  }
}

/// Options for request to backend.
class RequestOptions {
  /// [timeout] duration for the request.
  RequestOptions({
    required this.timeout,
  });

  /// Timeout for the request, default to 30 minutes, in milliseconds.
  final Duration timeout;
}
