/// The Dynamic Link Social Meta Tag parameters.
class SocialMetaTagParameters {
  SocialMetaTagParameters({this.description, this.imageUrl, this.title});

  /// The description to use when the Dynamic Link is shared in a social post.
  final String? description;

  /// The URL to an image related to this link.
  final Uri? imageUrl;

  /// The title to use when the Dynamic Link is shared in a social post.
  final String? title;

  Map<String, dynamic> get data => <String, dynamic>{
    'description': description,
    'imageUrl': imageUrl?.toString(),
    'title': title,
  };
}
