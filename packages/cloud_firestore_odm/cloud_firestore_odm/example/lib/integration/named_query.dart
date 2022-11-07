import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'named_query.g.dart';

@NamedQuery<Conflict>('named-bundle-test-4')
@Collection<Conflict>('firestore-example-app/42/named-query-conflict')
@JsonSerializable()
class Conflict {
  Conflict(this.number);

  final num number;
}
