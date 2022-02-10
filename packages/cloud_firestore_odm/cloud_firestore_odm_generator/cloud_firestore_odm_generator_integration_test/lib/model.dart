import 'package:freezed_annotation/freezed_annotation.dart';

part 'model.g.dart';

@JsonSerializable()
class SplitFileModel {
  SplitFileModel();

  // When separated accross multiple files, it is necessary to specify fromJson/toJson
  factory SplitFileModel.fromJson(Map<String, Object?> json) =>
      _$SplitFileModelFromJson(json);

  Map<String, Object?> toJson() => _$SplitFileModelToJson(this);
}
