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

// ignore_for_file: use_late_for_private_fields_and_variables
part of '../base_model.dart';

/// A generative model that connects to a remote server template.
@experimental
final class TemplateGenerativeModel extends BaseTemplateApiClientModel {
  TemplateGenerativeModel._test({
    required String location,
    required FirebaseApp app,
    required bool useVertexBackend,
    http.Client? httpClient,
  }) : super(
          serializationStrategy: useVertexBackend
              ? VertexSerialization()
              : DeveloperSerialization(),
          modelUri: useVertexBackend
              ? _VertexUri(app: app, model: '', location: location)
              : _GoogleAIUri(app: app, model: ''),
          client: HttpApiClient(
              apiKey: app.options.apiKey,
              httpClient: httpClient,
              requestHeaders: BaseModel.firebaseTokens(null, null, app, false)),
          templateUri: useVertexBackend
              ? _TemplateVertexUri(app: app, location: location)
              : _TemplateGoogleAIUri(app: app),
        );

  TemplateGenerativeModel._({
    required String location,
    required FirebaseApp app,
    required bool useVertexBackend,
    bool? useLimitedUseAppCheckTokens,
    FirebaseAppCheck? appCheck,
    FirebaseAuth? auth,
    http.Client? httpClient,
  }) : super(
          serializationStrategy: useVertexBackend
              ? VertexSerialization()
              : DeveloperSerialization(),
          modelUri: useVertexBackend
              ? _VertexUri(app: app, model: '', location: location)
              : _GoogleAIUri(app: app, model: ''),
          client: HttpApiClient(
              apiKey: app.options.apiKey,
              httpClient: httpClient,
              requestHeaders: BaseModel.firebaseTokens(
                  appCheck, auth, app, useLimitedUseAppCheckTokens)),
          templateUri: useVertexBackend
              ? _TemplateVertexUri(app: app, location: location)
              : _TemplateGoogleAIUri(app: app),
        );

  /// Generates content from a template with the given [templateId] and [inputs].
  ///
  /// Sends a "templateGenerateContent" API request for the configured model.
  @experimental
  Future<GenerateContentResponse> generateContent(String templateId,
          {required Map<String, Object?> inputs}) =>
      makeTemplateRequest(TemplateTask.templateGenerateContent, templateId,
          inputs, null, _serializationStrategy.parseGenerateContentResponse);

  /// Generates a stream of content responding to [templateId] and [inputs].
  ///
  /// Sends a "templateStreamGenerateContent" API request for the server template,
  /// and waits for the response.
  @experimental
  Stream<GenerateContentResponse> generateContentStream(String templateId,
      {required Map<String, Object?> inputs}) {
    return streamTemplateRequest(
        TemplateTask.templateStreamGenerateContent,
        templateId,
        inputs,
        null,
        _serializationStrategy.parseGenerateContentResponse);
  }
}

/// Returns a [TemplateGenerativeModel] using its private constructor.
@experimental
@internal
TemplateGenerativeModel createTemplateGenerativeModel({
  required FirebaseApp app,
  required String location,
  required bool useVertexBackend,
  bool? useLimitedUseAppCheckTokens,
  FirebaseAppCheck? appCheck,
  FirebaseAuth? auth,
}) =>
    TemplateGenerativeModel._(
      app: app,
      appCheck: appCheck,
      useVertexBackend: useVertexBackend,
      useLimitedUseAppCheckTokens: useLimitedUseAppCheckTokens,
      auth: auth,
      location: location,
    );

/// Returns a [TemplateGenerativeModel] for test case.
@experimental
@internal
TemplateGenerativeModel createTestTemplateGenerativeModel({
  required FirebaseApp app,
  required String location,
  required bool useVertexBackend,
  required http.Client client,
}) =>
    TemplateGenerativeModel._test(
      app: app,
      useVertexBackend: useVertexBackend,
      location: location,
      httpClient: client,
    );
