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

part of '../base_model.dart';

/// An image model that connects to a remote server template.
@experimental
final class TemplateImagenModel extends BaseTemplateApiClientModel {
  TemplateImagenModel._testModel(
      {required FirebaseApp app,
      required String location,
      required bool useVertexBackend,
      http.Client? httpClient})
      : super(
          serializationStrategy: VertexSerialization(),
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

  TemplateImagenModel._(
      {required FirebaseApp app,
      required String location,
      required bool useVertexBackend,
      bool? useLimitedUseAppCheckTokens,
      FirebaseAppCheck? appCheck,
      FirebaseAuth? auth})
      : super(
          serializationStrategy: useVertexBackend
              ? VertexSerialization()
              : DeveloperSerialization(),
          modelUri: useVertexBackend
              ? _VertexUri(app: app, model: '', location: location)
              : _GoogleAIUri(app: app, model: ''),
          client: HttpApiClient(
              apiKey: app.options.apiKey,
              requestHeaders: BaseModel.firebaseTokens(
                  appCheck, auth, app, useLimitedUseAppCheckTokens)),
          templateUri: useVertexBackend
              ? _TemplateVertexUri(app: app, location: location)
              : _TemplateGoogleAIUri(app: app),
        );

  /// Generates images from a template with the given [templateId] and [inputs].
  @experimental
  Future<ImagenGenerationResponse<ImagenInlineImage>> generateImages(
          String templateId,
          {required Map<String, Object?> inputs}) =>
      makeTemplateRequest(
        TemplateTask.templatePredict,
        templateId,
        inputs,
        null,
        (jsonObject) =>
            parseImagenGenerationResponse<ImagenInlineImage>(jsonObject),
      );
}

/// Returns a [TemplateImagenModel] using its private constructor.
@experimental
@internal
TemplateImagenModel createTemplateImagenModel({
  required FirebaseApp app,
  required String location,
  required bool useVertexBackend,
  bool? useLimitedUseAppCheckTokens,
  FirebaseAppCheck? appCheck,
  FirebaseAuth? auth,
}) =>
    TemplateImagenModel._(
      app: app,
      appCheck: appCheck,
      auth: auth,
      location: location,
      useVertexBackend: useVertexBackend,
      useLimitedUseAppCheckTokens: useLimitedUseAppCheckTokens,
    );

/// Returns a [TemplateImagenModel] using its private constructor.
@experimental
@internal
TemplateImagenModel createTestTemplateImagenModel({
  required FirebaseApp app,
  required String location,
  required bool useVertexBackend,
  required http.Client client,
}) =>
    TemplateImagenModel._testModel(
      app: app,
      location: location,
      useVertexBackend: useVertexBackend,
      httpClient: client,
    );
