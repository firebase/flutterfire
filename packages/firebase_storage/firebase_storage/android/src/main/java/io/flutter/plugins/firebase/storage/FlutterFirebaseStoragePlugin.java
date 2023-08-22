// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.storage;

import android.net.Uri;
import android.util.Base64;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
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
import io.flutter.plugin.common.EventChannel;
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
    implements FlutterFirebasePlugin,
    FlutterPlugin,
    GeneratedAndroidFirebaseStorage.FirebaseStorageHostApi {

  private MethodChannel channel;
  @Nullable
  private BinaryMessenger messenger;

  private static final String METHOD_CHANNEL_NAME = "plugins.flutter.io/firebase_storage";

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
      storageException = new FlutterFirebaseStorageException(
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
    messenger = null;
    GeneratedAndroidFirebaseStorage.FirebaseStorageHostApi.setup(messenger, null);
  }

  private void initInstance(BinaryMessenger messenger) {
    channel = new MethodChannel(messenger, METHOD_CHANNEL_NAME);
    FlutterFirebasePluginRegistry.registerPlugin(METHOD_CHANNEL_NAME, this);

    GeneratedAndroidFirebaseStorage.FirebaseStorageHostApi.setup(messenger, this);
    this.messenger = messenger;
  }

  private FirebaseStorage getStorageFromPigeon(GeneratedAndroidFirebaseStorage.PigeonFirebaseApp app) {
    return getStorageFromPigeon(app, null);
  }

  private FirebaseStorage getStorageFromPigeon(GeneratedAndroidFirebaseStorage.PigeonFirebaseApp app,
      @Nullable String bucket) {
    FirebaseApp androidApp = FirebaseApp.getInstance(app.getAppName());
    if (bucket == null) {
      return FirebaseStorage.getInstance(androidApp);
    } else {
      return FirebaseStorage.getInstance(androidApp, "gs://" + bucket);
    }
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

  private GeneratedAndroidFirebaseStorage.PigeonStorageReference convertToPigeonReference(StorageReference reference) {
    return new GeneratedAndroidFirebaseStorage.PigeonStorageReference.Builder()
        .setBucket(reference.getBucket())
        .setFullPath(reference.getPath())
        .setName(reference.getName())
        .build();
  }

  @Override
  public GeneratedAndroidFirebaseStorage.PigeonStorageReference getReferencebyPath(
      @NonNull GeneratedAndroidFirebaseStorage.PigeonFirebaseApp app, @NonNull String path,
      @Nullable String bucket) {
    StorageReference androidReference = getStorageFromPigeon(app, bucket).getReference(path);

    return convertToPigeonReference(androidReference);
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

  @Override
  public void useStorageEmulator(@NonNull GeneratedAndroidFirebaseStorage.PigeonFirebaseApp app, @NonNull String host,
      @NonNull Long port,
      @NonNull GeneratedAndroidFirebaseStorage.Result<Void> result) {
    try {
      FirebaseStorage androidStorage = getStorageFromPigeon(app);
      androidStorage.useEmulator(host, port.intValue());
      result.success(null);
    } catch (Exception e) {
      result.error(e);
    }
  }

  // FirebaseStorageHostApi Reference releated api override
  @Override
  public void referenceDelete(@NonNull GeneratedAndroidFirebaseStorage.PigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageReference reference,
      @NonNull GeneratedAndroidFirebaseStorage.Result<Void> result) {
    FirebaseStorage firebaseStorage = getStorageFromPigeon(app);
    StorageReference androidReference = firebaseStorage.getReference(reference.getFullPath());
    androidReference.delete().addOnCompleteListener(
        task -> {
          if (task.isSuccessful()) {
            result.success(null);
          } else {
            result.error(
                task.getException());
          }
        });

  }

  @Override
  public void referenceGetDownloadURL(@NonNull GeneratedAndroidFirebaseStorage.PigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageReference reference,
      @NonNull GeneratedAndroidFirebaseStorage.Result<String> result) {
    FirebaseStorage firebaseStorage = getStorageFromPigeon(app);
    StorageReference androidReference = firebaseStorage.getReference(reference.getFullPath());
    androidReference.getDownloadUrl().addOnCompleteListener(
        task -> {
          if (task.isSuccessful()) {
            Uri androidUrl = task.getResult();
            result.success(androidUrl.toString());
          } else {
            result.error(
                task.getException());
          }
        });
  }

  @Override
  public void referenceGetData(@NonNull GeneratedAndroidFirebaseStorage.PigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageReference reference,
      @NonNull Long maxSize, @NonNull GeneratedAndroidFirebaseStorage.Result<byte[]> result) {
    FirebaseStorage firebaseStorage = getStorageFromPigeon(app);
    StorageReference androidReference = firebaseStorage.getReference(reference.getFullPath());
    androidReference.getBytes(maxSize).addOnCompleteListener(
        task -> {
          if (task.isSuccessful()) {
            byte[] androidData = task.getResult();
            result.success(androidData);
          } else {
            result.error(
                task.getException());
          }
        });
  }

  GeneratedAndroidFirebaseStorage.PigeonFullMetaData convertToPigeonMetaData(StorageMetadata meteData) {
    return new GeneratedAndroidFirebaseStorage.PigeonFullMetaData.Builder().setMetadata(parseMetadata(meteData))
        .build();
  }

  @Override
  public void referenceGetMetaData(@NonNull GeneratedAndroidFirebaseStorage.PigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageReference reference,
      @NonNull GeneratedAndroidFirebaseStorage.Result<GeneratedAndroidFirebaseStorage.PigeonFullMetaData> result) {
    FirebaseStorage firebaseStorage = getStorageFromPigeon(app);
    StorageReference androidReference = firebaseStorage.getReference(reference.getFullPath());
    androidReference.getMetadata().addOnCompleteListener(
        task -> {
          if (task.isSuccessful()) {
            StorageMetadata androidMetaData = task.getResult();
            result.success(convertToPigeonMetaData(androidMetaData));
          } else {
            result.error(
                task.getException());
          }
        });
  }

  GeneratedAndroidFirebaseStorage.PigeonListResult convertToPigeonListResult(ListResult listResult) {
    List<GeneratedAndroidFirebaseStorage.PigeonStorageReference> pigeonItems = new ArrayList<>();
    for (StorageReference storageReference : listResult.getItems()) {
      pigeonItems.add(convertToPigeonReference(storageReference));
    }
    List<GeneratedAndroidFirebaseStorage.PigeonStorageReference> pigeonPrefixes = new ArrayList<>();
    for (StorageReference storageReference : listResult.getPrefixes()) {
      pigeonPrefixes.add(convertToPigeonReference(storageReference));
    }
    return new GeneratedAndroidFirebaseStorage.PigeonListResult.Builder().setItems(pigeonItems)
        .setPageToken(listResult.getPageToken())
        .setPrefixs(pigeonPrefixes).build();
  }

  @Override
  public void referenceList(@NonNull GeneratedAndroidFirebaseStorage.PigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageReference reference,
      @NonNull GeneratedAndroidFirebaseStorage.PigeonListOptions options,
      @NonNull GeneratedAndroidFirebaseStorage.Result<GeneratedAndroidFirebaseStorage.PigeonListResult> result) {
    FirebaseStorage firebaseStorage = getStorageFromPigeon(app);
    StorageReference androidReference = firebaseStorage.getReference(reference.getFullPath());
    androidReference.list(options.getMaxResults().intValue(), options.getPageToken()).addOnCompleteListener(
        task -> {
          if (task.isSuccessful()) {
            ListResult androidListResult = task.getResult();
            result.success(convertToPigeonListResult(androidListResult));
          } else {
            result.error(
                task.getException());
          }
        });
  }

  @Override
  public void referenceListAll(@NonNull GeneratedAndroidFirebaseStorage.PigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageReference reference,
      @NonNull GeneratedAndroidFirebaseStorage.Result<GeneratedAndroidFirebaseStorage.PigeonListResult> result) {
    FirebaseStorage firebaseStorage = getStorageFromPigeon(app);
    StorageReference androidReference = firebaseStorage.getReference(reference.getFullPath());
    androidReference.listAll().addOnCompleteListener(
        task -> {
          if (task.isSuccessful()) {
            ListResult androidListResult = task.getResult();
            result.success(convertToPigeonListResult(androidListResult));
          } else {
            result.error(
                task.getException());
          }
        });
  }

  StorageMetadata convertToStorageMetaData(
      GeneratedAndroidFirebaseStorage.PigeonSettableMetadata pigeonSettableMetatdata) {
    StorageMetadata.Builder androidMetaDataBuilder = new StorageMetadata.Builder()
        .setCacheControl(pigeonSettableMetatdata.getCacheControl())
        .setContentDisposition(pigeonSettableMetatdata.getContentDisposition())
        .setContentEncoding(pigeonSettableMetatdata.getContentEncoding())
        .setContentLanguage(pigeonSettableMetatdata.getContentLanguage())
        .setContentType(pigeonSettableMetatdata.getContentType());

    for (Map.Entry<String, String> entry : pigeonSettableMetatdata.getCustomMetadata().entrySet()) {
      androidMetaDataBuilder.setCustomMetadata(entry.getKey(), entry.getValue());
      // System.out.println(entry.getKey() + "/" + entry.getValue());
    }
    // pigeonSettableMetatdata.getCustomMetadata()
    // .foreach((key, value) -> androidMetaDataBuilder.setCustomMetadata(key,
    // value));
    return androidMetaDataBuilder.build();
  }

  @Override
  public void referenceUpdateMetadata(@NonNull GeneratedAndroidFirebaseStorage.PigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageReference reference,
      @NonNull GeneratedAndroidFirebaseStorage.PigeonSettableMetadata metadata,
      @NonNull GeneratedAndroidFirebaseStorage.Result<GeneratedAndroidFirebaseStorage.PigeonFullMetaData> result) {
    FirebaseStorage firebaseStorage = getStorageFromPigeon(app);
    StorageReference androidReference = firebaseStorage.getReference(reference.getFullPath());
    androidReference.updateMetadata(convertToStorageMetaData(metadata)).addOnCompleteListener(
        task -> {
          if (task.isSuccessful()) {
            StorageMetadata androidMetadata = task.getResult();
            result.success(convertToPigeonMetaData(androidMetadata));
          } else {
            result.error(
                task.getException());
          }
        });
  }

  @Override
  public void registerStorageTask(@NonNull GeneratedAndroidFirebaseStorage.PigeonFirebaseApp app,
      @Nullable String bucket,
      @NonNull GeneratedAndroidFirebaseStorage.Result<String> result) {
    try {
      final FirebaseStorage androidStorage = getStorageFromPigeon(app, bucket);

      final String name = METHOD_CHANNEL_NAME + "/task/" + androidStorage.getApp().getName();
      // final EventChannel channel = new EventChannel(messenger, name);
      // channel.setStreamHandler(handler);
      // streamHandlers.put(channel, handler);
      result.success(name);
    } catch (Exception e) {
      result.error(e);
    }
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
          FlutterFirebaseStorageTask task = FlutterFirebaseStorageTask.uploadBytes(
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
          FlutterFirebaseStorageTask task = FlutterFirebaseStorageTask.uploadBytes(
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
          FlutterFirebaseStorageTask task = FlutterFirebaseStorageTask.uploadFile(
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
          FlutterFirebaseStorageTask task = FlutterFirebaseStorageTask.downloadFile(handle, reference,
              new File(filePath));

          try {
            task.startTaskWithMethodChannel(channel);
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  // FirebaseStorageHostApi Task releated api override
  @Override
  public void taskPause(@NonNull GeneratedAndroidFirebaseStorage.PigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseStorage.PigeonTaskSnapShot taskSnap,
      @NonNull GeneratedAndroidFirebaseStorage.Result<Boolean> result) {

    // TaskCompletionSource<Map<String, Object>> taskCompletionSource = new
    // TaskCompletionSource<>();
    // cachedThreadPool.execute(
    // () -> {
    // final int handle = (int) Objects.requireNonNull(arguments.get("handle"));
    // FlutterFirebaseStorageTask task =
    // FlutterFirebaseStorageTask.getInProgressTaskForHandle(handle);

    // if (task == null) {
    // taskCompletionSource.setException(
    // new Exception("Pause operation was called on a task which does not exist."));
    // return;
    // }

    // Map<String, Object> statusMap = new HashMap<>();
    // try {
    // boolean paused = Tasks.await(task.pause());
    // statusMap.put("status", paused);
    // if (paused) {
    // statusMap.put(
    // "snapshot",
    // FlutterFirebaseStorageTask.parseTaskSnapshot(task.getSnapshot()));
    // }

    // taskCompletionSource.setResult(statusMap);
    // } catch (Exception e) {
    // taskCompletionSource.setException(e);
    // }
    // });

    // return taskCompletionSource.getTask();
  }

  @Override
  public void taskResume(@NonNull GeneratedAndroidFirebaseStorage.PigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseStorage.PigeonTaskSnapShot taskSnap,
      @NonNull GeneratedAndroidFirebaseStorage.Result<Boolean> result) {
    // TaskCompletionSource<Map<String, Object>> taskCompletionSource = new
    // TaskCompletionSource<>();
    // cachedThreadPool.execute(
    // () -> {
    // final int handle = (int) Objects.requireNonNull(arguments.get("handle"));
    // FlutterFirebaseStorageTask task =
    // FlutterFirebaseStorageTask.getInProgressTaskForHandle(handle);

    // if (task == null) {
    // taskCompletionSource.setException(
    // new Exception("Resume operation was called on a task which does not
    // exist."));
    // return;
    // }

    // try {
    // boolean resumed = Tasks.await(task.resume());
    // Map<String, Object> statusMap = new HashMap<>();
    // statusMap.put("status", resumed);
    // if (resumed) {
    // statusMap.put(
    // "snapshot",
    // FlutterFirebaseStorageTask.parseTaskSnapshot(task.getSnapshot()));
    // }

    // taskCompletionSource.setResult(statusMap);
    // } catch (Exception e) {
    // taskCompletionSource.setException(e);
    // }
    // });

    // return taskCompletionSource.getTask();
  }

  @Override
  public void taskCancel(@NonNull GeneratedAndroidFirebaseStorage.PigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseStorage.PigeonTaskSnapShot taskSnap,
      @NonNull GeneratedAndroidFirebaseStorage.Result<Boolean> result) {
    // TaskCompletionSource<Map<String, Object>> taskCompletionSource = new
    // TaskCompletionSource<>();
    // cachedThreadPool.execute(
    // () -> {
    // final int handle = (int) Objects.requireNonNull(arguments.get("handle"));
    // FlutterFirebaseStorageTask task =
    // FlutterFirebaseStorageTask.getInProgressTaskForHandle(handle);
    // if (task == null) {
    // taskCompletionSource.setException(
    // new Exception("Cancel operation was called on a task which does not
    // exist."));
    // return;
    // }

    // try {
    // boolean canceled = Tasks.await(task.cancel());
    // Map<String, Object> statusMap = new HashMap<>();
    // statusMap.put("status", canceled);
    // if (canceled) {
    // statusMap.put(
    // "snapshot",
    // FlutterFirebaseStorageTask.parseTaskSnapshot(task.getSnapshot()));
    // }

    // taskCompletionSource.setResult(statusMap);
    // } catch (Exception e) {
    // taskCompletionSource.setException(e);
    // }
    // });
    // return taskCompletionSource.getTask();
  }

  @Override
  public void setMaxOperationRetryTime(@NonNull GeneratedAndroidFirebaseStorage.PigeonFirebaseApp app,
      @NonNull Long time) {
    FirebaseStorage androidStorage = getStorageFromPigeon(app);
    androidStorage.setMaxOperationRetryTimeMillis(time);
  }

  @Override
  public void setMaxUploadRetryTime(@NonNull GeneratedAndroidFirebaseStorage.PigeonFirebaseApp app,
      @NonNull Long time) {
    FirebaseStorage androidStorage = getStorageFromPigeon(app);
    androidStorage.setMaxUploadRetryTimeMillis(time);
  }

  @Override
  public void setMaxDownloadRetryTime(@NonNull GeneratedAndroidFirebaseStorage.PigeonFirebaseApp app,
      @NonNull Long time) {
    FirebaseStorage androidStorage = getStorageFromPigeon(app);
    androidStorage.setMaxDownloadRetryTimeMillis(time);
  }

  // @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull final Result result) {
    Task<?> methodCallTask;

    switch (call.method) {
      // case "Storage#useEmulator":
      // methodCallTask = useEmulator(call.arguments());
      // break;
      // case "Reference#delete":
      // methodCallTask = referenceDelete(call.arguments());
      // break;
      // case "Reference#getDownloadURL":
      // methodCallTask = referenceGetDownloadURL(call.arguments());
      // break;
      // case "Reference#getMetadata":
      // methodCallTask = referenceGetMetadata(call.arguments());
      // break;
      // case "Reference#getData":
      // methodCallTask = referenceGetData(call.arguments());
      // break;
      // case "Reference#list":
      // methodCallTask = referenceList(call.arguments());
      // break;
      // case "Reference#listAll":
      // methodCallTask = referenceListAll(call.arguments());
      // break;
      // case "Reference#updateMetadata":
      // methodCallTask = referenceUpdateMetadata(call.arguments());
      // break;
      case "Task#startPutData":
        methodCallTask = taskPutData(call.arguments());
        break;
      case "Task#startPutString":
        methodCallTask = taskPutString(call.arguments());
        break;
      case "Task#startPutFile":
        methodCallTask = taskPutFile(call.arguments());
        break;
      // case "Task#pause":
      // methodCallTask = taskPause(call.arguments());
      // break;
      // case "Task#resume":
      // methodCallTask = taskResume(call.arguments());
      // break;
      // case "Task#cancel":
      // methodCallTask = taskCancel(call.arguments());
      // break;
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
      Map<String, String> customMetadata = (Map<String, String>) Objects.requireNonNull(metadata.get("customMetadata"));
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
