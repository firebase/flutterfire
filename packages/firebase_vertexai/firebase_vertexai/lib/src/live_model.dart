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

import 'dart:convert';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'base_model.dart';
import 'live_api.dart';
import 'function_calling.dart';
import 'content.dart';
import 'live_session.dart';

const _baseDailyUrl = 'daily-firebaseml.sandbox.googleapis.com';
const _apiUrl =
    'ws/google.firebase.machinelearning.v2beta.LlmBidiService/BidiGenerateContent?key=';

const _baseAutopushUrl = 'autopush-firebasevertexai.sandbox.googleapis.com';
const _apiAutopushUrl =
    'ws/google.firebase.vertexai.v1beta.LlmBidiService/BidiGenerateContent/locations';

const _baseGAIUrl = 'generativelanguage.googleapis.com';
const _apiGAIUrl =
    'ws/google.ai.generativelanguage.v1alpha.GenerativeService.BidiGenerateContent?key=';

const _bidiGoogleAI = false;

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
        _liveGenerationConfig = liveGenerationConfig,
        _tools = tools,
        _systemInstruction = systemInstruction,
        super(
          model: model,
          app: app,
          location: location,
        );

  final FirebaseApp _app;
  final String _location;
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
    late String uri;
    late String modelString;

    if (_bidiGoogleAI) {
      uri = 'wss://$_baseGAIUrl/$_apiGAIUrl${_app.options.apiKey}';
      modelString = '${model.prefix}/${model.name}}';
    } else {
      // uri = 'wss://$_baseDailyUrl/$_apiUrl${_app.options.apiKey}';
      uri =
          'wss://$_baseAutopushUrl/$_apiAutopushUrl/$_location?key=${_app.options.apiKey}';
      modelString =
          'projects/${_app.options.projectId}/locations/$_location/publishers/google/models/${model.name}';
    }

    final requestJson = {
      'setup': {
        'model': modelString,
        if (_liveGenerationConfig != null)
          'generation_config': _liveGenerationConfig.toJson(),
        if (_systemInstruction != null)
          'system_instruction': _systemInstruction.toJson(),
        if (_tools != null) 'tools': _tools.map((t) => t.toJson()).toList(),
      }
    };

    final request = jsonEncode(requestJson);
    var ws = WebSocketChannel.connect(Uri.parse(uri));
    await ws.ready;
    print(uri);
    print(request);

    ws.sink.add(request);
    return LiveSession(ws: ws);
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
