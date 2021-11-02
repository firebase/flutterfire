/// Options class for defining navigation behavior of the Dynamic Link.
class NavigationInfoParameters {
  const NavigationInfoParameters({this.forcedRedirectEnabled});

  /// Whether forced non-interactive redirect it to be used.
  ///
  /// Forced non-interactive redirect occurs when link is tapped on mobile
  /// device.
  ///
  /// Default behavior is to disable force redirect and show interstitial page
  /// where user tap will initiate navigation to the App (or AppStore if not
  /// installed). Disabled force redirect normally improves reliability of the
  /// click.
  final bool? forcedRedirectEnabled;

  Map<String, dynamic> get data => <String, dynamic>{
        'forcedRedirectEnabled': forcedRedirectEnabled,
      };
}
