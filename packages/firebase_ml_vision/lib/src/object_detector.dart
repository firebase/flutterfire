// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_ml_vision;

/// Detection mode: `stream` | `single`
/// In `stream` mode, the object detector runs with low latency, but might produce incomplete results (such as unspecified bounding boxes or category labels) on the first few invocations of the detector.
/// Also, in `stream`, the detector assigns tracking IDs to objects, which you can use to track objects across frames. Use this mode when you want to track objects, or when low latency is important, such as when processing video streams in real time.
///
/// In `single`, the object detector returns the result after the object's bounding box is determined. If you also enable classification it returns the result after the bounding box and category label are both available.
/// As a consequence, detection latency is potentially higher. Also, in `single`, tracking IDs are not assigned. Use this mode if latency isn't critical and you don't want to deal with partial results.
enum ObjectDetectorMode { stream, single }

/// Detector for detecting objects in an input image.
///
/// The object detector is created via
/// `objectDetector([ObjectDetectorOptions options])` in [FirebaseVision]:
///
/// ```dart
/// final FirebaseVisionImage image =
///     FirebaseVisionImage.fromFilePath('path/to/file');
///
/// final ObjectDetector objectDetector = FirebaseVision.instance.objectDetector();
///
/// final List<DetectedObject> objects = await objectDetector.processImage(image);
/// ```
class ObjectDetector {
  ObjectDetector._(this.options, this._handle) : assert(options != null);

  /// The options for the object detector.
  final ObjectDetectorOptions options;
  final int _handle;
  bool _hasBeenOpened = false;
  bool _isClosed = false;

  /// Detects objects in the input image.
  Future<List<DetectedObject>> processImage(
      FirebaseVisionImage visionImage) async {
    assert(!_isClosed);

    _hasBeenOpened = true;
    final List<dynamic> reply =
        await FirebaseVision.channel.invokeListMethod<dynamic>(
      'ObjectDetector#processImage',
      <String, dynamic>{
        'handle': _handle,
        'options': <String, dynamic>{
          'enableClassification': options.enableClassification,
          'enableMultipleObjects': options.enableMultipleObjects,
          'mode': _enumToString(options.mode),
        },
      }..addAll(visionImage._serialize()),
    );

    final List<DetectedObject> objects = <DetectedObject>[];
    for (dynamic data in reply) {
      objects.add(DetectedObject._(data));
    }

    return objects;
  }

  /// Release resources used by this detector.
  Future<void> close() {
    if (!_hasBeenOpened) _isClosed = true;
    if (_isClosed) return Future<void>.value(null);

    _isClosed = true;
    return FirebaseVision.channel.invokeMethod<void>(
      'ObjectDetector#close',
      <String, dynamic>{'handle': _handle},
    );
  }
}

/// Immutable options for configuring features of [ObjectDetector].
///
/// Used to configure features such as detection mode, enable classification, enable multiple objects
class ObjectDetectorOptions {
  /// Constructor for [ObjectDetectorOptions].
  const ObjectDetectorOptions({
    this.enableClassification = false,
    this.enableMultipleObjects = false,
    this.mode = ObjectDetectorMode.stream,
  });

  /// Whether to run additional classifiers for the object class
  ///
  /// Currently only classes defined as [DetectedObjectClass] are supported
  final bool enableClassification;

  /// Whether to detect and track up to five objects or only the most prominent object (default).
  final bool enableMultipleObjects;

  /// Object detection mode.
  final ObjectDetectorMode mode;
}

/// Represents a detected object by [ObjectDetector].
class DetectedObject {
  DetectedObject._(dynamic data)
      : boundingBox = Rect.fromLTWH(
          data['left'],
          data['top'],
          data['width'],
          data['height'],
        ),
        confidence = data['confidence'],
        trackingId = data['trackingId'],
        category = DetectedObjectCategory.values.firstWhere((e) =>
            e.toString().substring(e.toString().lastIndexOf('.') + 1) ==
            data['category']);

  /// The axis-aligned bounding rectangle of the detected object.
  ///
  /// The point (0, 0) is defined as the upper-left corner of the image.
  final Rect boundingBox;

  /// The tracking ID if the tracking is enabled.
  ///
  /// Null if tracking was not enabled.
  final int trackingId;

  /// The category of detected object
  ///
  /// Null if classification was not enabled
  final DetectedObjectCategory category;

  /// The overall confidence of the result. Range [0.0, 1.0].
  final double confidence;
}

/// Represents category of detected object
enum DetectedObjectCategory {
  HOME_GOOD,
  FASHION_GOOD,
  FOOD,
  PLACE,
  PLANT,
  UNKNOWN
}
