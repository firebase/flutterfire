// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// Specifies custom configurations for your Cloud Firestore instance.
///
/// You must set these before invoking any other methods.
@immutable
class Settings {
  /// Creates an instance for these [Settings].
  const Settings({
    this.persistenceEnabled,
    this.host,
    this.sslEnabled,
    this.cacheSizeBytes,
    this.webExperimentalForceLongPolling,
    this.webExperimentalAutoDetectLongPolling,
    this.webExperimentalLongPollingOptions,
    this.ignoreUndefinedProperties = false,
  });

  /// Constant used to indicate the LRU garbage collection should be disabled.
  ///
  /// Set this value as the cacheSizeBytes on the settings passed to the Firestore instance.
  static const int CACHE_SIZE_UNLIMITED = -1;

  /// Attempts to enable persistent storage, if possible.
  final bool? persistenceEnabled;

  /// The hostname to connect to.
  final String? host;

  /// Whether to use SSL when connecting.
  final bool? sslEnabled;

  /// An approximate cache size threshold for the on-disk data.
  ///
  /// If the cache grows beyond this size, Firestore will start removing data that hasn't
  /// been recently used. The size is not a guarantee that the cache will stay
  /// below that size, only that if the cache exceeds the given size, cleanup
  /// will be attempted.
  ///
  /// The default value is 40 MB. The threshold must be set to at least 1 MB,
  /// and can be set to [Settings.CACHE_SIZE_UNLIMITED] to disable garbage collection.
  final int? cacheSizeBytes;

  /// Whether to skip nested properties that are set to undefined during object serialization.
  ///
  /// If set to true, these properties are skipped and not written to Firestore. If set to false
  /// or omitted, the SDK throws an exception when it encounters properties of type undefined.
  /// Web only.
  final bool ignoreUndefinedProperties;

  /// Forces the SDK’s underlying network transport (WebChannel) to use long-polling.
  ///
  /// Each response from the backend will be closed immediately after the backend sends data
  /// (by default responses are kept open in case the backend has more data to send).
  /// This avoids incompatibility issues with certain proxies, antivirus software, etc.
  /// that incorrectly buffer traffic indefinitely.
  /// Use of this option will cause some performance degradation though.
  final bool? webExperimentalForceLongPolling;

  ///	Configures the SDK's underlying transport (WebChannel) to automatically detect if long-polling should be used.
  ///
  ///This is very similar to [webExperimentalForceLongPolling], but only uses long-polling if required.
  final bool? webExperimentalAutoDetectLongPolling;

  /// Options that configure the SDK’s underlying network transport (WebChannel) when long-polling is used.
  ///
  /// These options are only used if experimentalForceLongPolling is true
  /// or if [webExperimentalAutoDetectLongPolling] is true and the auto-detection determined that long-polling was needed.
  /// Otherwise, these options have no effect.
  final WebExperimentalLongPollingOptions? webExperimentalLongPollingOptions;

  /// Returns the settings as a [Map]
  Map<String, dynamic> get asMap {
    return {
      'persistenceEnabled': persistenceEnabled,
      'host': host,
      'sslEnabled': sslEnabled,
      'cacheSizeBytes': cacheSizeBytes,
      'webExperimentalForceLongPolling': webExperimentalForceLongPolling,
      'webExperimentalAutoDetectLongPolling':
          webExperimentalAutoDetectLongPolling,
      'webExperimentalLongPollingOptions':
          webExperimentalLongPollingOptions?.asMap,
      if (kIsWeb) 'ignoreUndefinedProperties': ignoreUndefinedProperties,
    };
  }

  Settings copyWith({
    bool? persistenceEnabled,
    String? host,
    bool? sslEnabled,
    int? cacheSizeBytes,
    bool? webExperimentalForceLongPolling,
    bool? webExperimentalAutoDetectLongPolling,
    bool? ignoreUndefinedProperties,
    WebExperimentalLongPollingOptions? webExperimentalLongPollingOptions,
  }) {
    assert(
        cacheSizeBytes == null ||
            cacheSizeBytes == CACHE_SIZE_UNLIMITED ||
            // 1mb and 100mb. minimum and maximum inclusive range.
            (cacheSizeBytes >= 1048576 && cacheSizeBytes <= 104857600),
        'Cache size must be between 1048576 bytes (inclusive) and 104857600 bytes (inclusive)');

    return Settings(
      persistenceEnabled: persistenceEnabled ?? this.persistenceEnabled,
      host: host ?? this.host,
      sslEnabled: sslEnabled ?? this.sslEnabled,
      cacheSizeBytes: cacheSizeBytes ?? this.cacheSizeBytes,
      webExperimentalForceLongPolling: webExperimentalForceLongPolling ??
          this.webExperimentalForceLongPolling,
      webExperimentalAutoDetectLongPolling:
          webExperimentalAutoDetectLongPolling ??
              this.webExperimentalAutoDetectLongPolling,
      webExperimentalLongPollingOptions: webExperimentalLongPollingOptions ??
          this.webExperimentalLongPollingOptions,
      ignoreUndefinedProperties:
          ignoreUndefinedProperties ?? this.ignoreUndefinedProperties,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Settings &&
      other.runtimeType == runtimeType &&
      other.persistenceEnabled == persistenceEnabled &&
      other.host == host &&
      other.sslEnabled == sslEnabled &&
      other.cacheSizeBytes == cacheSizeBytes &&
      other.webExperimentalForceLongPolling ==
          webExperimentalForceLongPolling &&
      other.webExperimentalAutoDetectLongPolling ==
          webExperimentalAutoDetectLongPolling &&
      other.webExperimentalLongPollingOptions ==
          webExperimentalLongPollingOptions &&
      other.ignoreUndefinedProperties == ignoreUndefinedProperties;

  @override
  int get hashCode => Object.hash(
        runtimeType,
        persistenceEnabled,
        host,
        sslEnabled,
        cacheSizeBytes,
        webExperimentalForceLongPolling,
        webExperimentalAutoDetectLongPolling,
        webExperimentalLongPollingOptions,
        ignoreUndefinedProperties,
      );

  @override
  String toString() => 'Settings($asMap)';
}

/// Options that configure the SDK’s underlying network transport (WebChannel) when long-polling is used.
@immutable
class WebExperimentalLongPollingOptions {
  /// The desired maximum timeout interval, in seconds, to complete a long-polling GET response
  ///
  /// Valid values are between 5 and 30, inclusive.
  /// By default, when long-polling is used the "hanging GET" request sent by the client times out after 30 seconds.
  /// To request a different timeout from the server, set this setting with the desired timeout.
  /// Changing the default timeout may be useful, for example,
  /// if the buffering proxy that necessitated enabling long-polling in the first place has a shorter timeout for hanging GET requests,
  /// in which case setting the long-polling timeout to a shorter value,
  /// such as 25 seconds, may fix prematurely-closed hanging GET requests.
  final Duration? timeoutDuration;

  const WebExperimentalLongPollingOptions({
    this.timeoutDuration,
  });

  Map<String, dynamic> get asMap {
    return {
      'timeoutDuration': timeoutDuration?.inSeconds,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is WebExperimentalLongPollingOptions &&
      other.runtimeType == runtimeType &&
      other.timeoutDuration == timeoutDuration;

  @override
  int get hashCode => Object.hash(runtimeType, timeoutDuration);
}
