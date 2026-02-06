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
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:camera_macos/camera_macos.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class VideoInput extends ChangeNotifier {
  List<dynamic> _cameras = [];
  dynamic _cameraController;
  dynamic _selectedCamera;
  bool controllerInitialized = false;
  Timer? _captureTimer;
  StreamController<Uint8List> _imageStreamController = StreamController();
  bool _isStreaming = false;

  List<dynamic> get cameras => _cameras;
  dynamic get cameraController => _cameraController;

  Future<void> init() async {
    try {
      if (!kIsWeb && Platform.isMacOS) {
        _cameras = await CameraMacOS.instance.listDevices();
      } else {
        _cameras = await availableCameras();
      }
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
      if (!kIsWeb && Platform.isMacOS) {
        (_cameraController as CameraMacOSController).destroy();
      } else {
        (_cameraController as CameraController).dispose();
      }
    }
  }

  String? get selectedCameraId {
    if (_selectedCamera == null) return null;
    if (!kIsWeb && Platform.isMacOS) {
      return (_selectedCamera as CameraMacOSDevice).deviceId;
    }
    return null;
  }

  void setMacOSController(CameraMacOSController controller) {
    _cameraController = controller;
    controllerInitialized = true;
    notifyListeners();
  }

  Future<void> initializeCameraController() async {
    if (controllerInitialized && _cameraController != null) {
      if (!kIsWeb && Platform.isMacOS) {
        await (_cameraController as CameraMacOSController).destroy();
      } else {
        await (_cameraController as CameraController).dispose();
      }
      controllerInitialized = false;
    }

    if (_selectedCamera == null) {
      log("No camera selected or available.");
      return;
    }

    if (!kIsWeb && Platform.isMacOS) {
      // On macOS, we rely on CameraMacOSView to initialize the controller.
      controllerInitialized = false;
      notifyListeners();
    } else {
      _cameraController = CameraController(
        _selectedCamera as CameraDescription,
        ResolutionPreset.veryHigh,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      try {
        await (_cameraController as CameraController).initialize();
        controllerInitialized = true;
        notifyListeners();
      } catch (e) {
        log('Error initializing camera: $e');
      }
    }
  }

  Stream<Uint8List> startStreamingImages() {
    final bool isInitialized = !kIsWeb && Platform.isMacOS
        ? _cameraController != null
        : (_cameraController as CameraController?)?.value.isInitialized ??
            false;

    if (_cameraController == null || !isInitialized) {
      throw ErrorSummary('Unable to start image stream');
    }

    _captureTimer = Timer.periodic(
      const Duration(seconds: 1), // Capture images at 1 frame per second
      (timer) async {
        final bool currentIsInitialized = !kIsWeb && Platform.isMacOS
            ? _cameraController != null
            : (_cameraController as CameraController?)?.value.isInitialized ??
                false;

        if (_cameraController == null ||
            !currentIsInitialized ||
            !_isStreaming) {
          log("Stopping timer due to invalid state.");
          stopStreamingImages();
          return;
        }

        try {
          if (!kIsWeb && Platform.isMacOS) {
            final controller = _cameraController as CameraMacOSController;
            log("Taking picture (macOS)...");
            final CameraMacOSFile? image = await controller.takePicture();
            if (image != null && image.bytes != null) {
              _imageStreamController.add(image.bytes!);
            }
          } else {
            final controller = _cameraController as CameraController;
            if (controller.value.isTakingPicture) return;
            log("Taking picture...");
            final XFile imageFile = await controller.takePicture();
            Uint8List imageBytes = await imageFile.readAsBytes();
            _imageStreamController.add(imageBytes);
          }
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
      if (!kIsWeb && Platform.isMacOS) {
        final currentSelected = _selectedCamera as CameraMacOSDevice;
        final otherCamera = _cameras.firstWhere(
          (camera) =>
              (camera as CameraMacOSDevice).deviceId !=
              currentSelected.deviceId,
          orElse: () => _cameras[0],
        );
        _selectedCamera = otherCamera;
      } else {
        final currentSelected = _selectedCamera as CameraDescription;
        final otherCamera = _cameras.firstWhere(
          (camera) =>
              (camera as CameraDescription).lensDirection !=
              currentSelected.lensDirection,
          orElse: () => _cameras[0],
        );
        _selectedCamera = otherCamera;
      }
      await initializeCameraController();
    }
  }
}
