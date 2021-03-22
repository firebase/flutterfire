// @dart=2.9

import 'package:meta/meta.dart';

/// Defines the options for the corresponding Remote Config instance.
class RemoteConfigSettings {
  /// Constructs an instance of [RemoteConfigSettings] with given [fetchTimeout]
  /// and [minimumFetchInterval].
  RemoteConfigSettings({
    @required this.fetchTimeout,
    @required this.minimumFetchInterval,
  });

  /// Maximum Duration to wait for a response when fetching configuration from
  /// the Remote Config server. Defaults to one minute.
  Duration fetchTimeout;

  /// Maximum age of a cached config before it is considered stale. Defaults
  /// to twelve hours.
  Duration minimumFetchInterval;
}
