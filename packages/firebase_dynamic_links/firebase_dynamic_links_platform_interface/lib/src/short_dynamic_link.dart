/// Response from creating a short dynamic link with [DynamicLinkBuilder].
class ShortDynamicLink {
  const ShortDynamicLink({
    required this.shortUrl,
    this.warnings,
    this.previewLink,
  });

  /// Short url value.
  final Uri shortUrl;

  /// Gets the preview link to show the link flow chart. Android only.
  final Uri? previewLink;

  /// Information about potential warnings on link creation.
  final List<String>? warnings;

  /// Returns the current instance as a [Map].
  Map<String, dynamic> asMap() => <String, dynamic>{
        'shortUrl': shortUrl.toString(),
        'previewLink': previewLink.toString(),
        'warnings': warnings,
      };

  @override
  String toString() {
    return '$ShortDynamicLink($asMap)';
  }
}
