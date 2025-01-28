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

import 'content.dart';
import 'error.dart';

class LiveServerContent {
  LiveServerContent({this.modelTurn, this.turnComplete, this.interrupted});

  final Content? modelTurn;
  final bool? turnComplete;
  final bool? interrupted;
}

class LiveServerMessage {
  LiveServerMessage({this.serverContent});

  final LiveServerContent? serverContent;
  // toolCall and toolCallCancellation
}

class LiveClientRealtimeInput {
  LiveClientRealtimeInput({this.mediaChunks});
  final List<InlineDataPart>? mediaChunks;

  Map<String, dynamic> toJson() => {
        'mediaChunks': mediaChunks?.map((e) => e.toJson()).toList(),
      };
}

class LiveClientContent {
  LiveClientContent({this.turns, this.turnComplete});
  final List<Content>? turns;
  final bool? turnComplete;

  Map<String, dynamic> toJson() => {
        'client_content': {
          'turns': turns?.map((e) => e.toJson()).toList(),
          'turn_complete': turnComplete,
        }
      };
}

class LiveClientToolResponse {
  LiveClientToolResponse({this.functionResponses});
  final List<FunctionResponse>? functionResponses;
  Map<String, dynamic> toJson() => {
        'functionResponses': functionResponses?.map((e) => e.toJson()).toList(),
      };
}

LiveServerMessage parseServerMessage(Object jsonObject) {
  if (jsonObject case {'error': final Object error}) {
    throw parseError(error);
  }
  print(jsonObject);
  Map<String, dynamic> json = jsonObject as Map<String, dynamic>;
  LiveServerContent? serverContent;
  if (json.containsKey('server_content')) {
    final serverContentJson = json['server_content'] as Map<String, dynamic>;
    Content? modelTurn;
    if (serverContentJson.containsKey('model_turn')) {
      modelTurn = serverContentJson['model_turn'];
    }
    bool? turnComplete;
    if (serverContentJson.containsKey('turn_complete')) {
      turnComplete = serverContentJson['turn_complete'] as bool;
    }
    serverContent =
        LiveServerContent(modelTurn: modelTurn, turnComplete: turnComplete);
  }
  return LiveServerMessage(serverContent: serverContent);
}
