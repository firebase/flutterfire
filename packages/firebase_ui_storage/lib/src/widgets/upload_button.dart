// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_shared/firebase_ui_shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../config.dart';
import '../file_picker.dart';

/// A button that uploads a file to Firebase Storage.
/// While upload is in progress, a [LoadingIndicator] is shown.
/// If an error occurs, [onError] is called.
class UploadButton extends StatefulWidget {
  /// The storage instance to use.
  /// If not specified, [FirebaseStorage.instance] is used.
  final FirebaseStorage? storage;

  /// {@macro ui.shared.widgets.button_variant}
  final ButtonVariant variant;

  /// A callback that is called when an error occurs.
  final void Function(Object? error, StackTrace? stackTrace) onError;

  /// A list of file extensions that can be selected.
  /// If not specified, all files are allowed.
  final List<String> extensions;

  /// A list of mime types that can be selected.
  /// If not specified, all files are allowed.
  final List<String> mimeTypes;

  /// A callback that is called when the upload is started.
  final Function(UploadTask task)? onUploadStarted;

  /// A callback that is called when the upload is complete.
  final Function(Reference ref) onUploadComplete;

  /// A metadata to be set on the uploaded file.
  final SettableMetadata? metadata;

  const UploadButton({
    super.key,
    required this.onError,
    required this.onUploadComplete,
    this.onUploadStarted,
    this.storage,
    this.variant = ButtonVariant.filled,
    this.extensions = const [],
    this.mimeTypes = const [],
    this.metadata,
  });

  @override
  State<UploadButton> createState() => _UploadButtonState();
}

class _UploadButtonState extends State<UploadButton> {
  bool isLoading = false;
  FirebaseStorage get storage => widget.storage ?? FirebaseStorage.instance;

  late final filePicker = FilePicker(
    extensions: widget.extensions,
    mimeTypes: widget.mimeTypes,
  );

  Future<void> _upload(FirebaseUIStorageConfiguration config) async {
    try {
      setState(() {
        isLoading = true;
      });

      final file = await filePicker.pickFile();
      if (file == null) return;

      final childRef = config.namingPolicy.getUploadFileName(file.name);
      final ref = config.uploadRoot.child(childRef);

      UploadTask task;

      if (!kIsWeb) {
        task = ref.putFile(File(file.path));
      } else {
        task = ref.putData(await file.readAsBytes(), widget.metadata);
      }

      widget.onUploadStarted?.call(task);
      await task;
      widget.onUploadComplete(ref);
    } catch (e, stackTrace) {
      widget.onError(e, stackTrace);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = context.configFor(storage);

    return LoadingButton(
      label: 'Upload file', // TOOD(lesnitsky): i18n
      cupertinoIcon: CupertinoIcons.cloud_upload,
      materialIcon: Icons.upload_outlined,
      isLoading: isLoading,
      variant: widget.variant,
      onTap: () => _upload(config),
    );
  }
}
