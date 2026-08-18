part of 'movies.dart';

class DeleteAllMovieDataVariablesBuilder {
  final FirebaseDataConnect _dataConnect;
  DeleteAllMovieDataVariablesBuilder(
    this._dataConnect,
  );
  Deserializer<DeleteAllMovieDataData> dataDeserializer =
      (dynamic json) => DeleteAllMovieDataData.fromJson(jsonDecode(json));

  Future<OperationResult<DeleteAllMovieDataData, void>> execute() {
    return ref().execute();
  }

  MutationRef<DeleteAllMovieDataData, void> ref() {
    return _dataConnect.mutation(
        "deleteAllMovieData", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class DeleteAllMovieDataData {
  final int directedBy_deleteMany;
  final int movie_deleteMany;
  final int person_deleteMany;
  DeleteAllMovieDataData.fromJson(dynamic json)
      : directedBy_deleteMany =
            nativeFromJson<int>(json['directedBy_deleteMany']),
        movie_deleteMany = nativeFromJson<int>(json['movie_deleteMany']),
        person_deleteMany = nativeFromJson<int>(json['person_deleteMany']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteAllMovieDataData otherTyped = other as DeleteAllMovieDataData;
    return directedBy_deleteMany == otherTyped.directedBy_deleteMany &&
        movie_deleteMany == otherTyped.movie_deleteMany &&
        person_deleteMany == otherTyped.person_deleteMany;
  }

  @override
  int get hashCode => Object.hashAll([
        directedBy_deleteMany.hashCode,
        movie_deleteMany.hashCode,
        person_deleteMany.hashCode
      ]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['directedBy_deleteMany'] = nativeToJson<int>(directedBy_deleteMany);
    json['movie_deleteMany'] = nativeToJson<int>(movie_deleteMany);
    json['person_deleteMany'] = nativeToJson<int>(person_deleteMany);
    return json;
  }

  DeleteAllMovieDataData({
    required this.directedBy_deleteMany,
    required this.movie_deleteMany,
    required this.person_deleteMany,
  });
}
