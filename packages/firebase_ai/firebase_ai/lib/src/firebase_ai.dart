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

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show FirebasePluginPlatform;
import 'package:meta/meta.dart';

import '../firebase_ai.dart';
import 'base_model.dart';

const _defaultLocation = 'us-central1';

/// The entrypoint for generative models.
class FirebaseAI extends FirebasePluginPlatform {
  FirebaseAI._(
      {required this.app,
      required this.location,
      required bool useVertexBackend,
      this.appCheck,
      this.auth})
      : _useVertexBackend = useVertexBackend,
        super(app.name, 'plugins.flutter.io/firebase_vertexai');

  /// The [FirebaseApp] for this current [FirebaseAI] instance.
  FirebaseApp app;

  /// The optional [FirebaseAppCheck] for this current [FirebaseAI] instance.
  /// https://firebase.google.com/docs/app-check
  FirebaseAppCheck? appCheck;

  /// The optional [FirebaseAuth] for this current [FirebaseAI] instance.
  FirebaseAuth? auth;

  /// The service location for this [FirebaseAI] instance.
  String location;

  final bool _useVertexBackend;

  static final Map<String, FirebaseAI> _cachedInstances = {};

  /// Returns an instance using a specified [FirebaseApp].
  ///
  /// If [app] is not provided, the default Firebase app will be used.
  /// If pass in [appCheck], request session will get protected from abusing.
  static FirebaseAI vertexAI({
    FirebaseApp? app,
    FirebaseAppCheck? appCheck,
    FirebaseAuth? auth,
    String? location,
  }) {
    app ??= Firebase.app();
    var instanceKey = '${app.name}::vertexai';

    if (_cachedInstances.containsKey(instanceKey)) {
      return _cachedInstances[instanceKey]!;
    }

    location ??= _defaultLocation;

    FirebaseAI newInstance = FirebaseAI._(
      app: app,
      location: location,
      appCheck: appCheck,
      auth: auth,
      useVertexBackend: true,
    );
    _cachedInstances[instanceKey] = newInstance;

    return newInstance;
  }

  /// Returns an instance using a specified [FirebaseApp].
  ///
  /// If [app] is not provided, the default Firebase app will be used.
  /// If pass in [appCheck], request session will get protected from abusing.
  static FirebaseAI googleAI({
    FirebaseApp? app,
    FirebaseAppCheck? appCheck,
    FirebaseAuth? auth,
  }) {
    app ??= Firebase.app();
    var instanceKey = '${app.name}::googleai';

    if (_cachedInstances.containsKey(instanceKey)) {
      return _cachedInstances[instanceKey]!;
    }

    FirebaseAI newInstance = FirebaseAI._(
      app: app,
      location: _defaultLocation,
      appCheck: appCheck,
      auth: auth,
      useVertexBackend: false,
    );
    _cachedInstances[instanceKey] = newInstance;

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
  GenerativeModel generativeModel({
    required String model,
    List<SafetySetting>? safetySettings,
    GenerationConfig? generationConfig,
    List<Tool>? tools,
    ToolConfig? toolConfig,
    Content? systemInstruction,
  }) {
    return createGenerativeModel(
      model: model,
      app: app,
      appCheck: appCheck,
      useVertexBackend: _useVertexBackend,
      auth: auth,
      location: location,
      safetySettings: safetySettings,
      generationConfig: generationConfig,
      tools: tools,
      toolConfig: toolConfig,
      systemInstruction: systemInstruction,
    );
  }

  /// Create a [ImagenModel].
  ///
  /// The optional [safetySettings] can be used to control and guide the
  /// generation. See [ImagenSafetySettings] for details.
  @experimental
  ImagenModel imagenModel(
      {required String model,
      ImagenGenerationConfig? generationConfig,
      ImagenSafetySettings? safetySettings}) {
    return createImagenModel(
        app: app,
        location: location,
        model: model,
        useVertexBackend: _useVertexBackend,
        generationConfig: generationConfig,
        safetySettings: safetySettings,
        appCheck: appCheck,
        auth: auth);
  }

  /// Create a [LiveGenerativeModel] for real-time interaction.
  ///
  /// The optional [liveGenerationConfig] can be used to control and guide the
  /// generation. See [LiveGenerationConfig] for details.
  LiveGenerativeModel liveGenerativeModel({
    required String model,
    LiveGenerationConfig? liveGenerationConfig,
    List<Tool>? tools,
    Content? systemInstruction,
  }) {
    if (!_useVertexBackend) {
      throw FirebaseAISdkException(
          'LiveGenerativeModel is currently only supported with the VertexAI backend.');
    }
    return createLiveGenerativeModel(
      app: app,
      location: location,
      model: model,
      liveGenerationConfig: liveGenerationConfig,
      tools: tools,
      systemInstruction: systemInstruction,
      appCheck: appCheck,
      auth: auth,
    );
  }
}
