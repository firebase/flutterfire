// Copyright 2025 Google LLC
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

part of 'base_model.dart';

const _apiUrl = 'ws/google.firebase.vertexai';
const _apiUrlSuffixVertexAI = 'LlmBidiService/BidiGenerateContent/locations';
const _apiUrlSuffixGoogleAI = 'GenerativeService/BidiGenerateContent';

/// A live, generative AI model for real-time interaction.
///
/// See the [Cloud
/// documentation](https://cloud.google.com/vertex-ai/generative-ai/docs/model-reference/multimodal-live)
/// for more details about the low-latency, two-way interactions that use text,
/// audio, and video input, with audio and text output.
///
/// > Warning: For Vertex AI in Firebase, Live Model
/// is in Public Preview, which means that the feature is not subject to any SLA
/// or deprecation policy and could change in backwards-incompatible ways.
final class LiveGenerativeModel extends BaseModel {
  LiveGenerativeModel._(
      {required String model,
      required String location,
      required FirebaseApp app,
      required bool useVertexBackend,
      bool? useLimitedUseAppCheckTokens,
      FirebaseAppCheck? appCheck,
      FirebaseAuth? auth,
      LiveGenerationConfig? liveGenerationConfig,
      List<Tool>? tools,
      Content? systemInstruction})
      : _app = app,
        _location = location,
        _useVertexBackend = useVertexBackend,
        _appCheck = appCheck,
        _auth = auth,
        _liveGenerationConfig = liveGenerationConfig,
        _tools = tools,
        _systemInstruction = systemInstruction,
        _useLimitedUseAppCheckTokens = useLimitedUseAppCheckTokens,
        super._(
          serializationStrategy: VertexSerialization(),
          modelUri: useVertexBackend
              ? _VertexUri(
                  model: model,
                  app: app,
                  location: location,
                )
              : _GoogleAIUri(
                  model: model,
                  app: app,
                ),
        );

  final FirebaseApp _app;
  final String _location;
  final bool _useVertexBackend;
  final FirebaseAppCheck? _appCheck;
  final FirebaseAuth? _auth;
  final LiveGenerationConfig? _liveGenerationConfig;
  final List<Tool>? _tools;
  final Content? _systemInstruction;
  final bool? _useLimitedUseAppCheckTokens;

  String _vertexAIUri() => 'wss://${_modelUri.baseAuthority}/'
      '$_apiUrl.${_modelUri.apiVersion}.$_apiUrlSuffixVertexAI/'
      '$_location?key=${_app.options.apiKey}';

  String _vertexAIModelString() => 'projects/${_app.options.projectId}/'
      'locations/$_location/publishers/google/models/${model.name}';

  String _googleAIUri() => 'wss://${_modelUri.baseAuthority}/'
      '$_apiUrl.${_modelUri.apiVersion}.$_apiUrlSuffixGoogleAI?key=${_app.options.apiKey}';

  String _googleAIModelString() =>
      'projects/${_app.options.projectId}/models/${model.name}';

  /// Establishes a connection to a live generation service.
  ///
  /// This function handles the WebSocket connection setup and returns an [LiveSession]
  /// object that can be used to communicate with the service.
  ///
  /// Returns a [Future] that resolves to an [LiveSession] object upon successful
  /// connection.
  Future<LiveSession> connect(
      {SessionResumptionConfig? sessionResumption}) async {
    final uri = _useVertexBackend ? _vertexAIUri() : _googleAIUri();
    final modelString =
        _useVertexBackend ? _vertexAIModelString() : _googleAIModelString();

    final headers = await BaseModel.firebaseTokens(
      _appCheck,
      _auth,
      _app,
      _useLimitedUseAppCheckTokens,
    )();

    return LiveSession.connect(
      uri: uri,
      headers: headers,
      modelString: modelString,
      systemInstruction: _systemInstruction,
      tools: _tools,
      sessionResumption: sessionResumption,
      liveGenerationConfig: _liveGenerationConfig,
    );
  }
}

/// Returns a [LiveGenerativeModel] using it's private constructor.
LiveGenerativeModel createLiveGenerativeModel({
  required FirebaseApp app,
  required String location,
  required String model,
  required bool useVertexBackend,
  bool? useLimitedUseAppCheckTokens,
  FirebaseAppCheck? appCheck,
  FirebaseAuth? auth,
  LiveGenerationConfig? liveGenerationConfig,
  List<Tool>? tools,
  Content? systemInstruction,
}) =>
    LiveGenerativeModel._(
      model: model,
      app: app,
      appCheck: appCheck,
      auth: auth,
      location: location,
      useVertexBackend: useVertexBackend,
      useLimitedUseAppCheckTokens: useLimitedUseAppCheckTokens,
      liveGenerationConfig: liveGenerationConfig,
      tools: tools,
      systemInstruction: systemInstruction,
    );
