class RemoteConfigSettings {

  /// docs
  RemoteConfigSettings(this.fetchTimeout, this.minimumFetchInterval);

  Duration fetchTimeout;
  Duration minimumFetchInterval;
}
