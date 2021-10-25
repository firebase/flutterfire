package io.flutter.plugins.firebase.database;

import android.util.Log;
import com.google.firebase.database.DatabaseException;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.Logger.Level;
import java.util.HashMap;
import java.util.Map;

class Config {
  protected Level logLevel;
  protected Boolean isPersistenceEnabled;
  protected Long cacheSize;

  void applyTo(FirebaseDatabase db) {
    try {
      if (logLevel != null) {
        db.setLogLevel(logLevel);
      }

      if (isPersistenceEnabled != null) {
        db.setPersistenceEnabled(isPersistenceEnabled);
      }

      if (cacheSize != null) {
        db.setPersistenceCacheSizeBytes(cacheSize);
      }
    } catch (DatabaseException e) {
      final String message = e.getMessage();
      if (message == null) throw e;

      if (!message.contains("must be made before any other usage of FirebaseDatabase")) {
        throw e;
      }
    }
  }
}

public class DatabaseConfiguration {
  private static final Map<String, Config> configs = new HashMap<>();
  private static boolean shouldWarn = false;
  private static boolean warningSent = false;
  private static boolean isLocked = false;

  public static void applyConfig(FirebaseDatabase db) {
    if (isLocked) return;

    isLocked = true;
    shouldWarn = false;

    final Config config = configs.get(db.getApp().getName());
    if (config == null) return;

    config.applyTo(db);
  }

  private static Config getConfigForDB(FirebaseDatabase db) {
    final String name = db.getApp().getName();

    if (configs.containsKey(name)) {
      return configs.get(name);
    }

    final Config config = new Config();
    configs.put(name, config);

    return config;
  }

  public static void setLogLevel(FirebaseDatabase db, Level level)
      throws FlutterFirebaseDatabaseException {
    checkConfigAppliedBeforeOtherOperations();

    final Config config = getConfigForDB(db);
    config.logLevel = level;
  }

  public static void setPersistenceEnabled(FirebaseDatabase db, boolean isEnabled)
      throws FlutterFirebaseDatabaseException {
    checkConfigAppliedBeforeOtherOperations();

    final Config config = getConfigForDB(db);
    config.isPersistenceEnabled = isEnabled;
  }

  public static void setPersistenceCacheSizeBytes(FirebaseDatabase db, Long size)
      throws FlutterFirebaseDatabaseException {
    checkConfigAppliedBeforeOtherOperations();

    final Config config = getConfigForDB(db);
    config.cacheSize = size;
  }

  public static void reload() {
    isLocked = false;
    shouldWarn = true;
  }

  private static void checkConfigAppliedBeforeOtherOperations()
      throws FlutterFirebaseDatabaseException {
    if (shouldWarn) {
      if (!warningSent) {
        Log.w(
            "firebase_database",
            "Any changes to database configuration do not apply after hot restart. "
                + "Re-launch the app to apply new configuration");

        warningSent = true;
      }
    } else if (isLocked) {
      throw new FlutterFirebaseDatabaseException(
          Constants.ILLEGAL_CONFIGURATION_POINT_CODE,
          "Firebase database should be configured before any other usage",
          new HashMap<>());
    }
  }
}
