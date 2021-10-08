package io.flutter.plugins.firebase.database;

import java.util.HashMap;
import java.util.Map;

public class FirebaseDatabaseException extends Exception {
  private final String code;
  private final String message;
  private final Map<String, Object> additionalData;

  public FirebaseDatabaseException(String code, String message, Map<String, Object> additionalData) {
    super(message, null);

    this.code = code;
    this.message = message;
    this.additionalData = additionalData;
  }
}
