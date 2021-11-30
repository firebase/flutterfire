package io.flutter.plugins.firebase.database;

import androidx.annotation.NonNull;

import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.Query;

import java.util.List;
import java.util.Map;
import java.util.Objects;

public class QueryBuilder {
  private Query query;
  final private List<Map<String, Object>> modifiers;

  public QueryBuilder(@NonNull DatabaseReference ref, @NonNull List<Map<String, Object>> modifiers) {
    this.query = ref;
    this.modifiers = modifiers;
  }

  public Query build() {
    if (modifiers.isEmpty()) return query;

    for (Map<String, Object> modifier : modifiers) {
      String name = (String) modifier.get("name");
      String type = (String) modifier.get("type");

      if (Constants.LIMIT_TO_FIRST.equals(name)) {
        limitToFirst((int) modifier.get("value"));
      } else if (Constants.LIMIT_TO_LAST.equals(name)) {
        limitToLast((int) modifier.get("value"));
      } else if (Constants.ORDER_BY.equals(type)) {
        orderBy(modifier);
      } else if (Constants.START_AT.equals(name)) {
        startAt(modifier);
      } else if (Constants.START_AFTER.equals(name)) {
        startAfter(modifier);
      } else if (Constants.END_AT.equals(name)) {
        endAt(modifier);
      } else if (Constants.END_BEFORE.equals(name)) {
        endBefore(modifier);
      }
    }

    return query;
  }

  private void orderBy(Map<String, Object> modifier) {
    String name = (String) modifier.get("name");

    if ("orderByKey".equals(name)) {
      query = query.orderByKey();
    } else if ("orderByValue".equals(name)) {
      query = query.orderByValue();
    } else if ("orderByPriority".equals(name)) {
      query = query.orderByPriority();
    } else if ("orderByChild".equals(name)) {
      String path = (String) Objects.requireNonNull(modifier.get("name"));
      query = query.orderByChild(path);
    }
  }

  private void startAt(Map<String, Object> modifier) {
    final Object value = modifier.get("value");
    final String key = (String) modifier.get("key");

    if (value instanceof Boolean) {
      if (key == null) {
        query = query.startAt((Boolean) value);
      } else {
        query = query.startAt((Boolean) value, key);
      }
    } else if (value instanceof Number) {
      if (key == null) {
        query = query.startAt(((Number) value).doubleValue());
      } else {
        query = query.startAt(((Number) value).doubleValue(), key);
      }
    } else {
      if (key == null) {
        query = query.startAt((String) value);
      } else {
        query = query.startAt((String) value, key);
      }
    }
  }

  private void startAfter(Map<String, Object> modifier) {
    final Object value = modifier.get("value");
    final String key = (String) modifier.get("key");

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
    } else {
      if (key == null) {
        query = query.startAfter((String) value);
      } else {
        query = query.startAfter((String) value, key);
      }
    }
  }

  private void endAt(Map<String, Object> modifier) {
    final Object value = modifier.get("value");
    final String key = (String) modifier.get("key");

    if (value instanceof Boolean) {
      if (key == null) {
        query = query.endAt((Boolean) value);
      } else {
        query = query.endAt((Boolean) value, key);
      }
    } else if (value instanceof Number) {
      if (key == null) {
        query = query.endAt(((Number) value).doubleValue());
      } else {
        query = query.endAt(((Number) value).doubleValue(), key);
      }
    } else {
      if (key == null) {
        query = query.endAt((String) value);
      } else {
        query = query.endAt((String) value, key);
      }
    }
  }

  private void endBefore(Map<String, Object> modifier) {
    final Object value = modifier.get("value");
    final String key = (String) modifier.get("key");

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
    } else {
      if (key == null) {
        query = query.endBefore((String) value);
      } else {
        query = query.endBefore((String) value, key);
      }
    }
  }

  private void limitToFirst(int value) {
    query = query.limitToFirst(value);
  }

  private void limitToLast(int value) {
    query = query.limitToLast(value);
  }
}
