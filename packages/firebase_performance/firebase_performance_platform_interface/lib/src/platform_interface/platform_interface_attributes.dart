abstract class PerformanceAttributesPlatform {
  final Map<String, String> _attributes = <String, String>{};
  
  Future<void> putAttribute(String name, String value) {
    throw UnimplementedError('putAttribute() is not implemented');
  }

  Future<void> removeAttribute(String name) {
    throw UnimplementedError('removeAttribute() is not implemented');
  }

  String? getAttribute(String name) => _attributes[name];

  Future<Map<String, String>> getAttributes() {
    throw UnimplementedError('getAttributes() is not implemented');
  }
}
