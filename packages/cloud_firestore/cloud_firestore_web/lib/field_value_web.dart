part of cloud_firestore_web;

/// Implementation of [FieldValuePlatform] that is compatible with
/// firestore web plugin
class FieldValueWeb extends FieldValuePlatform implements web.FieldValue {
  web.FieldValue _delegate;

  FieldValueWeb._(this._delegate, this.type, this.value) : super(type, value);

  @override
  final FieldValueType type;

  @override
  final dynamic value;

  @override
  FieldValueInterface get instance => this;
}
