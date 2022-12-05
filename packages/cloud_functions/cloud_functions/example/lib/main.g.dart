// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Fruits _$FruitsFromJson(Map<String, dynamic> json) => Fruits(
      apple: Fruit.fromJson(json['apple'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FruitsToJson(Fruits instance) => <String, dynamic>{
      'apple': instance.apple.toJson(),
    };

Fruit _$FruitFromJson(Map<String, dynamic> json) => Fruit(
      color: json['color'] as String,
      size: json['size'] as String,
    );

Map<String, dynamic> _$FruitToJson(Fruit instance) => <String, dynamic>{
      'color': instance.color,
      'size': instance.size,
    };
