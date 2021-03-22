// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

part of firebase_ml_vision;

/// Start or end of a component types detected by [DocumentTextRecognizedBreak].
enum TextRecognizedBreakType {
  unknown,
  space,
  sureSpace,
  eolSureSpace,
  hyphen,
  lineBreak,
}

/// Detector for performing optical character recognition(OCR) on an input image.
///
/// In comparison to [TextRecognizer], it detects dense document text.
///
/// A document text recognizer is created via `cloudDocumentTextRecognizer()` in [FirebaseVision]:
///
/// ```dart
/// final FirebaseVisionImage image =
///     FirebaseVisionImage.fromFilePath('path/to/file');
///
/// final DocumentTextRecognizer documentTextRecognizer =
///     FirebaseVision.instance.cloudDocumentTextRecognizer();
///
/// final List<VisionDocumentText> recognizedText =
///     await documentTextRecognizer.processImage(image);
/// ```
class DocumentTextRecognizer {
  DocumentTextRecognizer._({
    @required CloudDocumentRecognizerOptions cloudOptions,
    @required int handle,
  })  : _cloudOptions = cloudOptions,
        _handle = handle,
        assert(cloudOptions != null);

  final int _handle;
  final CloudDocumentRecognizerOptions _cloudOptions;

  bool _hasBeenOpened = false;
  bool _isClosed = false;

  /// Detects [VisionDocumentText] from a [FirebaseVisionImage].
  Future<VisionDocumentText> processImage(
      FirebaseVisionImage visionImage) async {
    assert(!_isClosed);
    assert(visionImage != null);
    _hasBeenOpened = true;
    final Map<String, dynamic> reply =
        await FirebaseVision.channel.invokeMapMethod<String, dynamic>(
      'DocumentTextRecognizer#processImage',
      <String, dynamic>{
        'handle': _handle,
        'options': <String, dynamic>{
          'hintedLanguages': _cloudOptions.hintedLanguages,
        },
      }..addAll(visionImage._serialize()),
    );
    return VisionDocumentText._(reply);
  }

  /// Releases resources used by this recognizer.
  Future<void> close() {
    if (!_hasBeenOpened) _isClosed = true;
    if (_isClosed) return Future<void>.value();

    _isClosed = true;
    return FirebaseVision.channel.invokeMethod<void>(
      'DocumentTextRecognizer#close',
      <String, dynamic>{'handle': _handle},
    );
  }
}

/// Options for cloud document text recognizer.
///
/// In cases, when the language of the text in the image is known, setting
/// a hint will help get better results (although it will be a significant
/// hindrance if the hint is wrong).
class CloudDocumentRecognizerOptions {
  /// Constructor for [CloudDocumentRecognizerOptions].
  ///
  /// For Latin alphabet based languages, setting language hints is not needed.
  const CloudDocumentRecognizerOptions({this.hintedLanguages});

  /// Language hints for text recognition.
  ///
  /// In most cases, an empty value yields the best results since it enables
  /// automatic language detection.
  ///
  /// Each language code parameter typically consists of a BCP-47 identifier.
  /// See //cloud.google.com/vision/docs/languages for more details.
  final List<String> hintedLanguages;
}

/// Representation for start or end of a structural component.
class DocumentTextRecognizedBreak {
  DocumentTextRecognizedBreak._(dynamic data)
      : detectedBreakType =
            TextRecognizedBreakType.values[data['detectedBreakType']],
        isPrefix = data['detectedBreakPrefix'];

  /// Is set to the detected break type in a text logical component.
  final TextRecognizedBreakType detectedBreakType;

  /// Is set to true if break prepends an element.
  final bool isPrefix;
}

/// Recognized document text in a document image.
class VisionDocumentText {
  VisionDocumentText._(Map<String, dynamic> data)
      : text = data['text'],
        blocks = List<DocumentTextBlock>.unmodifiable(data['blocks']
            .map<DocumentTextBlock>(
                (dynamic block) => DocumentTextBlock._(block)));

  /// String representation of the recognized text.
  final String text;

  /// All recognized text broken down into individual blocks.
  final List<DocumentTextBlock> blocks;
}

/// Abstract class for common attributes of text elements in a document image.
abstract class DocumentTextContainer {
  DocumentTextContainer._(Map<dynamic, dynamic> data)
      : boundingBox = data['left'] != null
            ? Rect.fromLTWH(
                data['left'],
                data['top'],
                data['width'],
                data['height'],
              )
            : null,
        confidence = data['confidence']?.toDouble(),
        recognizedBreak = data['recognizedBreak'] == null
            ? null
            : DocumentTextRecognizedBreak._(data['recognizedBreak']),
        recognizedLanguages = List<RecognizedLanguage>.unmodifiable(
          data['recognizedLanguages'].map<RecognizedLanguage>(
            (dynamic language) => RecognizedLanguage._(language),
          ),
        ),
        text = data['text'];

  /// Axis-aligned bounding rectangle of the detected text.
  ///
  /// The point (0, 0) is defined as the upper-left corner of the image.
  ///
  /// Could be null even if text is found.
  final Rect boundingBox;

  /// The confidence of the recognized text block.
  final double confidence;

  /// Detected start or end of a structural component.
  final DocumentTextRecognizedBreak recognizedBreak;

  /// All detected languages from recognized text.
  ///
  /// Can detect multiple languages. If no languages are
  /// recognized, the list is empty.
  final List<RecognizedLanguage> recognizedLanguages;

  /// The recognized text as a string.
  ///
  /// Returns empty string if nothing is found.
  final String text;
}

/// A logical element on the page.
class DocumentTextBlock extends DocumentTextContainer {
  DocumentTextBlock._(Map<dynamic, dynamic> block)
      : paragraphs = List<DocumentTextParagraph>.unmodifiable(
            block['paragraphs'].map<DocumentTextParagraph>(
                (dynamic paragraph) => DocumentTextParagraph._(paragraph))),
        super._(block);

  /// The content of the document block, broken down into individual paragraphs.
  final List<DocumentTextParagraph> paragraphs;
}

/// A structural unit of text representing a number of words in certain order.
class DocumentTextParagraph extends DocumentTextContainer {
  DocumentTextParagraph._(Map<dynamic, dynamic> paragraph)
      : words = List<DocumentTextWord>.unmodifiable(paragraph['words']
            .map<DocumentTextWord>((dynamic word) => DocumentTextWord._(word))),
        super._(paragraph);

  /// The content of the document paragraph, broken down into individual words.
  final List<DocumentTextWord> words;
}

/// A single word representation.
class DocumentTextWord extends DocumentTextContainer {
  DocumentTextWord._(Map<dynamic, dynamic> word)
      : symbols = List<DocumentTextSymbol>.unmodifiable(word['symbols']
            .map<DocumentTextSymbol>(
                (dynamic symbol) => DocumentTextSymbol._(symbol))),
        super._(word);

  /// The content of the document word, broken down into individual symbols.
  final List<DocumentTextSymbol> symbols;
}

/// A single symbol representation.
class DocumentTextSymbol extends DocumentTextContainer {
  DocumentTextSymbol._(Map<dynamic, dynamic> symbol) : super._(symbol);
}
