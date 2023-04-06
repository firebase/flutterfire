// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:file_selector/file_selector.dart';

class FilePicker {
  final List<String> extensions;
  final List<String> mimeTypes;
  final XTypeGroup _typeGroup;

  FilePicker({
    this.extensions = const [],
    this.mimeTypes = const [],
  }) : _typeGroup = XTypeGroup(
          extensions: extensions,
          mimeTypes: mimeTypes,
        );

  Future<XFile?> pickFile() async {
    final file = await openFile(acceptedTypeGroups: [_typeGroup]);
    return file;
  }
}
