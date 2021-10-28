/// Response from creating a short dynamic link with [DynamicLinkBuilder].
class ShortDynamicLink {
  const ShortDynamicLink(this.shortUrl, this.warnings, this.previewLink);

  /// Short url value.
  final Uri shortUrl;

  /// Gets the preview link to show the link flow chart..
  final Uri previewLink;

  /// Information about potential warnings on link creation.
  final List<String>? warnings;
}
