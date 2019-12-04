package io.flutter.plugins.firebasemlvision;

import androidx.annotation.NonNull;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import com.google.firebase.ml.vision.label.FirebaseVisionImageLabel;
import com.google.firebase.ml.vision.label.FirebaseVisionImageLabeler;
import io.flutter.plugin.common.MethodChannel;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

abstract class AbstractImageLabeler implements Detector {
  abstract FirebaseVisionImageLabeler getImageLabeler();

  @Override
  public void handleDetection(final FirebaseVisionImage image, final MethodChannel.Result result) {
    getImageLabeler()
        .processImage(image)
        .addOnSuccessListener(
            new OnSuccessListener<List<FirebaseVisionImageLabel>>() {
              @Override
              public void onSuccess(List<FirebaseVisionImageLabel> firebaseVisionLabels) {
                List<Map<String, Object>> labels = new ArrayList<>(firebaseVisionLabels.size());
                for (FirebaseVisionImageLabel label : firebaseVisionLabels) {
                  Map<String, Object> labelData = new HashMap<>();
                  labelData.put("confidence", (double) label.getConfidence());
                  labelData.put("entityId", label.getEntityId());
                  labelData.put("text", label.getText());

                  labels.add(labelData);
                }

                result.success(labels);
              }
            })
        .addOnFailureListener(
            new OnFailureListener() {
              @Override
              public void onFailure(@NonNull Exception e) {
                result.error("imageLabelerError", e.getLocalizedMessage(), null);
              }
            });
  }

  @Override
  public void close() throws IOException {
    getImageLabeler().close();
  }
}
