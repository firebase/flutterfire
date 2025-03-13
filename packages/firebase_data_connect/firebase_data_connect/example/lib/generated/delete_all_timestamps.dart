part of movies;

class DeleteAllTimestampsVariablesBuilder {
  FirebaseDataConnect _dataConnect;

  DeleteAllTimestampsVariablesBuilder(
    this._dataConnect,
  );
  Deserializer<DeleteAllTimestampsData> dataDeserializer =
      (dynamic json) => DeleteAllTimestampsData.fromJson(jsonDecode(json));

  Future<OperationResult<DeleteAllTimestampsData, void>> execute() {
    return this.ref().execute();
  }

  MutationRef<DeleteAllTimestampsData, void> ref() {
    return _dataConnect.mutation(
        "deleteAllTimestamps", dataDeserializer, emptySerializer, null);
  }
}

class DeleteAllTimestampsData {
  int timestampHolder_deleteMany;

  DeleteAllTimestampsData.fromJson(dynamic json)
      : timestampHolder_deleteMany =
            nativeFromJson<int>(json['timestampHolder_deleteMany']) {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['timestampHolder_deleteMany'] =
        nativeToJson<int>(timestampHolder_deleteMany);

    return json;
  }

  DeleteAllTimestampsData({
    required this.timestampHolder_deleteMany,
  });
}
