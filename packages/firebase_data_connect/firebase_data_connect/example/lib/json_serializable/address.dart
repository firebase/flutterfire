import 'package:example/timestamp.dart';
import 'package:json_annotation/json_annotation.dart';
part 'address.g.dart';

@JsonSerializable(explicitToJson: true)
class Address {
  String street;
  String city;

  List<Timestamp> timestamp;

  Address(this.street, this.city, this.timestamp);

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
  Map<String, dynamic> toJson() => _$AddressToJson(this);
}
