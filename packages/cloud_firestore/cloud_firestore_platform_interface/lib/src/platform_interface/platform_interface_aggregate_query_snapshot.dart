import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class AggregateQuerySnapshotPlatform extends PlatformInterface {
  AggregateQuerySnapshotPlatform({required count}) : _count = count, super(token: _token);

  static final Object _token = Object();

  /// Throws an [AssertionError] if [instance] does not extend
  /// [AggregateQuerySnapshotPlatform].
  ///
  /// This is used by the app-facing [AggregateQuerySnapshot] to ensure that
  /// the object in which it's going to delegate calls has been
  /// constructed properly.
  static void verifyExtends(AggregateQuerySnapshotPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
  }

  final int _count;

  int get count => _count;
}
