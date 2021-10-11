import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';
import 'package:json_annotation/json_annotation.dart';

part 'movie.g.dart';

@JsonSerializable()
class Movie {
  Movie({
    this.genre,
    required this.likes,
    required this.poster,
    required this.rated,
    required this.runtime,
    required this.title,
    required this.year,
  });

  factory Movie.fromJson(Map<String, Object?> json) {
    return _$MovieFromJson(json);
  }

  final String poster;
  final int likes;
  final String title;
  final int year;
  final String runtime;
  final String rated;
  final List<String>? genre;

  Map<String, Object?> toJson() => _$MovieToJson(this);
}

@Collection<Movie>('firestore-example-app')
@Collection<Comment>('firestore-example-app/*/comments', name: 'comments')
final moviesRef = MovieCollectionReference();

@JsonSerializable()
class Comment {
  Comment({
    required this.authorName,
    required this.message,
  });

  factory Comment.fromJson(Map<String, Object?> json) {
    return _$CommentFromJson(json);
  }

  final String authorName;
  final String message;

  Map<String, Object?> toJson() => _$CommentToJson(this);
}
