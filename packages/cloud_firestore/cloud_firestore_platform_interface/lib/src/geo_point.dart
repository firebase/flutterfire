// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:ui';

/// Represents a geographical point by its longitude and latitude
class GeoPoint {
  /// Create [GeoPoint] instance
  const GeoPoint(this.latitude, this.longitude);

  final double latitude; // ignore: public_member_api_docs
  final double longitude; // ignore: public_member_api_docs

  @override
  bool operator ==(dynamic o) =>
      o is GeoPoint && o.latitude == latitude && o.longitude == longitude;

  @override
  int get hashCode => hashValues(latitude, longitude);
}
