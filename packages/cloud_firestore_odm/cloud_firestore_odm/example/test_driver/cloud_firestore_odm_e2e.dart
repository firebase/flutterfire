// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:drive/drive.dart' as drive;

import 'collection_reference_test.dart' as collection_reference_test;
import 'document_reference_test.dart' as document_reference_test;
import 'path_test.dart' as path_test;
import 'query_reference_test.dart' as query_reference_test;

void testsMain() {
  collection_reference_test.main();
  document_reference_test.main();
  // TODO CI tests configuration currently not compatible with widget testing
  // firestore_builder_test.main();
  query_reference_test.main();
  path_test.main();
}

void main() => drive.main(testsMain);
