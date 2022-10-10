import 'package:cloud_firestore_platform_interface/src/platform_interface/platform_interface_aggregate_query_snapshot.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../../cloud_firestore_platform_interface.dart';
import '../aggregate_source.dart';
import '../aggregate_type.dart';

abstract class AggregateQueryPlatform extends PlatformInterface {
  AggregateQueryPlatform(this.query, this.aggregateType) : super(token: _token);

  static final Object _token = Object();

  /// Throws an [AssertionError] if [instance] does not extend
  /// [AggregateQueryPlatform].
  ///
  /// This is used by the app-facing [AggregateQuery] to ensure that
  /// the object in which it's going to delegate calls has been
  /// constructed properly.
  static void verifyExtends(AggregateQueryPlatform instance) {
      PlatformInterface.verifyToken(instance, _token);
  }

  final QueryPlatform query;
  final AggregateType aggregateType;

  Future<AggregateQuerySnapshotPlatform> get({required AggregateSource source}) async {
    throw UnimplementedError('get() is not implemented');
  }

}
