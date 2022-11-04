// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/collection_generator.dart';
import 'src/validator_generator.dart';

/// Builds generators for `build_runner` to run
Builder firebase(BuilderOptions options) {
  return SharedPartBuilder(
    [
      CollectionGenerator(),
      ValidatorGenerator(),
    ],
    'firebase',
  );
}
