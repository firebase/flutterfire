import 'package:cloud_firestore_platform_interface/src/method_channel/utils/source.dart';
import 'package:cloud_firestore_platform_interface/src/platform_interface/platform_interface_aggregate_query.dart';

import 'method_channel_firestore.dart';
import 'method_channel_aggregate_query_snapshot.dart';
import '../../cloud_firestore_platform_interface.dart';
import '../aggregate_source.dart';
import '../aggregate_type.dart';
import '../platform_interface/platform_interface_aggregate_query_snapshot.dart';

class MethodChannelAggregateQuery extends AggregateQueryPlatform {
  MethodChannelAggregateQuery(QueryPlatform query, AggregateType aggregateType) : super(query, aggregateType);

  @override
  Future<AggregateQuerySnapshotPlatform> get({required AggregateSource source}) async {
    final Map<String, dynamic>? data = await MethodChannelFirebaseFirestore
        .channel
        .invokeMapMethod<String, dynamic>(
      'AggregateQuery#get',
      <String, dynamic>{
        'query': query,
        'firestore': query.firestore,
        'source': getAggregateSourceString(source),
      },
    );

    return MethodChannelAggregateQuerySnapshot(
       count: data!['count'] as int,
    );
  }
}
