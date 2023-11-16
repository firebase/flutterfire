// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

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
  @JsonKey(includeFromJson: false, includeToJson: false)
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
      @JsonKey(includeFromJson: false, includeToJson: false) int? ignored});
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
abstract class _$$PersonImplCopyWith<$Res> implements $PersonCopyWith<$Res> {
  factory _$$PersonImplCopyWith(
          _$PersonImpl value, $Res Function(_$PersonImpl) then) =
      __$$PersonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String firstName,
      @JsonKey(name: 'LAST_NAME') String lastName,
      @JsonKey(includeFromJson: false, includeToJson: false) int? ignored});
}

/// @nodoc
class __$$PersonImplCopyWithImpl<$Res>
    extends _$PersonCopyWithImpl<$Res, _$PersonImpl>
    implements _$$PersonImplCopyWith<$Res> {
  __$$PersonImplCopyWithImpl(
      _$PersonImpl _value, $Res Function(_$PersonImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firstName = null,
    Object? lastName = null,
    Object? ignored = freezed,
  }) {
    return _then(_$PersonImpl(
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
class _$PersonImpl implements _Person {
  _$PersonImpl(
      {required this.firstName,
      @JsonKey(name: 'LAST_NAME') required this.lastName,
      @JsonKey(includeFromJson: false, includeToJson: false) this.ignored});

  factory _$PersonImpl.fromJson(Map<String, dynamic> json) =>
      _$$PersonImplFromJson(json);

  @override
  final String firstName;
  @override
  @JsonKey(name: 'LAST_NAME')
  final String lastName;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final int? ignored;

  @override
  String toString() {
    return 'Person(firstName: $firstName, lastName: $lastName, ignored: $ignored)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PersonImpl &&
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
  _$$PersonImplCopyWith<_$PersonImpl> get copyWith =>
      __$$PersonImplCopyWithImpl<_$PersonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PersonImplToJson(
      this,
    );
  }
}

abstract class _Person implements Person {
  factory _Person(
      {required final String firstName,
      @JsonKey(name: 'LAST_NAME') required final String lastName,
      @JsonKey(includeFromJson: false, includeToJson: false)
      final int? ignored}) = _$PersonImpl;

  factory _Person.fromJson(Map<String, dynamic> json) = _$PersonImpl.fromJson;

  @override
  String get firstName;
  @override
  @JsonKey(name: 'LAST_NAME')
  String get lastName;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  int? get ignored;
  @override
  @JsonKey(ignore: true)
  _$$PersonImplCopyWith<_$PersonImpl> get copyWith =>
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
abstract class _$$PublicRedirected2ImplCopyWith<$Res>
    implements $PublicRedirectedCopyWith<$Res> {
  factory _$$PublicRedirected2ImplCopyWith(_$PublicRedirected2Impl value,
          $Res Function(_$PublicRedirected2Impl) then) =
      __$$PublicRedirected2ImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String value});
}

/// @nodoc
class __$$PublicRedirected2ImplCopyWithImpl<$Res>
    extends _$PublicRedirectedCopyWithImpl<$Res, _$PublicRedirected2Impl>
    implements _$$PublicRedirected2ImplCopyWith<$Res> {
  __$$PublicRedirected2ImplCopyWithImpl(_$PublicRedirected2Impl _value,
      $Res Function(_$PublicRedirected2Impl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
  }) {
    return _then(_$PublicRedirected2Impl(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PublicRedirected2Impl implements PublicRedirected2 {
  _$PublicRedirected2Impl({required this.value});

  factory _$PublicRedirected2Impl.fromJson(Map<String, dynamic> json) =>
      _$$PublicRedirected2ImplFromJson(json);

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
            other is _$PublicRedirected2Impl &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, value);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PublicRedirected2ImplCopyWith<_$PublicRedirected2Impl> get copyWith =>
      __$$PublicRedirected2ImplCopyWithImpl<_$PublicRedirected2Impl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PublicRedirected2ImplToJson(
      this,
    );
  }
}

abstract class PublicRedirected2 implements PublicRedirected {
  factory PublicRedirected2({required final String value}) =
      _$PublicRedirected2Impl;

  factory PublicRedirected2.fromJson(Map<String, dynamic> json) =
      _$PublicRedirected2Impl.fromJson;

  @override
  String get value;
  @override
  @JsonKey(ignore: true)
  _$$PublicRedirected2ImplCopyWith<_$PublicRedirected2Impl> get copyWith =>
      throw _privateConstructorUsedError;
}
