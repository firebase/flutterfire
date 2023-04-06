// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_ui_storage/firebase_ui_storage.dart';
import 'package:flutter/material.dart';

import 'apps.dart';

class UploadButtonApp extends StatelessWidget implements App {
  const UploadButtonApp({super.key});

  @override
  String get name => 'UploadButton';

  @override
  Widget build(BuildContext context) {
    return UploadButton(
      onError: (e, s) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      ),
      onUploadComplete: (ref) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload complete: ${ref.fullPath}'),
        ),
      ),
      variant: ButtonVariant.filled,
    );
  }
}
