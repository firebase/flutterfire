// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'movie.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Movie _$MovieFromJson(Map<String, dynamic> json) => Movie(
      genre:
          (json['genre'] as List<dynamic>?)?.map((e) => e as String).toList(),
      likes: json['likes'] as int,
      poster: json['poster'] as String,
      rated: json['rated'] as String,
      runtime: json['runtime'] as String,
      title: json['title'] as String,
      year: json['year'] as int,
      id: json['id'] as String,
    );

const _$MovieFieldMap = <String, String>{
  'id': 'id',
  'poster': 'poster',
  'likes': 'likes',
  'title': 'title',
  'year': 'year',
  'runtime': 'runtime',
  'rated': 'rated',
  'genre': 'genre',
};

Map<String, dynamic> _$MovieToJson(Movie instance) => <String, dynamic>{
      'id': instance.id,
      'poster': instance.poster,
      'likes': instance.likes,
      'title': instance.title,
      'year': instance.year,
      'runtime': instance.runtime,
      'rated': instance.rated,
      'genre': instance.genre,
    };

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      authorName: json['authorName'] as String,
      message: json['message'] as String,
    );

const _$CommentFieldMap = <String, String>{
  'authorName': 'authorName',
  'message': 'message',
};

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'authorName': instance.authorName,
      'message': instance.message,
    };
