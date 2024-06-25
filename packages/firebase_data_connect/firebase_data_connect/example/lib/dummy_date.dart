import 'package:example/timestamp.dart';
import 'package:json/json.dart';

enum ValueState { Unset, Set }

abstract class JsonSerializer {
  String toJson();
}

abstract class Parser<T> {
  T parse();
}

class Optional<T> {
  ValueState state = ValueState.Unset;
  late T? _value;
  set value(T? v) {
    state = ValueState.Set;
    _value = v;
  }

  T? get value {
    return _value;
  }
}

class DummydateWithCustom {
  Optional<Timestamp> timestamp = Optional();
  Optional<String> str = Optional();
  bool h = false;
  DummydateWithCustom.fromJson(Map<String, Object?> json) {
    timestamp.value = Timestamp.fromJson(json['timestamp'] as String);
    str.value = json['a'].toString();
  }
  Map<String, Object?> toJson() {
    const map = <String, Object?>{};
    if (timestamp.state == ValueState.Set) {
      map['timestamp'] = timestamp.value!.toJson();
    }
    if (str.state == ValueState.Set) {
      map['str'] = str.value!.toString();
    }
    map['h'] = h.toString();
    return map;
  }
}
