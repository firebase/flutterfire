import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:firebase/firestore.dart' as web;

/// Implementation of [FieldValuePlatform] that is compatible with
/// firestore web plugin
class FieldValueWeb extends FieldValuePlatform implements web.FieldValue {
  /// The js-interop delegate for this [FieldValuePlatform]
  web.FieldValue delegate;

  /// Constructor.
  FieldValueWeb(this.delegate, this.type, this.value) : super(type, value);

  @override
  final FieldValueType type;

  @override
  final dynamic value;

  @override
  FieldValuePlatform get instance => this;
}
