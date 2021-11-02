import 'short_dynamic_link_path_length.dart';

/// Options class for defining how Dynamic Link URLs are generated.
class DynamicLinkParametersOptions {
  const DynamicLinkParametersOptions({this.shortDynamicLinkPathLength});

  /// Specifies the length of the path component of a short Dynamic Link.
  final ShortDynamicLinkPathLength? shortDynamicLinkPathLength;

  Map<String, dynamic> get data => <String, dynamic>{
        'shortDynamicLinkPathLength': shortDynamicLinkPathLength?.index,
      };
}
