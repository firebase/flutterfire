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

  public static final String PARAMETERS = "parameters";
  public static final String ORDER_BY = "orderBy";
  public static final Object CHILD = "child";
  public static final String ORDER_BY_CHILD_KEY = "orderByChildKey";

  public static final String START_AT = "startAt";
  public static final String START_AT_KEY = "startAtKey";

  public static final String END_AT = "endAt";
  public static final String END_AT_KEY = "endAtKey";

  public static final String EQUAL_TO = "equalTo";
  public static final String EQUAL_TO_KEY = "equalToKey";

  public static final String LIMIT_TO_FIRST = "limitToFirst";
  public static final String LIMIT_TO_LAST = "limitToLast";

  public static final String EVENT_TYPE = "eventType";

  public static final String EVENT_TYPE_CHILD_ADDED = "EventType.childAdded";
  public static final String EVENT_TYPE_CHILD_REMOVED = "EventType.childRemoved";
  public static final String EVENT_TYPE_CHILD_CHANGED = "EventType.childChanged";
  public static final String EVENT_TYPE_CHILD_MOVED = "EventType.childMoved";
  public static final String EVENT_TYPE_VALUE = "EventType.value";

  public static final String CHILD_KEYS = "childKeys";
  public static final String PREVIOUS_CHILD_NAME = "previousChildName";

  public static final String METHOD_DO_TRANSACTION = "DoTransaction";
  public static final String TRANSACTION_KEY = "transactionKey";
  public static final String TRANSACTION_TIMEOUT = "transactionTimeout";

  public static final String ILLEGAL_CONFIGURATION_POINT_CODE = "wrong-configuration-point";
  public static final String TRANSACTION_TIMEOUT_CODE = "transaction-timeout";
}
