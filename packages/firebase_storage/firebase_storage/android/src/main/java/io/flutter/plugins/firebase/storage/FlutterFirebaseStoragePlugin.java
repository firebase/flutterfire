// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.storage;

import android.net.Uri;
import android.util.Base64;
import androidx.annotation.NonNull;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.ListResult;
import com.google.firebase.storage.StorageException;
import com.google.firebase.storage.StorageMetadata;
import com.google.firebase.storage.StorageReference;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin;
import io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry;
import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

public class FlutterFirebaseStoragePlugin
    implements FlutterFirebasePlugin, MethodCallHandler, FlutterPlugin {
  private MethodChannel channel;

  static Map<String, Object> parseMetadata(StorageMetadata storageMetadata) {
    if (storageMetadata == null) {
      return null;
    }

    Map<String, Object> out = new HashMap<>();
    if (storageMetadata.getName() != null) {
      out.put("name", storageMetadata.getName());
    }

    if (storageMetadata.getBucket() != null) {
      out.put("bucket", storageMetadata.getBucket());
    }

    if (storageMetadata.getGeneration() != null) {
      out.put("generation", storageMetadata.getGeneration());
    }

    if (storageMetadata.getMetadataGeneration() != null) {
      out.put("metadataGeneration", storageMetadata.getMetadataGeneration());
    }

    out.put("fullPath", storageMetadata.getPath());

    out.put("size", storageMetadata.getSizeBytes());

    out.put("creationTimeMillis", storageMetadata.getCreationTimeMillis());

    out.put("updatedTimeMillis", storageMetadata.getUpdatedTimeMillis());

    if (storageMetadata.getMd5Hash() != null) {
      out.put("md5Hash", storageMetadata.getMd5Hash());
    }

    if (storageMetadata.getCacheControl() != null) {
      out.put("cacheControl", storageMetadata.getCacheControl());
    }

    if (storageMetadata.getContentDisposition() != null) {
      out.put("contentDisposition", storageMetadata.getContentDisposition());
    }

    if (storageMetadata.getContentEncoding() != null) {
      out.put("contentEncoding", storageMetadata.getContentEncoding());
    }

    if (storageMetadata.getContentLanguage() != null) {
      out.put("contentLanguage", storageMetadata.getContentLanguage());
    }

    if (storageMetadata.getContentType() != null) {
      out.put("contentType", storageMetadata.getContentType());
    }

    Map<String, String> customMetadata = new HashMap<>();
    for (String key : storageMetadata.getCustomMetadataKeys()) {
      if (storageMetadata.getCustomMetadata(key) == null) {
        customMetadata.put(key, "");
      } else {
        customMetadata.put(key, Objects.requireNonNull(storageMetadata.getCustomMetadata(key)));
      }
    }
    out.put("customMetadata", customMetadata);
    return out;
  }

  static Map<String, String> getExceptionDetails(Exception exception) {
    Map<String, String> details = new HashMap<>();
    FlutterFirebaseStorageException storageException = null;

    if (exception instanceof StorageException) {
      storageException = new FlutterFirebaseStorageException(exception, exception.getCause());
    } else if (exception.getCause() != null && exception.getCause() instanceof StorageException) {
      storageException =
          new FlutterFirebaseStorageException(
              (StorageException) exception.getCause(),
              exception.getCause().getCause() != null
                  ? exception.getCause().getCause()
                  : exception.getCause());
    }

    if (storageException != null) {
      details.put("code", storageException.getCode());
      details.put("message", storageException.getMessage());
    }

    return details;
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    initInstance(binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    FlutterFirebaseStorageTask.cancelInProgressTasks();
    channel.setMethodCallHandler(null);
    channel = null;
  }

  private void initInstance(BinaryMessenger messenger) {
    String channelName = "plugins.flutter.io/firebase_storage";
    channel = new MethodChannel(messenger, channelName);
    channel.setMethodCallHandler(this);
    FlutterFirebasePluginRegistry.registerPlugin(channelName, this);
  }

  private FirebaseStorage getStorage(Map<String, Object> arguments) {
    String appName = (String) Objects.requireNonNull(arguments.get("appName"));
    FirebaseApp app = FirebaseApp.getInstance(appName);
    String bucket = (String) arguments.get("bucket");

    FirebaseStorage storage;

    if (bucket == null) {
      storage = FirebaseStorage.getInstance(app);
    } else {
      storage = FirebaseStorage.getInstance(app, "gs://" + bucket);
    }

    Object maxOperationRetryTime = arguments.get("maxOperationRetryTime");
    if (maxOperationRetryTime != null) {
      storage.setMaxOperationRetryTimeMillis(getLongValue(maxOperationRetryTime));
    }

    Object maxDownloadRetryTime = arguments.get("maxDownloadRetryTime");
    if (maxDownloadRetryTime != null) {
      storage.setMaxDownloadRetryTimeMillis(getLongValue(maxDownloadRetryTime));
    }

    Object maxUploadRetryTime = arguments.get("maxUploadRetryTime");
    if (maxUploadRetryTime != null) {
      storage.setMaxUploadRetryTimeMillis(getLongValue(maxUploadRetryTime));
    }

    return storage;
  }

  private StorageReference getReference(Map<String, Object> arguments) {
    String path = (String) Objects.requireNonNull(arguments.get("path"));
    return getStorage(arguments).getReference(path);
  }

  private Map<String, Object> parseListResult(ListResult listResult) {
    Map<String, Object> out = new HashMap<>();

    if (listResult.getPageToken() != null) {
      out.put("nextPageToken", listResult.getPageToken());
    }

    List<String> items = new ArrayList<>();
    List<String> prefixes = new ArrayList<>();

    for (StorageReference reference : listResult.getItems()) {
      items.add(reference.getPath());
    }

    for (StorageReference reference : listResult.getPrefixes()) {
      prefixes.add(reference.getPath());
    }

    out.put("items", items);
    out.put("prefixes", prefixes);
    return out;
  }

  private Task<Void> useEmulator(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          FirebaseStorage firebaseStorage = getStorage(arguments);
          String host = (String) Objects.requireNonNull(arguments.get("host"));
          int port = (int) Objects.requireNonNull((arguments.get("port")));
          firebaseStorage.useEmulator(host, port);
          taskCompletionSource.setResult(null);
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> referenceDelete(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          StorageReference reference = getReference(arguments);
          try {
            Tasks.await(reference.delete());
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Map<String, Object>> referenceGetDownloadURL(Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          StorageReference reference = getReference(arguments);
          try {
            Uri downloadURL = Tasks.await(reference.getDownloadUrl());
            Map<String, Object> out = new HashMap<>();
            out.put("downloadURL", downloadURL.toString());
            taskCompletionSource.setResult(out);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<byte[]> referenceGetData(Map<String, Object> arguments) {
    TaskCompletionSource<byte[]> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          Integer maxSize = (Integer) Objects.requireNonNull(arguments.get("maxSize"));
          StorageReference reference = getReference(arguments);
          try {
            taskCompletionSource.setResult(Tasks.await(reference.getBytes(maxSize)));
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Map<String, Object>> referenceGetMetadata(Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();
    cachedThreadPool.execute(
        () -> {
          StorageReference reference = getReference(arguments);
          try {
            taskCompletionSource.setResult(parseMetadata(Tasks.await(reference.getMetadata())));
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Map<String, Object>> referenceList(Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          StorageReference reference = getReference(arguments);
          Task<ListResult> task;

          @SuppressWarnings("unchecked")
          Map<String, Object> listOptions =
              (Map<String, Object>) Objects.requireNonNull(arguments.get("options"));

          int maxResults = (Integer) Objects.requireNonNull(listOptions.get("maxResults"));

          if (listOptions.get("pageToken") != null) {
            task =
                reference.list(
                    maxResults, (String) Objects.requireNonNull(listOptions.get("pageToken")));
          } else {
            task = reference.list(maxResults);
          }

          try {
            taskCompletionSource.setResult(parseListResult(Tasks.await(task)));
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Map<String, Object>> referenceListAll(Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          StorageReference reference = getReference(arguments);

          try {
            taskCompletionSource.setResult(parseListResult(Tasks.await(reference.listAll())));
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });
    return taskCompletionSource.getTask();
  }

  private Task<Map<String, Object>> referenceUpdateMetadata(Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          StorageReference reference = getReference(arguments);

          @SuppressWarnings("unchecked")
          Map<String, Object> metadata =
              (Map<String, Object>) Objects.requireNonNull(arguments.get("metadata"));

          try {
            taskCompletionSource.setResult(
                parseMetadata(Tasks.await(reference.updateMetadata(parseMetadata(metadata)))));
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> taskPutData(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          StorageReference reference = getReference(arguments);
          byte[] bytes = (byte[]) Objects.requireNonNull(arguments.get("data"));

          @SuppressWarnings("unchecked")
          Map<String, Object> metadata = (Map<String, Object>) arguments.get("metadata");

          final int handle = (int) Objects.requireNonNull(arguments.get("handle"));
          FlutterFirebaseStorageTask task =
              FlutterFirebaseStorageTask.uploadBytes(
                  handle, reference, bytes, parseMetadata(metadata));
          try {
            task.startTaskWithMethodChannel(channel);
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> taskPutString(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          StorageReference reference = getReference(arguments);
          String data = (String) Objects.requireNonNull(arguments.get("data"));
          int format = (int) Objects.requireNonNull(arguments.get("format"));

          @SuppressWarnings("unchecked")
          Map<String, Object> metadata = (Map<String, Object>) arguments.get("metadata");

          final int handle = (int) Objects.requireNonNull(arguments.get("handle"));
          FlutterFirebaseStorageTask task =
              FlutterFirebaseStorageTask.uploadBytes(
                  handle, reference, stringToByteData(data, format), parseMetadata(metadata));

          try {
            task.startTaskWithMethodChannel(channel);
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> taskPutFile(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          StorageReference reference = getReference(arguments);
          String filePath = (String) Objects.requireNonNull(arguments.get("filePath"));

          @SuppressWarnings("unchecked")
          Map<String, Object> metadata = (Map<String, Object>) arguments.get("metadata");

          final int handle = (int) Objects.requireNonNull(arguments.get("handle"));
          FlutterFirebaseStorageTask task =
              FlutterFirebaseStorageTask.uploadFile(
                  handle, reference, Uri.fromFile(new File(filePath)), parseMetadata(metadata));

          try {
            task.startTaskWithMethodChannel(channel);
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> taskWriteToFile(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();
    cachedThreadPool.execute(
        () -> {
          StorageReference reference = getReference(arguments);
          String filePath = (String) Objects.requireNonNull(arguments.get("filePath"));

          final int handle = (int) Objects.requireNonNull(arguments.get("handle"));
          FlutterFirebaseStorageTask task =
              FlutterFirebaseStorageTask.downloadFile(handle, reference, new File(filePath));

          try {
            task.startTaskWithMethodChannel(channel);
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Map<String, Object>> taskPause(Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();
    cachedThreadPool.execute(
        () -> {
          final int handle = (int) Objects.requireNonNull(arguments.get("handle"));
          FlutterFirebaseStorageTask task =
              FlutterFirebaseStorageTask.getInProgressTaskForHandle(handle);

          if (task == null) {
            taskCompletionSource.setException(
                new Exception("Pause operation was called on a task which does not exist."));
            return;
          }

          Map<String, Object> statusMap = new HashMap<>();
          try {
            boolean paused = Tasks.await(task.pause());
            statusMap.put("status", paused);
            if (paused) {
              statusMap.put(
                  "snapshot", FlutterFirebaseStorageTask.parseTaskSnapshot(task.getSnapshot()));
            }

            taskCompletionSource.setResult(statusMap);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Map<String, Object>> taskResume(Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();
    cachedThreadPool.execute(
        () -> {
          final int handle = (int) Objects.requireNonNull(arguments.get("handle"));
          FlutterFirebaseStorageTask task =
              FlutterFirebaseStorageTask.getInProgressTaskForHandle(handle);

          if (task == null) {
            taskCompletionSource.setException(
                new Exception("Resume operation was called on a task which does not exist."));
            return;
          }

          try {
            boolean resumed = Tasks.await(task.resume());
            Map<String, Object> statusMap = new HashMap<>();
            statusMap.put("status", resumed);
            if (resumed) {
              statusMap.put(
                  "snapshot", FlutterFirebaseStorageTask.parseTaskSnapshot(task.getSnapshot()));
            }

            taskCompletionSource.setResult(statusMap);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Map<String, Object>> taskCancel(Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();
    cachedThreadPool.execute(
        () -> {
          final int handle = (int) Objects.requireNonNull(arguments.get("handle"));
          FlutterFirebaseStorageTask task =
              FlutterFirebaseStorageTask.getInProgressTaskForHandle(handle);
          if (task == null) {
            taskCompletionSource.setException(
                new Exception("Cancel operation was called on a task which does not exist."));
            return;
          }

          try {
            boolean canceled = Tasks.await(task.cancel());
            Map<String, Object> statusMap = new HashMap<>();
            statusMap.put("status", canceled);
            if (canceled) {
              statusMap.put(
                  "snapshot", FlutterFirebaseStorageTask.parseTaskSnapshot(task.getSnapshot()));
            }

            taskCompletionSource.setResult(statusMap);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });
    return taskCompletionSource.getTask();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull final Result result) {
    Task<?> methodCallTask;

    switch (call.method) {
      case "Storage#useEmulator":
        methodCallTask = useEmulator(call.arguments());
        break;
      case "Reference#delete":
        methodCallTask = referenceDelete(call.arguments());
        break;
      case "Reference#getDownloadURL":
        methodCallTask = referenceGetDownloadURL(call.arguments());
        break;
      case "Reference#getMetadata":
        methodCallTask = referenceGetMetadata(call.arguments());
        break;
      case "Reference#getData":
        methodCallTask = referenceGetData(call.arguments());
        break;
      case "Reference#list":
        methodCallTask = referenceList(call.arguments());
        break;
      case "Reference#listAll":
        methodCallTask = referenceListAll(call.arguments());
        break;
      case "Reference#updateMetadata":
        methodCallTask = referenceUpdateMetadata(call.arguments());
        break;
      case "Task#startPutData":
        methodCallTask = taskPutData(call.arguments());
        break;
      case "Task#startPutString":
        methodCallTask = taskPutString(call.arguments());
        break;
      case "Task#startPutFile":
        methodCallTask = taskPutFile(call.arguments());
        break;
      case "Task#pause":
        methodCallTask = taskPause(call.arguments());
        break;
      case "Task#resume":
        methodCallTask = taskResume(call.arguments());
        break;
      case "Task#cancel":
        methodCallTask = taskCancel(call.arguments());
        break;
      case "Task#writeToFile":
        methodCallTask = taskWriteToFile(call.arguments());
        break;
      default:
        result.notImplemented();
        return;
    }

    methodCallTask.addOnCompleteListener(
        task -> {
          if (task.isSuccessful()) {
            result.success(task.getResult());
          } else {
            Exception exception = task.getException();
            Map<String, String> exceptionDetails = getExceptionDetails(exception);

            result.error(
                "firebase_storage",
                exception != null ? exception.getMessage() : null,
                exceptionDetails);
          }
        });
  }

  private StorageMetadata parseMetadata(Map<String, Object> metadata) {
    if (metadata == null) {
      return null;
    }

    StorageMetadata.Builder builder = new StorageMetadata.Builder();

    if (metadata.get("cacheControl") != null) {
      builder.setCacheControl((String) metadata.get("cacheControl"));
    }
    if (metadata.get("contentDisposition") != null) {
      builder.setContentDisposition((String) metadata.get("contentDisposition"));
    }
    if (metadata.get("contentEncoding") != null) {
      builder.setContentEncoding((String) metadata.get("contentEncoding"));
    }
    if (metadata.get("contentLanguage") != null) {
      builder.setContentLanguage((String) metadata.get("contentLanguage"));
    }
    if (metadata.get("contentType") != null) {
      builder.setContentType((String) metadata.get("contentType"));
    }
    if (metadata.get("customMetadata") != null) {
      @SuppressWarnings("unchecked")
      Map<String, String> customMetadata =
          (Map<String, String>) Objects.requireNonNull(metadata.get("customMetadata"));
      for (String key : customMetadata.keySet()) {
        builder.setCustomMetadata(key, customMetadata.get(key));
      }
    }

    return builder.build();
  }

  private byte[] stringToByteData(@NonNull String data, int format) {
    switch (format) {
      case 1: // PutStringFormat.base64
        return Base64.decode(data, Base64.DEFAULT);
      case 2: // PutStringFormat.base64Url
        return Base64.decode(data, Base64.URL_SAFE);
      default:
        return null;
    }
  }

  private Long getLongValue(Object value) {
    if (value instanceof Long) {
      return (Long) value;
    } else if (value instanceof Integer) {
      return Long.valueOf((Integer) value);
    } else {
      return 0L;
    }
  }

  @Override
  public Task<Map<String, Object>> getPluginConstantsForFirebaseApp(FirebaseApp firebaseApp) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();
    cachedThreadPool.execute(
        () -> {
          HashMap<String, Object> obj = new HashMap<String, Object>();
          taskCompletionSource.setResult(obj);
        });

    return taskCompletionSource.getTask();
  }

  @Override
  public Task<Void> didReinitializeFirebaseCore() {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();
    cachedThreadPool.execute(
        () -> {
          FlutterFirebaseStorageTask.cancelInProgressTasks();
          taskCompletionSource.setResult(null);
        });

    return taskCompletionSource.getTask();
  }
}
