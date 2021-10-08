package io.flutter.plugins.firebase.database;

import com.google.firebase.database.Logger;

public class Constants {
  public static final String APP_NAME = "appName";
  public static final String DATABASE_URL = "databaseURL";

  public static final String ENABLED = "enabled";

  public static final String CACHE_SIZE = "cacheSize";
  public static final Long DEFAULT_CACHE_SIZE = 10485760L;

  public static final Logger.Level DISABLED_LOG_LEVEL = Logger.Level.INFO;
  public static final Logger.Level ENABLED_LOG_LEVEL = Logger.Level.DEBUG;

  public static final String PATH = "path";
  public static final String KEY = "key";
  public static final String VALUE = "value";
  public static final String PRIORITY = "priority";
  public static final String SNAPSHOT = "snapshot";

  public static final String COMMITTED = "committed";
}
