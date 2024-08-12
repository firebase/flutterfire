part of firebase_data_connect_common;

enum DataConnectErrorCode { unavailable, unauthorized, other }

class FirebaseDataConnectError implements Exception {
  FirebaseDataConnectError(this.code, this.message);
  String message;
  DataConnectErrorCode code;
  String toString() => "FirebaseDataConnectError: $code:$message";
}
