// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebasemlvision;

import android.graphics.Rect;
import androidx.annotation.NonNull;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.ml.vision.FirebaseVision;
import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import com.google.firebase.ml.vision.document.FirebaseVisionCloudDocumentRecognizerOptions;
import com.google.firebase.ml.vision.document.FirebaseVisionDocumentText;
import com.google.firebase.ml.vision.document.FirebaseVisionDocumentTextRecognizer;
import com.google.firebase.ml.vision.text.RecognizedLanguage;
import io.flutter.plugin.common.MethodChannel;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class DocumentTextRecognizer implements Detector {
  private final FirebaseVisionDocumentTextRecognizer recognizer;

  DocumentTextRecognizer(FirebaseVision vision, Map<String, Object> options) {
    FirebaseVisionCloudDocumentRecognizerOptions.Builder optionsBuilder =
        new FirebaseVisionCloudDocumentRecognizerOptions.Builder();
    if (options.get("hintedLanguages") != null) {
      optionsBuilder.setLanguageHints((List<String>) options.get("hintedLanguages"));
    }
    FirebaseVisionCloudDocumentRecognizerOptions cloudDocumentTextRecognizerOptions =
        optionsBuilder.build();
    recognizer = vision.getCloudDocumentTextRecognizer(cloudDocumentTextRecognizerOptions);
  }

  @Override
  public void handleDetection(final FirebaseVisionImage image, final MethodChannel.Result result) {
    recognizer
        .processImage(image)
        .addOnSuccessListener(
            new OnSuccessListener<FirebaseVisionDocumentText>() {
              @Override
              public void onSuccess(FirebaseVisionDocumentText firebaseDocumentVisionText) {
                Map<String, Object> visionDocumentTextData = new HashMap<>();
                visionDocumentTextData.put("text", firebaseDocumentVisionText.getText());
                getBlockData(visionDocumentTextData, firebaseDocumentVisionText);
                result.success(visionDocumentTextData);
              }
            })
        .addOnFailureListener(
            new OnFailureListener() {
              @Override
              public void onFailure(@NonNull Exception exception) {
                result.error("documentTextRecognizerError", exception.getLocalizedMessage(), null);
              }
            });
  }

  private void getBlockData(
      Map<String, Object> visionDocumentTextData,
      FirebaseVisionDocumentText firebaseDocumentVisionText) {
    List<Map<String, Object>> allBlockData = new ArrayList<>();
    for (FirebaseVisionDocumentText.Block block : firebaseDocumentVisionText.getBlocks()) {
      Map<String, Object> blockData = new HashMap<>();
      addCommonDataFieldsToMap(
          blockData,
          block.getBoundingBox(),
          block.getConfidence(),
          block.getRecognizedBreak(),
          block.getRecognizedLanguages(),
          block.getText());
      getParagraphData(blockData, block);
      allBlockData.add(blockData);
    }
    visionDocumentTextData.put("blocks", allBlockData);
  }

  private void getParagraphData(
      Map<String, Object> blockData, FirebaseVisionDocumentText.Block block) {
    List<Map<String, Object>> allParagraphData = new ArrayList<>();
    for (FirebaseVisionDocumentText.Paragraph paragraph : block.getParagraphs()) {
      Map<String, Object> paragraphData = new HashMap<>();
      addCommonDataFieldsToMap(
          paragraphData,
          paragraph.getBoundingBox(),
          paragraph.getConfidence(),
          paragraph.getRecognizedBreak(),
          paragraph.getRecognizedLanguages(),
          paragraph.getText());
      getWordData(paragraphData, paragraph);
      allParagraphData.add(paragraphData);
    }
    blockData.put("paragraphs", allParagraphData);
  }

  private void getWordData(
      Map<String, Object> paragraphData, FirebaseVisionDocumentText.Paragraph paragraph) {
    List<Map<String, Object>> allWordData = new ArrayList<>();
    for (FirebaseVisionDocumentText.Word word : paragraph.getWords()) {
      Map<String, Object> wordData = new HashMap<>();
      addCommonDataFieldsToMap(
          wordData,
          word.getBoundingBox(),
          word.getConfidence(),
          word.getRecognizedBreak(),
          word.getRecognizedLanguages(),
          word.getText());
      getSymbolData(wordData, word);
      allWordData.add(wordData);
    }
    paragraphData.put("words", allWordData);
  }

  private void getSymbolData(Map<String, Object> wordData, FirebaseVisionDocumentText.Word word) {
    List<Map<String, Object>> allSymbolData = new ArrayList<>();
    for (FirebaseVisionDocumentText.Symbol symbol : word.getSymbols()) {
      Map<String, Object> symbolData = new HashMap<>();
      addCommonDataFieldsToMap(
          symbolData,
          symbol.getBoundingBox(),
          symbol.getConfidence(),
          symbol.getRecognizedBreak(),
          symbol.getRecognizedLanguages(),
          symbol.getText());

      allSymbolData.add(symbolData);
    }
    wordData.put("symbols", allSymbolData);
  }

  private void addCommonDataFieldsToMap(
      Map<String, Object> addTo,
      Rect boundingBox,
      Float confidence,
      FirebaseVisionDocumentText.RecognizedBreak recognizedBreak,
      List<RecognizedLanguage> languages,
      String text) {

    if (boundingBox != null) {
      addTo.put("left", (double) boundingBox.left);
      addTo.put("top", (double) boundingBox.top);
      addTo.put("width", (double) boundingBox.width());
      addTo.put("height", (double) boundingBox.height());
    }

    addTo.put("confidence", confidence == null ? null : (double) confidence);

    if (recognizedBreak != null) {
      Map<String, Object> breakData = new HashMap<>();
      breakData.put("detectedBreakType", recognizedBreak.getDetectedBreakType());
      breakData.put("detectedBreakPrefix", recognizedBreak.getIsPrefix());
      addTo.put("recognizedBreak", breakData);
    } else {
      addTo.put("recognizedBreak", null);
    }

    List<Map<String, Object>> allLanguageData = new ArrayList<>();
    for (RecognizedLanguage language : languages) {
      Map<String, Object> languageData = new HashMap<>();
      languageData.put("languageCode", language.getLanguageCode());
      allLanguageData.add(languageData);
    }
    addTo.put("recognizedLanguages", allLanguageData);

    addTo.put("text", text);
  }

  @Override
  public void close() throws IOException {
    recognizer.close();
  }
}
