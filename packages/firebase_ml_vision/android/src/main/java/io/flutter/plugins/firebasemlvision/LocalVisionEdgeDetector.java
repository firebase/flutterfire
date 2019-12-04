package io.flutter.plugins.firebasemlvision;

import com.google.firebase.ml.common.FirebaseMLException;
import com.google.firebase.ml.common.modeldownload.FirebaseLocalModel;
import com.google.firebase.ml.common.modeldownload.FirebaseModelManager;
import com.google.firebase.ml.vision.FirebaseVision;
import com.google.firebase.ml.vision.label.FirebaseVisionImageLabeler;
import com.google.firebase.ml.vision.label.FirebaseVisionOnDeviceAutoMLImageLabelerOptions;
import java.util.Map;

class LocalVisionEdgeDetector extends AbstractImageLabeler {
  private final FirebaseVisionImageLabeler labeler;

  LocalVisionEdgeDetector(Map<String, Object> options) {
    final String finalPath = "flutter_assets/assets/" + options.get("dataset") + "/manifest.json";
    FirebaseLocalModel localModel =
        FirebaseModelManager.getInstance().getLocalModel((String) options.get("dataset"));
    if (localModel == null) {
      localModel =
          new FirebaseLocalModel.Builder((String) options.get("dataset"))
              .setAssetFilePath(finalPath)
              .build();
      FirebaseModelManager.getInstance().registerLocalModel(localModel);
    }

    try {
      labeler = FirebaseVision.getInstance().getOnDeviceAutoMLImageLabeler(parseOptions(options));
    } catch (FirebaseMLException exception) {
      throw new IllegalArgumentException(exception.getLocalizedMessage());
    }
  }

  private FirebaseVisionOnDeviceAutoMLImageLabelerOptions parseOptions(
      Map<String, Object> optionsData) {
    float conf = (float) (double) optionsData.get("confidenceThreshold");
    return new FirebaseVisionOnDeviceAutoMLImageLabelerOptions.Builder()
        .setLocalModelName((String) optionsData.get("dataset"))
        .setConfidenceThreshold(conf)
        .build();
  }

  @Override
  FirebaseVisionImageLabeler getImageLabeler() {
    return labeler;
  }
}
