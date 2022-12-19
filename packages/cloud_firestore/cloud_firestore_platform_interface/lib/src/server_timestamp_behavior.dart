enum ServerTimestampBehavior {
  none,
  estimate,
  previous,
}

extension ServerTimestampBehaviorExtension on ServerTimestampBehavior {
  String get name {
    switch (this) {
      case ServerTimestampBehavior.none:
        return 'none';
      case ServerTimestampBehavior.estimate:
        return 'estimate';
      case ServerTimestampBehavior.previous:
        return 'previous';
    }
  }
}
