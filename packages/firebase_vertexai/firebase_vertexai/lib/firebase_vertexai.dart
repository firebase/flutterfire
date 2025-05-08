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

import 'package:firebase_ai/firebase_ai.dart'
    show FirebaseAIException, FirebaseAISdkException;

export 'package:firebase_ai/firebase_ai.dart'
    show
        BlockReason,
        Candidate,
        CitationMetadata,
        Citation,
        CountTokensResponse,
        FinishReason,
        GenerateContentResponse,
        GenerationConfig,
        HarmBlockThreshold,
        HarmCategory,
        HarmProbability,
        HarmBlockMethod,
        PromptFeedback,
        ResponseModalities,
        SafetyRating,
        SafetySetting,
        UsageMetadata,
        GenerativeModel,
        ImagenModel,
        LiveGenerativeModel,
        ChatSession,
        StartChatExtension,
        Content,
        InlineDataPart,
        FileData,
        FunctionCall,
        FunctionResponse,
        Part,
        TextPart,
        InvalidApiKey,
        ServerException,
        UnsupportedUserLocation,
        FunctionCallingConfig,
        FunctionCallingMode,
        FunctionDeclaration,
        Tool,
        ToolConfig,
        ImagenSafetySettings,
        ImagenFormat,
        ImagenSafetyFilterLevel,
        ImagenPersonFilterLevel,
        ImagenGenerationConfig,
        ImagenAspectRatio,
        ImagenInlineImage,
        LiveGenerationConfig,
        SpeechConfig,
        LiveServerMessage,
        LiveServerContent,
        LiveServerToolCall,
        LiveServerToolCallCancellation,
        LiveServerResponse,
        LiveSession,
        Schema,
        SchemaType;
export 'src/firebase_vertexai.dart' show FirebaseVertexAI;

/// Exception thrown when generating content fails.
typedef VertexAIException = FirebaseAIException;

/// Exception indicating a stale package version or implementation bug.
///
/// This exception indicates a likely problem with the SDK implementation such
/// as an inability to parse a new response format. Resolution paths may include
/// updating to a new version of the SDK, or filing an issue.
typedef VertexAISdkException = FirebaseAISdkException;
