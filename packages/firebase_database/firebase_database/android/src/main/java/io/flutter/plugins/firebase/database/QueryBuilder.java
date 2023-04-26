/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.database;

import androidx.annotation.NonNull;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.Query;
import java.util.List;
import java.util.Map;
import java.util.Objects;

public class QueryBuilder {
  private final List<Map<String, Object>> modifiers;
  private Query query;

  public QueryBuilder(
      @NonNull DatabaseReference ref, @NonNull List<Map<String, Object>> modifiers) {
    this.query = ref;
    this.modifiers = modifiers;
  }

  public Query build() {
    if (modifiers.isEmpty()) return query;

    for (Map<String, Object> modifier : modifiers) {
      String type = (String) Objects.requireNonNull(modifier.get("type"));

      switch (type) {
        case Constants.LIMIT:
          limit(modifier);
          break;
        case Constants.CURSOR:
          cursor(modifier);
          break;
        case Constants.ORDER_BY:
          orderBy(modifier);
          break;
      }
    }

    return query;
  }

  private void limit(Map<String, Object> modifier) {
    String name = (String) Objects.requireNonNull(modifier.get("name"));
    int value = (int) Objects.requireNonNull(modifier.get("limit"));

    if (Constants.LIMIT_TO_FIRST.equals(name)) {
      query = query.limitToFirst(value);
    } else if (Constants.LIMIT_TO_LAST.equals(name)) {
      query = query.limitToLast(value);
    }
  }

  private void orderBy(Map<String, Object> modifier) {
    String name = (String) Objects.requireNonNull(modifier.get("name"));

    switch (name) {
      case "orderByKey":
        query = query.orderByKey();
        break;
      case "orderByValue":
        query = query.orderByValue();
        break;
      case "orderByPriority":
        query = query.orderByPriority();
        break;
      case "orderByChild":
        {
          String path = (String) Objects.requireNonNull(modifier.get("path"));
          query = query.orderByChild(path);
        }
    }
  }

  private void cursor(Map<String, Object> modifier) {
    String name = (String) Objects.requireNonNull(modifier.get("name"));

    switch (name) {
      case Constants.START_AT:
        startAt(modifier);
        break;
      case Constants.START_AFTER:
        startAfter(modifier);
        break;
      case Constants.END_AT:
        endAt(modifier);
        break;
      case Constants.END_BEFORE:
        endBefore(modifier);
        break;
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
}
