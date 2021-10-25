package io.flutter.plugins.firebase.database;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.Query;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import java.util.TreeMap;

public class QueryBuilder {
  private Query query;

  public QueryBuilder(@NonNull DatabaseReference ref) {
    query = ref;
  }

  static String buildQueryParams(@Nullable Map<String, Object> parameters) {
    if (parameters == null) return "";

    final TreeMap<String, Object> sortedParams = new TreeMap<>(parameters);

    final StringBuilder qsb = new StringBuilder();
    boolean empty = true;

    for (String key : sortedParams.keySet()) {
      if (empty) {
        empty = false;
      } else {
        qsb.append('&');
      }

      final Object value = sortedParams.get(key);

      qsb.append(key);
      qsb.append('=');
      qsb.append(value);
    }

    return qsb.toString();
  }

  public Query build(Map<String, Object> parameters) {
    if (parameters == null) return query;

    Map<String, Object> params = new HashMap<>(parameters);

    if (parameters.containsKey(Constants.ORDER_BY)) {
      final Object value = parameters.get(Constants.ORDER_BY);
      orderBy(value, parameters);

      params.remove(Constants.ORDER_BY);
    }

    for (String key : params.keySet()) {
      final Object value = params.get(key);

      if (Constants.ORDER_BY.equals(key)) {
        orderBy(value, params);
      } else if (Constants.START_AT.equals(key)) {
        startAt(value, params);
      } else if (Constants.START_AFTER.equals(key)) {
        startAfter(value, params);
      } else if (Constants.END_AT.equals(key)) {
        endAt(value, params);
      } else if (Constants.END_BEFORE.equals(key)) {
        endBefore(value, params);
      } else if (Constants.EQUAL_TO.equals(key)) {
        equalTo(value, params);
      } else if (Constants.LIMIT_TO_FIRST.equals(key) && value != null) {
        limitToFirst((int) value);
      } else if (Constants.LIMIT_TO_LAST.equals(key) && value != null) {
        limitToLast((int) value);
      }
    }

    return query;
  }

  private void orderBy(Object value, Map<String, Object> parameters) {
    if (Constants.KEY.equals(value)) {
      query = query.orderByKey();
    } else if (Constants.VALUE.equals(value)) {
      query = query.orderByValue();
    } else if (Constants.PRIORITY.equals(value)) {
      query = query.orderByPriority();
    } else if (Constants.CHILD.equals(value)) {
      final String childKey =
          (String) Objects.requireNonNull(parameters.get(Constants.ORDER_BY_CHILD_KEY));
      query = query.orderByChild(childKey);
    }
  }

  private void startAt(Object value, Map<String, Object> parameters) {
    final String key = (String) parameters.get(Constants.START_AT_KEY);

    if (value instanceof Boolean) {
      query = query.startAt((Boolean) value, key);
    } else if (value instanceof Number) {
      query = query.startAt(((Number) value).doubleValue(), key);
    } else {
      query = query.startAt((String) value, key);
    }
  }

  private void startAfter(Object value, Map<String, Object> parameters) {
    final String key = (String) parameters.get(Constants.START_AFTER_KEY);

    if (value instanceof Boolean) {
      if (key == null) {
        query = query.startAfter((Boolean) value);
      } else {
        query = query.startAfter((Boolean) value, key);
      }
    } else if (value instanceof Number) {
      if (key == null) {
        query = query.startAfter(((Number) value).doubleValue());
      } else {
        query = query.startAfter(((Number) value).doubleValue(), key);
      }
    } else if (key == null) {
      query = query.startAfter((String) value);
    } else {
      query = query.startAfter((String) value, key);
    }
  }

  private void endAt(Object value, Map<String, Object> parameters) {
    final String key = (String) parameters.get(Constants.END_AT_KEY);

    if (value instanceof Boolean) {
      query = query.endAt((Boolean) value, key);
    } else if (value instanceof Number) {
      query = query.endAt(((Number) value).doubleValue(), key);
    } else {
      query = query.endAt((String) value, key);
    }
  }

  private void endBefore(Object value, Map<String, Object> parameters) {
    final String key = (String) parameters.get(Constants.END_BEFORE_KEY);

    if (value instanceof Boolean) {
      if (key == null) {
        query = query.endBefore((Boolean) value);
      } else {
        query = query.endBefore((Boolean) value, key);
      }
    } else if (value instanceof Number) {
      if (key == null) {
        query = query.endBefore(((Number) value).doubleValue());
      } else {
        query = query.endBefore(((Number) value).doubleValue(), key);
      }
    } else if (key == null) {
      query = query.endBefore((String) value);
    } else {
      query = query.endBefore((String) value, key);
    }
  }

  private void equalTo(Object value, Map<String, Object> parameters) {
    final String key = (String) parameters.get(Constants.EQUAL_TO_KEY);

    if (value instanceof Boolean) {
      query = query.equalTo((Boolean) value, key);
    } else if (value instanceof Number) {
      query = query.equalTo(((Number) value).doubleValue(), key);
    } else {
      query = query.equalTo((String) value, key);
    }
  }

  private void limitToFirst(int value) {
    query = query.limitToFirst(value);
  }

  private void limitToLast(int value) {
    query = query.limitToLast(value);
  }
}
