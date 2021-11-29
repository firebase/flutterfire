/// A class used to assert that a value respects some rules.
///
/// As opposed to `assert`, this class works in release mode too.
abstract class Validator {
  /// A class used to assert that a value respects some rules.
  ///
  /// As opposed to `assert`, this class works in release mode too.
  const Validator();

  void validate(Object? value, String propertyName);
}

class Min extends Validator {
  const Min(this.minValue);

  final num minValue;

  @override
  void validate(Object? value, String propertyName) {
    if (value is num && value < minValue) {
      throw ArgumentError.value(value, propertyName);
    }
  }
}

class Max extends Validator {
  const Max(this.maxValue);

  final num maxValue;

  @override
  void validate(Object? value, String propertyName) {
    if (value is num && value > maxValue) {
      throw ArgumentError.value(value, propertyName);
    }
  }
}
