class EventParameters {
  Map<String, Object> _parameters = {};

  // Can only pass either a String or a num value
  EventParameters addParameter(String key, {String? string, num? number}) {
    assert(
      (string != null && number != null) || (string == null || number == null),
      'string or number must be set as the value of the parameter',
    );
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
