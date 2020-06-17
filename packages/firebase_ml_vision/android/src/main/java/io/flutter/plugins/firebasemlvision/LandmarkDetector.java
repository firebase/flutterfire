// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebasemlvision;

import androidx.annotation.NonNull;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.ml.vision.FirebaseVision;
import com.google.firebase.ml.vision.cloud.FirebaseVisionCloudDetectorOptions;
import com.google.firebase.ml.vision.cloud.landmark.FirebaseVisionCloudLandmark;
import com.google.firebase.ml.vision.cloud.landmark.FirebaseVisionCloudLandmarkDetector;
import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import com.google.firebase.ml.vision.common.FirebaseVisionLatLng;
import io.flutter.plugin.common.MethodChannel;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class LandmarkDetector implements Detector {
  private final FirebaseVisionCloudLandmarkDetector detector;

  LandmarkDetector(FirebaseVision vision, Map<String, Object> options) {
    detector = vision.getVisionCloudLandmarkDetector(parseOptions(options));
  }

  @Override
  public void handleDetection(final FirebaseVisionImage image, final MethodChannel.Result result) {
    detector
        .detectInImage(image)
        .addOnSuccessListener(
            new OnSuccessListener<List<FirebaseVisionCloudLandmark>>() {
              @Override
              public void onSuccess(
                  List<FirebaseVisionCloudLandmark> firebaseVisionCloudLandmarks) {
                List<Map<String, Object>> landmarks =
                    new ArrayList<>(firebaseVisionCloudLandmarks.size());
                for (FirebaseVisionCloudLandmark landmark : firebaseVisionCloudLandmarks) {
                  Map<String, Object> landmarkData = new HashMap<>();

                  landmarkData.put("left", (double) landmark.getBoundingBox().left);
                  landmarkData.put("top", (double) landmark.getBoundingBox().top);
                  landmarkData.put("width", (double) landmark.getBoundingBox().width());
                  landmarkData.put("height", (double) landmark.getBoundingBox().height());

                  landmarkData.put("confidence", landmark.getConfidence());
                  landmarkData.put("entityId", landmark.getEntityId());
                  landmarkData.put("landmark", landmark.getLandmark());

                  List<Map> locations = new ArrayList<>();
                  for (FirebaseVisionLatLng latLng : landmark.getLocations()) {
                    HashMap<String, Double> location = new HashMap<>();
                    location.put("lat", latLng.getLatitude());
                    location.put("lng", latLng.getLongitude());
                    locations.add(location);
                  }
                  landmarkData.put("locations", locations);

                  landmarks.add(landmarkData);
                }

                result.success(landmarks);
              }
            })
        .addOnFailureListener(
            new OnFailureListener() {
              @Override
              public void onFailure(@NonNull Exception exception) {
                result.error("landmarkDetectorError", exception.getLocalizedMessage(), null);
              }
            });
  }

  private FirebaseVisionCloudDetectorOptions parseOptions(Map<String, Object> options) {
    Integer maxResults = (Integer) options.get("maxResults");

    int model = FirebaseVisionCloudDetectorOptions.STABLE_MODEL;
    if (((String) options.get("modelType")).equals("lastest_model")) {
      model = FirebaseVisionCloudDetectorOptions.LATEST_MODEL;
    }

    FirebaseVisionCloudDetectorOptions.Builder builder =
        new FirebaseVisionCloudDetectorOptions.Builder()
            .setMaxResults(maxResults)
            .setModelType(model);

    return builder.build();
  }

  @Override
  public void close() throws IOException {
    detector.close();
  }
}
