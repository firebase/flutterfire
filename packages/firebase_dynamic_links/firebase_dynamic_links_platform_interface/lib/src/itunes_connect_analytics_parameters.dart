/// The Dynamic Link iTunes Connect parameters.
class ItunesConnectAnalyticsParameters {
  const ItunesConnectAnalyticsParameters(
      {this.affiliateToken, this.campaignToken, this.providerToken});

  /// The iTunes Connect affiliate token.
  final String? affiliateToken;

  /// The iTunes Connect campaign token.
  final String? campaignToken;

  /// The iTunes Connect provider token.
  final String? providerToken;

  Map<String, dynamic> asMap() => <String, dynamic>{
        'affiliateToken': affiliateToken,
        'campaignToken': campaignToken,
        'providerToken': providerToken,
      };

  @override
  String toString() {
    return '$ItunesConnectAnalyticsParameters($asMap)';
  }
}
