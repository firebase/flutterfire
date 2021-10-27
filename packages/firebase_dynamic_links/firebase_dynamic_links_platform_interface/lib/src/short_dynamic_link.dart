/// Response from creating a short dynamic link with [DynamicLinkBuilder].
class ShortDynamicLink {
  const ShortDynamicLink(this.shortUrl, this.warnings);

  /// Short url value.
  final Uri shortUrl;

  /// Information about potential warnings on link creation.
  final List<String>? warnings;
}
