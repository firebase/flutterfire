// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.database;

import android.os.Handler;
import android.util.Log;
import android.util.SparseArray;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.database.ChildEventListener;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseException;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.MutableData;
import com.google.firebase.database.Query;
import com.google.firebase.database.Transaction;
import com.google.firebase.database.ValueEventListener;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

class MethodCallHandlerImpl implements MethodChannel.MethodCallHandler {

  private static final String TAG = "MethodCallHandlerImpl";

  private MethodChannel channel;

  private final Handler handler = new Handler();
  private static final String EVENT_TYPE_CHILD_ADDED = "_EventType.childAdded";
  private static final String EVENT_TYPE_CHILD_REMOVED = "_EventType.childRemoved";
  private static final String EVENT_TYPE_CHILD_CHANGED = "_EventType.childChanged";
  private static final String EVENT_TYPE_CHILD_MOVED = "_EventType.childMoved";
  private static final String EVENT_TYPE_VALUE = "_EventType.value";

  // Handles are ints used as indexes into the sparse array of active observers
  private int nextHandle = 0;
  private final SparseArray<EventObserver> observers = new SparseArray<>();

  MethodCallHandlerImpl(MethodChannel channel) {
    this.channel = channel;
  }

  private DatabaseReference getReference(FirebaseDatabase database, Map<String, Object> arguments) {
    String path = (String) arguments.get("path");
    DatabaseReference reference = database.getReference();
    if (path != null) reference = reference.child(path);
    return reference;
  }

  private Query getQuery(FirebaseDatabase database, Map<String, Object> arguments) {
    Query query = getReference(database, arguments);
    @SuppressWarnings("unchecked")
    Map<String, Object> parameters = (Map<String, Object>) arguments.get("parameters");
    if (parameters == null) return query;
    Object orderBy = parameters.get("orderBy");
    if ("child".equals(orderBy)) {
      query = query.orderByChild((String) parameters.get("orderByChildKey"));
    } else if ("key".equals(orderBy)) {
      query = query.orderByKey();
    } else if ("value".equals(orderBy)) {
      query = query.orderByValue();
    } else if ("priority".equals(orderBy)) {
      query = query.orderByPriority();
    }
    if (parameters.containsKey("startAt")) {
      Object startAt = parameters.get("startAt");
      if (parameters.containsKey("startAtKey")) {
        String startAtKey = (String) parameters.get("startAtKey");
        if (startAt instanceof Boolean) {
          query = query.startAt((Boolean) startAt, startAtKey);
        } else if (startAt instanceof Number) {
          query = query.startAt(((Number) startAt).doubleValue(), startAtKey);
        } else {
          query = query.startAt((String) startAt, startAtKey);
        }
      } else {
        if (startAt instanceof Boolean) {
          query = query.startAt((Boolean) startAt);
        } else if (startAt instanceof Number) {
          query = query.startAt(((Number) startAt).doubleValue());
        } else {
          query = query.startAt((String) startAt);
        }
      }
    }
    if (parameters.containsKey("endAt")) {
      Object endAt = parameters.get("endAt");
      if (parameters.containsKey("endAtKey")) {
        String endAtKey = (String) parameters.get("endAtKey");
        if (endAt instanceof Boolean) {
          query = query.endAt((Boolean) endAt, endAtKey);
        } else if (endAt instanceof Number) {
          query = query.endAt(((Number) endAt).doubleValue(), endAtKey);
        } else {
          query = query.endAt((String) endAt, endAtKey);
        }
      } else {
        if (endAt instanceof Boolean) {
          query = query.endAt((Boolean) endAt);
        } else if (endAt instanceof Number) {
          query = query.endAt(((Number) endAt).doubleValue());
        } else {
          query = query.endAt((String) endAt);
        }
      }
    }
    if (parameters.containsKey("equalTo")) {
      Object equalTo = parameters.get("equalTo");
      if (parameters.containsKey("equalToKey")) {
        String equalToKey = (String) parameters.get("equalToKey");
        if (equalTo instanceof Boolean) {
          query = query.equalTo((Boolean) equalTo, equalToKey);
        } else if (equalTo instanceof Number) {
          query = query.equalTo(((Number) equalTo).doubleValue(), equalToKey);
        } else {
          query = query.equalTo((String) equalTo, equalToKey);
        }
      } else {
        if (equalTo instanceof Boolean) {
          query = query.equalTo((Boolean) equalTo);
        } else if (equalTo instanceof Number) {
          query = query.equalTo(((Number) equalTo).doubleValue());
        } else {
          query = query.equalTo((String) equalTo);
        }
      }
    }
    if (parameters.containsKey("limitToFirst")) {
      query = query.limitToFirst((int) parameters.get("limitToFirst"));
    }
    if (parameters.containsKey("limitToLast")) {
      query = query.limitToLast((int) parameters.get("limitToLast"));
    }
    return query;
  }

