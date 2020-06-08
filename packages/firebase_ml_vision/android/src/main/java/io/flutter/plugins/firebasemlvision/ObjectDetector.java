package io.flutter.plugins.firebasemlvision;

import androidx.annotation.NonNull;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.ml.vision.FirebaseVision;
import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import com.google.firebase.ml.vision.objects.FirebaseVisionObject;
import com.google.firebase.ml.vision.objects.FirebaseVisionObjectDetector;
import com.google.firebase.ml.vision.objects.FirebaseVisionObjectDetectorOptions;
import io.flutter.plugin.common.MethodChannel;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ObjectDetector implements Detector {

  private final FirebaseVisionObjectDetector detector;

  ObjectDetector(FirebaseVision vision, Map<String, Object> options) {
    detector = vision.getOnDeviceObjectDetector(parseOptions(options));
  }

  @Override
  public void handleDetection(final FirebaseVisionImage image, final MethodChannel.Result result) {
    detector
        .processImage(image)
        .addOnSuccessListener(
            new OnSuccessListener<List<FirebaseVisionObject>>() {
              @Override
              public void onSuccess(List<FirebaseVisionObject> detectedObjects) {
                List<Map<String, Object>> objects = new ArrayList<>(detectedObjects.size());
                for (FirebaseVisionObject detectedObj : detectedObjects) {
                  Map<String, Object> detectedObjData = new HashMap<>();

                  detectedObjData.put("left", (double) detectedObj.getBoundingBox().left);
                  detectedObjData.put("top", (double) detectedObj.getBoundingBox().top);
                  detectedObjData.put("width", (double) detectedObj.getBoundingBox().width());
                  detectedObjData.put("height", (double) detectedObj.getBoundingBox().height());

                  if (detectedObj.getTrackingId() != null) {
                    detectedObjData.put("trackingId", detectedObj.getTrackingId());
                  }

                  retrieveCategory(detectedObj, detectedObjData);
                }
                result.success(objects);
              }
            })
        .addOnFailureListener(
            new OnFailureListener() {
              @Override
              public void onFailure(@NonNull Exception e) {
                result.error("objectDetectorError", e.getLocalizedMessage(), null);
              }
            });
  }

  @Override
  public void close() throws IOException {
    detector.close();
  }

  private void retrieveCategory(
      FirebaseVisionObject detectedObj, Map<String, Object> detectedObjData) {
    switch (detectedObj.getClassificationCategory()) {
      case 0:
        detectedObjData.put("category", "UNKNOWN");
        detectedObjData.put("confidence", detectedObj.getClassificationConfidence());
        break;
      case 1:
        detectedObjData.put("category", "HOME_GOOD");
        detectedObjData.put("confidence", detectedObj.getClassificationConfidence());
        break;
      case 2:
        detectedObjData.put("category", "FASHION_GOOD");
        detectedObjData.put("confidence", detectedObj.getClassificationConfidence());
        break;
      case 3:
        detectedObjData.put("category", "FOOD");
        detectedObjData.put("confidence", detectedObj.getClassificationConfidence());
        break;
      case 4:
        detectedObjData.put("category", "PLACE");
        detectedObjData.put("confidence", detectedObj.getClassificationConfidence());
        break;
      case 5:
        detectedObjData.put("category", "PLANT");
        detectedObjData.put("confidence", detectedObj.getClassificationConfidence());
    }
  }

  private FirebaseVisionObjectDetectorOptions parseOptions(Map<String, Object> options) {

    int mode;
    switch ((String) options.get("mode")) {
      case "stream":
        mode = FirebaseVisionObjectDetectorOptions.STREAM_MODE;
        break;
      case "single":
        mode = FirebaseVisionObjectDetectorOptions.SINGLE_IMAGE_MODE;
        break;
      default:
        throw new IllegalArgumentException("Not a mode:" + options.get("mode"));
    }

    FirebaseVisionObjectDetectorOptions.Builder builder =
        new FirebaseVisionObjectDetectorOptions.Builder().setDetectorMode(mode);
    if ((boolean) options.get("enableClassification")) {
      builder.enableClassification();
    }
    if ((boolean) options.get("enableMultipleObjects")) {
      builder.enableMultipleObjects();
    }
    return builder.build();
  }
}
