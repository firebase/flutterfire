// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_ml_vision;

/// Option for controlling additional trade-offs in performing landmark detection.
///
/// Available model types detected by [LandmakrDetector].
enum LandmarkModelType { latest_model, stable_model }

/// Detector for detecting landmarks in an input image.
///
/// A landmark detector is created via
/// `landmarkDetector([LandmarkDetectorOptions options])` in [FirebaseVision]:
///
/// ```dart
/// final FirebaseVisionImage image =
///     FirebaseVisionImage.fromFilePath('path/to/file');
///
/// final LandmarkDetector landmarkDetector = FirebaseVision.instance.landmarkDetector();
///
/// final List<Landmark> landmarks = await landmarkDetector.processImage(image);
/// ```
class LandmarkDetector {
  LandmarkDetector._(this.options, this._handle) : assert(options != null);

  /// The options for the landmark detector.
  final LandmarkDetectorOptions options;
  final int _handle;
  bool _hasBeenOpened = false;
  bool _isClosed = false;

  /// Detects landmark in the input image.
  Future<List<Landmark>> processImage(FirebaseVisionImage visionImage) async {
    assert(!_isClosed);

    _hasBeenOpened = true;
    final List<dynamic> reply =
        await FirebaseVision.channel.invokeListMethod<dynamic>(
      'LandmarkDetector#processImage',
      <String, dynamic>{
        'handle': _handle,
        'options': <String, dynamic>{
          'maxResults': options.maxResults,
          'modelType': _enumToString(options.modelType)
        },
      }..addAll(visionImage._serialize()),
    );

    final List<Landmark> landmarks = <Landmark>[];
    for (dynamic data in reply) {
      landmarks.add(Landmark._(data));
    }

    return landmarks;
  }

  /// Release resources used by this detector.
  Future<void> close() {
    if (!_hasBeenOpened) _isClosed = true;
    if (_isClosed) return Future<void>.value(null);

    _isClosed = true;
    return FirebaseVision.channel.invokeMethod<void>(
      'LandmarkDetector#close',
      <String, dynamic>{'handle': _handle},
    );
  }
}

/// Immutable options for configuring features of [LandmarkDetector].
///
/// Used to configure features such as maxResults, modelType.
class LandmarkDetectorOptions {
  /// Constructor for [LandmarkDetectorOptions].
  const LandmarkDetectorOptions({
    this.maxResults = 10,
    this.modelType = LandmarkModelType.stable_model,
  });

  /// The maximum number of results of the specified type.
  final int maxResults;

  /// The model type for the detection
  final LandmarkModelType modelType;
}

/// Represents a landmark detected by [LandmarkDetector].
class Landmark {
  Landmark._(dynamic data)
      : boundingBox = Rect.fromLTWH(
          data['left'],
          data['top'],
          data['width'],
          data['height'],
        ),
        confidence = data['confidence'],
        entityId = data['entityId'],
        landmark = data['landmark'],
        _locations = data['locations'] == null
            ? null
            : data['locations']
                .map<LandmarkLocation>((dynamic location) => LandmarkLocation._(
                      location['lat'],
                      location['lng'],
                    ))
                .toList();

  final List<LandmarkLocation> _locations;

  /// The axis-aligned bounding rectangle of the detected face.
  ///
  /// The point (0, 0) is defined as the upper-left corner of the image.
  final Rect boundingBox;

  /// The overall confidence of the result.
  final double confidence;

  /// The opaque entity ID.
  final String entityId;

  /// The detected landmark.
  final String landmark;

  /// Gets the location information for the detected entity.
  List<LandmarkLocation> getLocations() => _locations;
}

/// Represent a landmark location.
class LandmarkLocation {
  LandmarkLocation._(this.lat, this.lng);

  /// The latitude of this location.
  final double lat;

  /// The longitude of this location.
  final double lng;
}