  private class DefaultCompletionListener implements DatabaseReference.CompletionListener {
    private final MethodChannel.Result result;

    DefaultCompletionListener(MethodChannel.Result result) {
      this.result = result;
    }

    @Override
    public void onComplete(@Nullable DatabaseError error, @NonNull DatabaseReference ref) {
      if (error != null) {
        result.error(String.valueOf(error.getCode()), error.getMessage(), error.getDetails());
      } else {
        result.success(null);
      }
    }
  }

  private class EventObserver implements ChildEventListener, ValueEventListener {
    private String requestedEventType;
    private int handle;

    EventObserver(String requestedEventType, int handle) {
      this.requestedEventType = requestedEventType;
      this.handle = handle;
    }

    private void sendEvent(
        String eventType, @NonNull DataSnapshot snapshot, String previousChildName) {
      if (eventType.equals(requestedEventType)) {
        Map<String, Object> arguments = new HashMap<>();
        Map<String, Object> snapshotMap = new HashMap<>();
        snapshotMap.put("key", snapshot.getKey());
        snapshotMap.put("value", snapshot.getValue());
        arguments.put("handle", handle);
        arguments.put("snapshot", snapshotMap);
        arguments.put("previousSiblingKey", previousChildName);
        channel.invokeMethod("Event", arguments);
      }
    }

    @Override
    public void onCancelled(@NonNull DatabaseError error) {
      Map<String, Object> arguments = new HashMap<>();
      arguments.put("handle", handle);
      arguments.put("error", asMap(error));
      channel.invokeMethod("Error", arguments);
    }

    @Override
    public void onChildAdded(@NonNull DataSnapshot snapshot, String previousChildName) {
      sendEvent(EVENT_TYPE_CHILD_ADDED, snapshot, previousChildName);
    }

    @Override
    public void onChildRemoved(@NonNull DataSnapshot snapshot) {
      sendEvent(EVENT_TYPE_CHILD_REMOVED, snapshot, null);
    }

    @Override
    public void onChildChanged(@NonNull DataSnapshot snapshot, String previousChildName) {
      sendEvent(EVENT_TYPE_CHILD_CHANGED, snapshot, previousChildName);
    }

    @Override
    public void onChildMoved(@NonNull DataSnapshot snapshot, String previousChildName) {
      sendEvent(EVENT_TYPE_CHILD_MOVED, snapshot, previousChildName);
    }

    @Override
    public void onDataChange(@NonNull DataSnapshot snapshot) {
      sendEvent(EVENT_TYPE_VALUE, snapshot, null);
    }
  }

