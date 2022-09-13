const String _exceptionMessage =
    "'string' OR 'number' must be set as the value of the parameter";

class EventParameters {
  EventParameters();
  // Constructs an [EventParameters] from a raw Map.
  factory EventParameters.fromMap(Map<String, Object> map) {
    Map<String, Object> parameters = {};
    map.forEach((key, value) {
      assert(
        value is String || value is num,
        _exceptionMessage,
      );
      parameters[key] = value;
    });
    return EventParameters._(parameters);
  }

  EventParameters._(this._parameters);

  Map<String, Object> _parameters = {};

  // Can only pass either a String or a num value
  EventParameters addParameter(String key, {String? string, num? number}) {
    assert(
      !(string == null && number == null),
      _exceptionMessage,
    );
    assert(!(string != null && number != null), _exceptionMessage);
    _parameters[key] = (string ?? number)!;
    return this;
  }

  /// Returns a map for this EventParameters instance.
  Map<String, Object> asMap() {
    return Map<String, Object>.from(_parameters);
  }

  @override
  String toString() {
    return '$EventParameters($asMap)';
  }
}
