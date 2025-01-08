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
import 'imagen_api.dart';
import 'imagen_content.dart';
import 'base_model.dart';
import 'client.dart';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

///
final class ImagenModel extends BaseModel {
  ImagenModel._(
      {required FirebaseApp app,
      required String modelName,
      required String location,
      FirebaseAppCheck? appCheck,
      FirebaseAuth? auth,
      ImagenModelConfig? modelConfig,
      ImagenSafetySettings? safetySettings})
      : _modelConfig = modelConfig,
        _safetySettings = safetySettings,
        super(
            model: modelName,
            app: app,
            location: location,
            client: HttpApiClient(
                apiKey: app.options.apiKey,
                requestHeaders: BaseModel.firebaseTokens(appCheck, auth)));

  final ImagenModelConfig? _modelConfig;
  final ImagenSafetySettings? _safetySettings;

  Map<String, Object?> _generateImagenRequest(
    String prompt, {
    ImagenGenerationConfig? generationConfig,
    String? gcsUri,
  }) {
    final parameters = <String, Object?>{};

    if (gcsUri != null) parameters['storageUri'] = gcsUri;

    if (generationConfig != null) {
      if (generationConfig.numberOfImages != null) {
        parameters['sampleCount'] = generationConfig.numberOfImages;
      }
      if (generationConfig.aspectRatio != null) {
        parameters['aspectRatio'] = generationConfig.aspectRatio!.toJson();
      }
      if (generationConfig.negativePrompt != null) {
        parameters['negativePrompt'] = generationConfig.negativePrompt;
      }
    }

    if (_safetySettings != null) {
      if (_safetySettings.personFilterLevel != null) {
        parameters['personGeneration'] =
            _safetySettings.personFilterLevel!.toJson();
      }
      if (_safetySettings.safetyFilterLevel != null) {
        parameters['safetySetting'] =
            _safetySettings.safetyFilterLevel!.toJson();
      }
    }

    if (_modelConfig != null && _modelConfig.addWatermark != null) {
      parameters['addWatermark'] = _modelConfig.addWatermark;
    }

    return {
      'instances': [
        {'prompt': prompt}
      ],
      'parameters': parameters,
    };
  }

  Future<ImagenGenerationResponse> generateImages(
    String prompt, {
    ImagenGenerationConfig? generationConfig,
    String? gcsUri,
  }) =>
      makeRequest(
        Task.predict,
        _generateImagenRequest(
          prompt,
          generationConfig: generationConfig,
          gcsUri: gcsUri,
        ),
        (jsonObject) => gcsUri != null
            ? parseImagenGenerationResponse<ImagenGCSImage>(jsonObject)
            : parseImagenGenerationResponse<ImagenInlineImage>(jsonObject),
      );
}

/// Returns a [ImagenModel] using it's private constructor.
ImagenModel createImagenModel({
  required FirebaseApp app,
  required String location,
  required String modelName,
  FirebaseAppCheck? appCheck,
  FirebaseAuth? auth,
  ImagenModelConfig? modelConfig,
  ImagenSafetySettings? safetySettings,
}) =>
    ImagenModel._(
      modelName: modelName,
      app: app,
      appCheck: appCheck,
      auth: auth,
      location: location,
      safetySettings: safetySettings,
      modelConfig: modelConfig,
    );
