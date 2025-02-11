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

import 'base_model.dart';
import 'client.dart';
import 'imagen_api.dart';
import 'imagen_content.dart';

///
final class ImagenModel extends BaseModel {
  ImagenModel._(
      {required FirebaseApp app,
      required String model,
      required String location,
      FirebaseAppCheck? appCheck,
      FirebaseAuth? auth,
      ImagenGenerationConfig? generationConfig,
      ImagenSafetySettings? safetySettings})
      : _generationConfig = generationConfig,
        _safetySettings = safetySettings,
        super(
            model: model,
            app: app,
            location: location,
            client: HttpApiClient(
                apiKey: app.options.apiKey,
                requestHeaders: BaseModel.firebaseTokens(appCheck, auth)));

  final ImagenGenerationConfig? _generationConfig;
  final ImagenSafetySettings? _safetySettings;

  Map<String, Object?> _generateImagenRequest(
    String prompt, {
    String? gcsUri,
  }) {
    final parameters = <String, Object?>{
      if (gcsUri != null) 'storageUri': gcsUri,
      'sampleCount': _generationConfig?.numberOfImages ?? 1,
      if (_generationConfig?.aspectRatio case final aspectRatio?)
        'aspectRatio': aspectRatio,
      if (_generationConfig?.negativePrompt case final negativePrompt?)
        'negativePrompt': negativePrompt,
      if (_generationConfig?.addWatermark case final addWatermark?)
        'addWatermark': addWatermark,
      if (_generationConfig.imageFormat case final imageFormat?)
        'outputOption': imageFormat.toJson(),
      if (_safetySettings?.personFilterLevel case final personFilterLevel?)
        'personGeneration': personFilterLevel.toJson(),
      if (_safetySettings?.safetyFilterLevel case final safetyFilterLevel?)
        'safetySetting': safetyFilterLevel.toJson(),
    };

    return {
      'instances': [
        {'prompt': prompt}
      ],
      'parameters': parameters,
    };
  }

  /// Generates images with format of [ImagenInlineImage] based on the given
  /// prompt.
  Future<ImagenGenerationResponse<ImagenInlineImage>> generateImages(
    String prompt,
  ) =>
      makeRequest(
        Task.predict,
        _generateImagenRequest(
          prompt,
        ),
        (jsonObject) =>
            parseImagenGenerationResponse<ImagenInlineImage>(jsonObject),
      );

  /// Generates images with format of [ImagenGCSImage] based on the given
  /// prompt.
  /// Note: Keep this API private until future release.
  Future<ImagenGenerationResponse<ImagenGCSImage>> _generateImagesGCS(
    String prompt,
    String gcsUri,
  ) =>
      makeRequest(
        Task.predict,
        _generateImagenRequest(
          prompt,
          gcsUri: gcsUri,
        ),
        (jsonObject) =>
            parseImagenGenerationResponse<ImagenGCSImage>(jsonObject),
      );
}

/// Returns a [ImagenModel] using it's private constructor.
ImagenModel createImagenModel({
  required FirebaseApp app,
  required String location,
  required String model,
  FirebaseAppCheck? appCheck,
  FirebaseAuth? auth,
  ImagenGenerationConfig? generationConfig,
  ImagenSafetySettings? safetySettings,
}) =>
    ImagenModel._(
      model: model,
      app: app,
      appCheck: appCheck,
      auth: auth,
      location: location,
      safetySettings: safetySettings,
      generationConfig: generationConfig,
    );
