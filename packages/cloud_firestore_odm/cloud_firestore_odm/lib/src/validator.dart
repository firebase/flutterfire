/// A class used to assert that a value respects some rules.
///
/// As opposed to `assert`, this class works in release mode too.
abstract class Validator<T> {
  /// A class used to assert that a value respects some rules.
  ///
  /// As opposed to `assert`, this class works in release mode too.
  const Validator();

  void validate(
    T value,
  );
}

class Min extends Validator<num> {
  const Min(this.minValue);

  final num minValue;

  @override
  void validate(num value) {
    if (value < minValue) {
      throw ArgumentError.value(
        value,
        // TODO name + message
      );
    }
  }
}

class Max extends Validator<num> {
  const Max(this.maxValue);

  final num maxValue;

  @override
  void validate(num value) {
    if (value > maxValue) {
      throw ArgumentError.value(
        value,
        // TODO name + message
      );
    }
  }
}
