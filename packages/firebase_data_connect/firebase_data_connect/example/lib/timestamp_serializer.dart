import 'package:example/timestamp.dart';

class TimestampSerializer<bool> {
  Timestamp? timestamp;
  Map<String, Object?> toJson() {
    var map = Map<String, Object?>();
    if (timestamp == null) {
      return map;
    }
    map['timestamp'] = timestamp!.toJson();
    return map;
  }

  TimestampSerializer.fromJson(Map<String, Object?> map) {
    var timestampStr = map['timestamp'];
    if (timestampStr != null) {
      timestamp = Timestamp.fromJson(timestampStr);
    }
  }
}
