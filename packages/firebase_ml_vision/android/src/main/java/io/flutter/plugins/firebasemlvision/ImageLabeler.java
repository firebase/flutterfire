// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebasemlvision;

import com.google.firebase.ml.vision.FirebaseVision;
import com.google.firebase.ml.vision.label.FirebaseVisionCloudImageLabelerOptions;
import com.google.firebase.ml.vision.label.FirebaseVisionImageLabeler;
import com.google.firebase.ml.vision.label.FirebaseVisionOnDeviceImageLabelerOptions;
import java.util.Map;

class ImageLabeler extends AbstractImageLabeler {
  private final FirebaseVisionImageLabeler labeler;

  ImageLabeler(FirebaseVision vision, Map<String, Object> options) {
    final String modelType = (String) options.get("modelType");
    if (modelType.equals("onDevice")) {
      labeler = vision.getOnDeviceImageLabeler(parseOptions(options));
    } else if (modelType.equals("cloud")) {
      labeler = vision.getCloudImageLabeler(parseCloudOptions(options));
    } else {
      final String message = String.format("No model for type: %s", modelType);
      throw new IllegalArgumentException(message);
    }
  }

  private FirebaseVisionOnDeviceImageLabelerOptions parseOptions(Map<String, Object> optionsData) {
    float conf = (float) (double) optionsData.get("confidenceThreshold");
    return new FirebaseVisionOnDeviceImageLabelerOptions.Builder()
        .setConfidenceThreshold(conf)
        .build();
  }

  private FirebaseVisionCloudImageLabelerOptions parseCloudOptions(
      Map<String, Object> optionsData) {
    float conf = (float) (double) optionsData.get("confidenceThreshold");
    return new FirebaseVisionCloudImageLabelerOptions.Builder()
        .setConfidenceThreshold(conf)
        .build();
  }

  @Override
  FirebaseVisionImageLabeler getImageLabeler() {
    return labeler;
  }
}
