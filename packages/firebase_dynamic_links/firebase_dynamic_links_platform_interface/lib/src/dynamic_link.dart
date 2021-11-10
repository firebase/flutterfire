/// Response from creating a dynamic link with [DynamicLinkBuilder].
class DynamicLink {
  const DynamicLink({required this.url});

  /// url value.
  final Uri url;

  Map<String, dynamic> asMap() => <String, dynamic>{
        'url': url.toString(),
      };

  @override
  String toString() {
    return '$DynamicLink($asMap)';
  }
}
