// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';
import 'package:json_annotation/json_annotation.dart';

part 'query.g.dart';

@Collection<DateTimeQuery>('firestore-example-app/42/date-time')
final dateTimeQueryRef = DateTimeQueryCollectionReference();

@JsonSerializable(converters: firestoreJsonConverters)
class DateTimeQuery {
  DateTimeQuery(this.time);
  final DateTime time;
}

class FirestoreDateTimeConverter extends JsonConverter<DateTime, Timestamp> {
  const FirestoreDateTimeConverter();
  @override
  DateTime fromJson(Timestamp json) => json.toDate();

  @override
  Timestamp toJson(DateTime object) => Timestamp.fromDate(object);
}

@Collection<TimestampQuery>('firestore-example-app/42/timestamp-time')
final timestampQueryRef = TimestampQueryCollectionReference();

@JsonSerializable(converters: firestoreJsonConverters)
class TimestampQuery {
  TimestampQuery(this.time);
  final Timestamp time;
}

@Collection<GeoPointQuery>('firestore-example-app/42/geopoint-time')
final geoPointQueryRef = GeoPointQueryCollectionReference();

@JsonSerializable(converters: firestoreJsonConverters)
class GeoPointQuery {
  GeoPointQuery(this.point);
  final GeoPoint point;
}

@Collection<DocumentReferenceQuery>('firestore-example-app/42/doc-ref')
final documentReferenceRef = DocumentReferenceQueryCollectionReference();

@JsonSerializable(converters: firestoreJsonConverters)
class DocumentReferenceQuery {
  DocumentReferenceQuery(this.ref);

  final DocumentReference<Map<String, dynamic>> ref;
}
