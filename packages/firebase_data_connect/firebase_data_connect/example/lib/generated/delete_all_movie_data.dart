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
  final int directedByDeleteMany;
  final int movieDeleteMany;
  final int personDeleteMany;
  DeleteAllMovieDataData.fromJson(dynamic json)
      : directedByDeleteMany = nativeFromJson<int>(
          json['directedBy_deleteMany'],
        ),
        movieDeleteMany = nativeFromJson<int>(
          json['movie_deleteMany'],
        ),
        personDeleteMany = nativeFromJson<int>(
          json['person_deleteMany'],
        );
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteAllMovieDataData otherTyped = other as DeleteAllMovieDataData;
    return directedByDeleteMany == otherTyped.directedByDeleteMany &&
        movieDeleteMany == otherTyped.movieDeleteMany &&
        personDeleteMany == otherTyped.personDeleteMany;
  }

  @override
  int get hashCode => Object.hashAll([
        directedByDeleteMany.hashCode,
        movieDeleteMany.hashCode,
        personDeleteMany.hashCode,
      ]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['directedBy_deleteMany'] = nativeToJson<int>(directedByDeleteMany);
    json['movie_deleteMany'] = nativeToJson<int>(movieDeleteMany);
    json['person_deleteMany'] = nativeToJson<int>(personDeleteMany);
    return json;
  }

  const DeleteAllMovieDataData({
    required this.directedByDeleteMany,
    required this.movieDeleteMany,
    required this.personDeleteMany,
  });
}
