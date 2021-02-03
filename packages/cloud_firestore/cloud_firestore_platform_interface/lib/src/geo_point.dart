// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/material.dart';

/// Represents a geographical point by its longitude and latitude
@immutable
class GeoPoint {
  /// Create [GeoPoint] instance.
  const GeoPoint(this.latitude, this.longitude)
      : assert(latitude >= -90 && latitude <= 90),
        assert(longitude >= -180 && longitude <= 180);

  final double latitude; // ignore: public_member_api_docs
  final double longitude; // ignore: public_member_api_docs

  @override
  bool operator ==(dynamic other) =>
      other is GeoPoint &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => hashValues(latitude, longitude);
}
