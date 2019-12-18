part of cloud_firestore_web;

class FieldValueWeb implements FieldValueInterface, web.FieldValue {
  static Map<String, dynamic> _serverDelegates(Map<String, dynamic> data) {
    Map<String, dynamic> output = Map.from(data);
    output.updateAll((key, value) {
      if (value is FieldValueInterface && value.instance is FieldValueWeb) {
        return (value.instance as FieldValueWeb)._delegate;
      } else {
        return value;
      }
    });
    return output;
  }

  web.FieldValue _delegate;

  FieldValueWeb._(this._delegate, this.type, this.value);

  @override
  final FieldValueType type;

  @override
  final dynamic value;

  @override
  FieldValueInterface get instance => this;
}
