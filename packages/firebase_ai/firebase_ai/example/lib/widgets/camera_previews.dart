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

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_macos/camera_macos.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';

class SquareCameraPreview extends StatelessWidget {
  const SquareCameraPreview({
    required this.controller,
    this.deviceId,
    this.onInitialized,
    super.key,
  });

  final dynamic controller;
  final String? deviceId;
  final Function(CameraMacOSController)? onInitialized;

  @override
  Widget build(BuildContext context) {
    double aspectRatio = 1.0;
    if (!kIsWeb && Platform.isMacOS) {
      //aspectRatio = (controller as CameraMacOSController?)?.aspectRatio ?? 1.0;
    } else {
      aspectRatio = (controller as CameraController?)?.value.aspectRatio ?? 1.0;
    }

    return Center(
      child: Container(
        width: 352, // Adjusted from 350 to be a multiple of 4
        height: 352,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(16),
            ),
            // The camera preview is often not a square. To fill the 1:1 aspect
            // ratio, we scale the preview to cover the area and clip it.
            child: Transform.scale(
              scale: aspectRatio / 1,
              child: Center(
                child: !kIsWeb && Platform.isMacOS
                    ? CameraMacOSView(
                        deviceId: deviceId,
                        cameraMode: CameraMacOSMode.photo,
                        enableAudio: false,
                        onCameraInizialized:
                            (CameraMacOSController controller) {
                          onInitialized?.call(controller);
                        },
                      )
                    : CameraPreview(controller as CameraController),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FullCameraPreview extends StatefulWidget {
  const FullCameraPreview({
    required this.controller,
    this.deviceId,
    this.onInitialized,
    super.key,
  });

  final dynamic controller;
  final String? deviceId;
  final Function(CameraMacOSController)? onInitialized;

  @override
  State<FullCameraPreview> createState() => _FullCameraPreviewState();
}

class _FullCameraPreviewState extends State<FullCameraPreview>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this, // the SingleTickerProviderStateMixin
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _animController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: !kIsWeb && Platform.isMacOS
            ? CameraMacOSView(
                deviceId: widget.deviceId,
                cameraMode: CameraMacOSMode.photo,
                enableAudio: false,
                onCameraInizialized: (CameraMacOSController controller) {
                  widget.onInitialized?.call(controller);
                },
              )
            : CameraPreview(widget.controller as CameraController),
      ),
    ).animate(controller: _animController).scaleXY().fadeIn();
  }
}
