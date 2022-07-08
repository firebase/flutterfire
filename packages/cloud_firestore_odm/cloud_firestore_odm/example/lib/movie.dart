import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';
import 'package:json_annotation/json_annotation.dart';

part 'movie.g.dart';

// ignore_for_file: constant_identifier_names
enum LanguageType { English, French, Spanish, Chinese, Korean }

enum GenreType {
  Action,
  Adventure,
  Comedy,
  Crime,
  Drame,
  Fantasy,
  Mystery,
  SciFi,
  Thriler,
}

enum CertificationType {
  None,
  G,
  PG,
  PG13,
  R,
  TVPG,
  TVMA,
}

enum CastType {
  Background,
  Cameo,
  Recurring,
  Side,
  Star,
  CoStar,
  GuestStar,
}

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
    required this.language,
    required this.certification,
    required this.cast,
    required this.majorCast,
  }) {
    _$assertMovie(this);
  }

  final String poster;
  @Min(0)
  final int likes;
  final String title;
  @Min(0)
  final int year;
  final String runtime;
  final String rated;
  final List<String>? genre;
  final List<LanguageType>? language;
  final CertificationType certification;
  final List<Map<CastType, String>> cast;
  final Map<CastType, String> majorCast;
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

  final String authorName;
  final String message;
}
