// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../pigeon/messages.pigeon.dart';

/// Converts [Source] to [String]
String getSourceString(Source source) {
  return switch (source) {
    Source.server => 'server',
    Source.cache => 'cache',
    _ => 'default'
  };
}

/// Converts [AggregateSource] to [String]
String getAggregateSourceString(AggregateSource source) {
  return switch (source) {
    AggregateSource.server => 'server',
  };
}
