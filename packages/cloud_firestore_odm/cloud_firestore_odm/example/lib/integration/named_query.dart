import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'named_query.g.dart';

@NamedQuery<OnlyNamedQuery>('only_named_query')
@JsonSerializable()
class OnlyNamedQuery {
  OnlyNamedQuery(this.value);

  final int value;
}

@NamedQuery<Conflict>('conflict-query')
@Collection<Conflict>('firestore-example-app/42/named-query-conflict')
@JsonSerializable()
class Conflict {
  Conflict(this.value);

  final int value;
}
