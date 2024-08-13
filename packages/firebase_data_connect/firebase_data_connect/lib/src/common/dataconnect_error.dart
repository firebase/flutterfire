part of firebase_data_connect_common;

/// Types of DataConnect errors that can occur.
enum DataConnectErrorCode { unavailable, unauthorized, other }

/// Error thrown when DataConnect encounters an error.
class FirebaseDataConnectError implements Exception {
  FirebaseDataConnectError(this.code, this.message);
  String message;
  DataConnectErrorCode code;
  @override
  String toString() => 'FirebaseDataConnectError: $code:$message';
}

typedef Serializer<Variables> = String Function(Variables vars);
typedef Deserializer<Data> = Data Function(String data);

enum OperationType { query, mutation }
