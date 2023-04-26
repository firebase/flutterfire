// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'freezed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Person _$PersonFromJson(Map<String, dynamic> json) {
  return _Person.fromJson(json);
}

/// @nodoc
mixin _$Person {
  String get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'LAST_NAME')
  String get lastName => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  int? get ignored => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PersonCopyWith<Person> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PersonCopyWith<$Res> {
  factory $PersonCopyWith(Person value, $Res Function(Person) then) =
      _$PersonCopyWithImpl<$Res, Person>;
  @useResult
  $Res call(
      {String firstName,
      @JsonKey(name: 'LAST_NAME') String lastName,
      @JsonKey(ignore: true) int? ignored});
}

/// @nodoc
class _$PersonCopyWithImpl<$Res, $Val extends Person>
    implements $PersonCopyWith<$Res> {
  _$PersonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firstName = null,
    Object? lastName = null,
    Object? ignored = freezed,
  }) {
    return _then(_value.copyWith(
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      ignored: freezed == ignored
          ? _value.ignored
          : ignored // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_PersonCopyWith<$Res> implements $PersonCopyWith<$Res> {
  factory _$$_PersonCopyWith(_$_Person value, $Res Function(_$_Person) then) =
      __$$_PersonCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String firstName,
      @JsonKey(name: 'LAST_NAME') String lastName,
      @JsonKey(ignore: true) int? ignored});
}

/// @nodoc
class __$$_PersonCopyWithImpl<$Res>
    extends _$PersonCopyWithImpl<$Res, _$_Person>
    implements _$$_PersonCopyWith<$Res> {
  __$$_PersonCopyWithImpl(_$_Person _value, $Res Function(_$_Person) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firstName = null,
    Object? lastName = null,
    Object? ignored = freezed,
  }) {
    return _then(_$_Person(
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      ignored: freezed == ignored
          ? _value.ignored
          : ignored // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$_Person implements _Person {
  _$_Person(
      {required this.firstName,
      @JsonKey(name: 'LAST_NAME') required this.lastName,
      @JsonKey(ignore: true) this.ignored});

  factory _$_Person.fromJson(Map<String, dynamic> json) =>
      _$$_PersonFromJson(json);

  @override
  final String firstName;
  @override
  @JsonKey(name: 'LAST_NAME')
  final String lastName;
  @override
  @JsonKey(ignore: true)
  final int? ignored;

  @override
  String toString() {
    return 'Person(firstName: $firstName, lastName: $lastName, ignored: $ignored)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Person &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.ignored, ignored) || other.ignored == ignored));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, firstName, lastName, ignored);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_PersonCopyWith<_$_Person> get copyWith =>
      __$$_PersonCopyWithImpl<_$_Person>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_PersonToJson(
      this,
    );
  }
}

abstract class _Person implements Person {
  factory _Person(
      {required final String firstName,
      @JsonKey(name: 'LAST_NAME') required final String lastName,
      @JsonKey(ignore: true) final int? ignored}) = _$_Person;

  factory _Person.fromJson(Map<String, dynamic> json) = _$_Person.fromJson;

  @override
  String get firstName;
  @override
  @JsonKey(name: 'LAST_NAME')
  String get lastName;
  @override
  @JsonKey(ignore: true)
  int? get ignored;
  @override
  @JsonKey(ignore: true)
  _$$_PersonCopyWith<_$_Person> get copyWith =>
      throw _privateConstructorUsedError;
}

PublicRedirected _$PublicRedirectedFromJson(Map<String, dynamic> json) {
  return PublicRedirected2.fromJson(json);
}

/// @nodoc
mixin _$PublicRedirected {
  String get value => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PublicRedirectedCopyWith<PublicRedirected> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PublicRedirectedCopyWith<$Res> {
  factory $PublicRedirectedCopyWith(
          PublicRedirected value, $Res Function(PublicRedirected) then) =
      _$PublicRedirectedCopyWithImpl<$Res, PublicRedirected>;
  @useResult
  $Res call({String value});
}

/// @nodoc
class _$PublicRedirectedCopyWithImpl<$Res, $Val extends PublicRedirected>
    implements $PublicRedirectedCopyWith<$Res> {
  _$PublicRedirectedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
  }) {
    return _then(_value.copyWith(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PublicRedirected2CopyWith<$Res>
    implements $PublicRedirectedCopyWith<$Res> {
  factory _$$PublicRedirected2CopyWith(
          _$PublicRedirected2 value, $Res Function(_$PublicRedirected2) then) =
      __$$PublicRedirected2CopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String value});
}

/// @nodoc
class __$$PublicRedirected2CopyWithImpl<$Res>
    extends _$PublicRedirectedCopyWithImpl<$Res, _$PublicRedirected2>
    implements _$$PublicRedirected2CopyWith<$Res> {
  __$$PublicRedirected2CopyWithImpl(
      _$PublicRedirected2 _value, $Res Function(_$PublicRedirected2) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
  }) {
    return _then(_$PublicRedirected2(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PublicRedirected2 implements PublicRedirected2 {
  _$PublicRedirected2({required this.value});

  factory _$PublicRedirected2.fromJson(Map<String, dynamic> json) =>
      _$$PublicRedirected2FromJson(json);

  @override
  final String value;

  @override
  String toString() {
    return 'PublicRedirected(value: $value)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PublicRedirected2 &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, value);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PublicRedirected2CopyWith<_$PublicRedirected2> get copyWith =>
      __$$PublicRedirected2CopyWithImpl<_$PublicRedirected2>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PublicRedirected2ToJson(
      this,
    );
  }
}

abstract class PublicRedirected2 implements PublicRedirected {
  factory PublicRedirected2({required final String value}) =
      _$PublicRedirected2;

  factory PublicRedirected2.fromJson(Map<String, dynamic> json) =
      _$PublicRedirected2.fromJson;

  @override
  String get value;
  @override
  @JsonKey(ignore: true)
  _$$PublicRedirected2CopyWith<_$PublicRedirected2> get copyWith =>
      throw _privateConstructorUsedError;
}
