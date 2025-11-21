// Copyright 2025 Google LLC
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

import 'dart:developer';
import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class VideoInput extends ChangeNotifier {
  late List<CameraDescription> _cameras;
  CameraController? _cameraController;
  CameraDescription? _selectedCamera;
  bool controllerInitialized = false;
  Timer? _captureTimer;
  StreamController<Uint8List> _imageStreamController = StreamController();
  bool _isStreaming = false;

  List<CameraDescription> get cameras => _cameras;
  CameraController? get cameraController => _cameraController;

  Future<void> init() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _selectedCamera = _cameras[0];
      }
    } catch (e) {
      log('Error getting available cameras: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    stopStreamingImages();
    if (controllerInitialized && _cameraController != null) {
      _cameraController!.dispose();
    }
  }

  Future<void> initializeCameraController() async {
    var cameraController = _cameraController;
    if (controllerInitialized && cameraController != null) {
      await cameraController.dispose();
      controllerInitialized = false;
    }

    if (_selectedCamera == null) {
      log("No camera selected or available.");
      return;
    }

    _cameraController = CameraController(
      _selectedCamera!,
      ResolutionPreset.veryHigh,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    try {
      await _cameraController!.initialize();
      controllerInitialized = true;
      notifyListeners();
    } catch (e) {
      log('Error initializing camera: $e');
    }
  }

  Stream<Uint8List> startStreamingImages() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      throw ErrorSummary('Unable to start image stream');
    }

    _captureTimer = Timer.periodic(
      const Duration(seconds: 1), // Capture images at 1 frame per second
      (timer) async {
        if (_cameraController == null ||
            !_cameraController!.value.isInitialized ||
            !_isStreaming) {
          log("Stopping timer due to invalid state.");
          stopStreamingImages();
          return;
        }

        try {
          // Prevent taking picture if already taking one
          if (_cameraController!.value.isTakingPicture) {
            return;
          }
          log("Taking picture...");
          final XFile imageFile = await _cameraController!.takePicture();
          Uint8List imageBytes = await imageFile.readAsBytes();
          _imageStreamController.add(imageBytes);
        } catch (e) {
          log('Error taking picture: $e');
        }
      },
    );
    _isStreaming = true;
    return _imageStreamController.stream;
  }

  /// Stops the periodic image capture and closes the stream.
  Future<void> stopStreamingImages() async {
    if (!_isStreaming) {
      return; // Nothing to stop
    }
    _captureTimer?.cancel();
    await _imageStreamController.close();
    _imageStreamController = StreamController();
    _isStreaming = false;
  }

  Future<void> flipCamera() async {
    if (_cameras.length > 1) {
      final otherCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection != _selectedCamera?.lensDirection,
        orElse: () => _cameras[0],
      );
      _selectedCamera = otherCamera;
      await initializeCameraController();
    }
  }
}