  @Override
  public void onMethodCall(final MethodCall call, @NonNull final MethodChannel.Result result) {
    final Map<String, Object> arguments = call.arguments();
    FirebaseDatabase database;
    String appName = call.argument("app");
    String databaseURL = call.argument("databaseURL");
    if (appName != null && databaseURL != null) {
      database = FirebaseDatabase.getInstance(FirebaseApp.getInstance(appName), databaseURL);
    } else if (appName != null) {
      database = FirebaseDatabase.getInstance(FirebaseApp.getInstance(appName));
    } else if (databaseURL != null) {
      database = FirebaseDatabase.getInstance(databaseURL);
    } else {
      database = FirebaseDatabase.getInstance();
    }
    switch (call.method) {
      case "FirebaseDatabase#goOnline":
        {
          database.goOnline();
          result.success(null);
          break;
        }

      case "FirebaseDatabase#goOffline":
        {
          database.goOffline();
          result.success(null);
          break;
        }

      case "FirebaseDatabase#purgeOutstandingWrites":
        {
          database.purgeOutstandingWrites();
          result.success(null);
          break;
        }

      case "FirebaseDatabase#setPersistenceEnabled":
        {
          Boolean isEnabled = call.argument("enabled");
          try {
            database.setPersistenceEnabled(isEnabled);
            result.success(true);
          } catch (DatabaseException e) {
            // Database is already in use, e.g. after hot reload/restart.
            result.success(false);
          }
          break;
        }

      case "FirebaseDatabase#setPersistenceCacheSizeBytes":
        {
          Long cacheSize = call.argument("cacheSize");
          try {
            database.setPersistenceCacheSizeBytes(cacheSize);
            result.success(true);
          } catch (DatabaseException e) {
            // Database is already in use, e.g. after hot reload/restart.
            result.success(false);
          }
          break;
        }

      case "DatabaseReference#set":
        {
          Object value = call.argument("value");
          Object priority = call.argument("priority");
          DatabaseReference reference = getReference(database, arguments);
          if (priority != null) {
            reference.setValue(
                value, priority, new MethodCallHandlerImpl.DefaultCompletionListener(result));
          } else {
            reference.setValue(value, new MethodCallHandlerImpl.DefaultCompletionListener(result));
          }
          break;
        }

      case "DatabaseReference#update":
        {
          Map<String, Object> value = call.argument("value");
          DatabaseReference reference = getReference(database, arguments);
          reference.updateChildren(
              value, new MethodCallHandlerImpl.DefaultCompletionListener(result));
          break;
        }

      case "DatabaseReference#setPriority":
        {
          Object priority = call.argument("priority");
          DatabaseReference reference = getReference(database, arguments);
          reference.setPriority(
              priority, new MethodCallHandlerImpl.DefaultCompletionListener(result));
          break;
        }

      case "DatabaseReference#runTransaction":
        {
          final DatabaseReference reference = getReference(database, arguments);

          // Initiate native transaction.
          reference.runTransaction(
              new Transaction.Handler() {
                @NonNull
                @Override
                public Transaction.Result doTransaction(@NonNull MutableData mutableData) {
                  // Tasks are used to allow native execution of doTransaction to wait while Snapshot is
                  // processed by logic on the Dart side.
                  final TaskCompletionSource<Map<String, Object>> updateMutableDataTCS =
                      new TaskCompletionSource<>();
                  final Task<Map<String, Object>> updateMutableDataTCSTask =
                      updateMutableDataTCS.getTask();

                  final Map<String, Object> doTransactionMap = new HashMap<>();
                  doTransactionMap.put("transactionKey", call.argument("transactionKey"));

                  final Map<String, Object> snapshotMap = new HashMap<>();
                  snapshotMap.put("key", mutableData.getKey());
                  snapshotMap.put("value", mutableData.getValue());
                  doTransactionMap.put("snapshot", snapshotMap);

                  // Return snapshot to Dart side for update.
                  handler.post(
                      new Runnable() {
                        @Override
                        public void run() {
                          channel.invokeMethod(
                              "DoTransaction",
                              doTransactionMap,
                              new MethodChannel.Result() {
                                @Override
                                @SuppressWarnings("unchecked")
                                public void success(Object result) {
                                  updateMutableDataTCS.setResult((Map<String, Object>) result);
                                }

                                @Override
                                public void error(
                                    String errorCode, String errorMessage, Object errorDetails) {
                                  String exceptionMessage =
                                      "Error code: "
                                          + errorCode
                                          + "\nError message: "
                                          + errorMessage
                                          + "\nError details: "
                                          + errorDetails;
                                  updateMutableDataTCS.setException(
                                      new Exception(exceptionMessage));
                                }

                                @Override
                                public void notImplemented() {
                                  updateMutableDataTCS.setException(
                                      new Exception("DoTransaction not implemented on Dart side."));
                                }
                              });
                        }
                      });

                  try {
                    // Wait for updated snapshot from the Dart side.
                    final Map<String, Object> updatedSnapshotMap =
                        Tasks.await(
                            updateMutableDataTCSTask,
                            (int) arguments.get("transactionTimeout"),
                            TimeUnit.MILLISECONDS);
                    // Set value of MutableData to value returned from the Dart side.
                    mutableData.setValue(updatedSnapshotMap.get("value"));
                  } catch (ExecutionException | InterruptedException | TimeoutException e) {
                    Log.e(TAG, "Unable to commit Snapshot update. Transaction failed.", e);
                    if (e instanceof TimeoutException) {
                      Log.e(TAG, "Transaction at " + reference.toString() + " timed out.");
                    }
                    return Transaction.abort();
                  }
                  return Transaction.success(mutableData);
                }

                @Override
                public void onComplete(
                    DatabaseError databaseError, boolean committed, DataSnapshot dataSnapshot) {
                  final Map<String, Object> completionMap = new HashMap<>();
                  completionMap.put("transactionKey", call.argument("transactionKey"));
                  if (databaseError != null) {
                    completionMap.put("error", asMap(databaseError));
                  }
                  completionMap.put("committed", committed);
                  if (dataSnapshot != null) {
                    Map<String, Object> snapshotMap = new HashMap<>();
                    snapshotMap.put("key", dataSnapshot.getKey());
                    snapshotMap.put("value", dataSnapshot.getValue());
                    completionMap.put("snapshot", snapshotMap);
                  }

                  // Invoke transaction completion on the Dart side.
                  handler.post(
                      new Runnable() {
                        public void run() {
                          result.success(completionMap);
                        }
                      });
                }
              });
          break;
        }

      case "OnDisconnect#set":
        {
          Object value = call.argument("value");
          Object priority = call.argument("priority");
          DatabaseReference reference = getReference(database, arguments);
          if (priority != null) {
            if (priority instanceof String) {
              reference
                  .onDisconnect()
                  .setValue(
                      value,
                      (String) priority,
                      new MethodCallHandlerImpl.DefaultCompletionListener(result));
            } else if (priority instanceof Double) {
              reference
                  .onDisconnect()
                  .setValue(
                      value,
                      (double) priority,
                      new MethodCallHandlerImpl.DefaultCompletionListener(result));
            } else if (priority instanceof Map) {
              reference
                  .onDisconnect()
                  .setValue(
                      value,
                      (Map) priority,
                      new MethodCallHandlerImpl.DefaultCompletionListener(result));
            }
          } else {
            reference
                .onDisconnect()
                .setValue(value, new MethodCallHandlerImpl.DefaultCompletionListener(result));
          }
          break;
        }

      case "OnDisconnect#update":
        {
          Map<String, Object> value = call.argument("value");
          DatabaseReference reference = getReference(database, arguments);
          reference
              .onDisconnect()
              .updateChildren(value, new MethodCallHandlerImpl.DefaultCompletionListener(result));
          break;
        }

      case "OnDisconnect#cancel":
        {
          DatabaseReference reference = getReference(database, arguments);
          reference
              .onDisconnect()
              .cancel(new MethodCallHandlerImpl.DefaultCompletionListener(result));
          break;
        }

      case "Query#keepSynced":
        {
          Boolean value = call.argument("value");
          getQuery(database, arguments).keepSynced(value);
          result.success(null);
          break;
        }

      case "Query#observe":
        {
          String eventType = call.argument("eventType");
          int handle = nextHandle++;
          MethodCallHandlerImpl.EventObserver observer =
              new MethodCallHandlerImpl.EventObserver(eventType, handle);
          observers.put(handle, observer);
          if (EVENT_TYPE_VALUE.equals(eventType)) {
            getQuery(database, arguments).addValueEventListener(observer);
          } else {
            getQuery(database, arguments).addChildEventListener(observer);
          }
          result.success(handle);
          break;
        }

      case "Query#removeObserver":
        {
          Query query = getQuery(database, arguments);
          Integer handle = call.argument("handle");
          MethodCallHandlerImpl.EventObserver observer = observers.get(handle);
          if (observer != null) {
            if (observer.requestedEventType.equals(EVENT_TYPE_VALUE)) {
              query.removeEventListener((ValueEventListener) observer);
            } else {
              query.removeEventListener((ChildEventListener) observer);
            }
            observers.delete(handle);
            result.success(null);
            break;
          } else {
            result.error("unknown_handle", "removeObserver called on an unknown handle", null);
            break;
          }
        }

      default:
        {
          result.notImplemented();
          break;
        }
    }
  }

  private static Map<String, Object> asMap(DatabaseError error) {
    Map<String, Object> map = new HashMap<>();
    map.put("code", error.getCode());
    map.put("message", error.getMessage());
    map.put("details", error.getDetails());
    return map;
  }
}
