// When separated accross multiple files, it is necessary to specify fromJson/toJson
// We voluntarily don't use JsonSerializable here, as it is not supported due to
// the generated FieldMap being private.
class SplitFileModel {
  SplitFileModel();

  // ignore: avoid_unused_constructor_parameters
  factory SplitFileModel.fromJson(Map<String, Object?> json) =>
      SplitFileModel();

  Map<String, Object?> toJson() => {};
}
