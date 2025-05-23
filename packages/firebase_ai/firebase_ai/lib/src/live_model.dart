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
const _apiUrlSuffix = 'LlmBidiService/BidiGenerateContent/locations';

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
      FirebaseAppCheck? appCheck,
      FirebaseAuth? auth,
      LiveGenerationConfig? liveGenerationConfig,
      List<Tool>? tools,
      Content? systemInstruction})
      : _app = app,
        _location = location,
        _appCheck = appCheck,
        _auth = auth,
        _liveGenerationConfig = liveGenerationConfig,
        _tools = tools,
        _systemInstruction = systemInstruction,
        super._(
          serializationStrategy: VertexSerialization(),
          modelUri: _VertexUri(
            model: model,
            app: app,
            location: location,
          ),
        );
  static const _apiVersion = 'v1beta';

  final FirebaseApp _app;
  final String _location;
  final FirebaseAppCheck? _appCheck;
  final FirebaseAuth? _auth;
  final LiveGenerationConfig? _liveGenerationConfig;
  final List<Tool>? _tools;
  final Content? _systemInstruction;

  /// Establishes a connection to a live generation service.
  ///
  /// This function handles the WebSocket connection setup and returns an [LiveSession]
  /// object that can be used to communicate with the service.
  ///
  /// Returns a [Future] that resolves to an [LiveSession] object upon successful
  /// connection.
  Future<LiveSession> connect() async {
    final uri = 'wss://${_modelUri.baseAuthority}/'
        '$_apiUrl.$_apiVersion.$_apiUrlSuffix/'
        '$_location?key=${_app.options.apiKey}';
    final modelString = 'projects/${_app.options.projectId}/'
        'locations/$_location/publishers/google/models/${model.name}';

    final setupJson = {
      'setup': {
        'model': modelString,
        if (_liveGenerationConfig != null)
          'generation_config': _liveGenerationConfig.toJson(),
        if (_systemInstruction != null)
          'system_instruction': _systemInstruction.toJson(),
        if (_tools != null) 'tools': _tools.map((t) => t.toJson()).toList(),
      }
    };

    final request = jsonEncode(setupJson);
    final headers = await BaseModel.firebaseTokens(_appCheck, _auth, _app)();

    var ws = kIsWeb
        ? WebSocketChannel.connect(Uri.parse(uri))
        : IOWebSocketChannel.connect(Uri.parse(uri), headers: headers);
    await ws.ready;

    ws.sink.add(request);
    return LiveSession(ws);
  }
}

/// Returns a [LiveGenerativeModel] using it's private constructor.
LiveGenerativeModel createLiveGenerativeModel({
  required FirebaseApp app,
  required String location,
  required String model,
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
      liveGenerationConfig: liveGenerationConfig,
      tools: tools,
      systemInstruction: systemInstruction,
    );
