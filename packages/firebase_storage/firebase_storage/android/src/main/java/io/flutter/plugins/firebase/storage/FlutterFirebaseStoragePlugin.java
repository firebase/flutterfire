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
import com.google.firebase.FirebaseApp;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.ListResult;
import com.google.firebase.storage.StorageMetadata;
import com.google.firebase.storage.StorageReference;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin;
import io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry;
import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;

public class FlutterFirebaseStoragePlugin
    implements FlutterFirebasePlugin,
        FlutterPlugin,
        GeneratedAndroidFirebaseStorage.FirebaseStorageHostApi {

  private MethodChannel channel;
  @Nullable private BinaryMessenger messenger;
  static final String STORAGE_METHOD_CHANNEL_NAME = "plugins.flutter.io/firebase_storage";
  static final String STORAGE_TASK_EVENT_NAME = "taskEvent";
  static final String DEFAULT_ERROR_CODE = "firebase_storage";

  static final Map<String, EventChannel> eventChannels = new HashMap<>();
  static final Map<String, StreamHandler> streamHandlers = new HashMap<>();

  static Map<String, String> getExceptionDetails(Exception exception) {
    Map<String, String> details = new HashMap<>();
    GeneratedAndroidFirebaseStorage.FlutterError storageException =
        FlutterFirebaseStorageException.parserExceptionToFlutter(exception);

    details.put("code", storageException.code);
    details.put("message", storageException.getMessage());

    return details;
  }

  static Map<String, Object> parseMetadataToMap(StorageMetadata storageMetadata) {
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

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    initInstance(binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    FlutterFirebaseStorageTask.cancelInProgressTasks();
    channel.setMethodCallHandler(null);
    assert messenger != null;
    GeneratedAndroidFirebaseStorage.FirebaseStorageHostApi.setup(messenger, null);
    channel = null;
    messenger = null;
    removeEventListeners();
  }

  private void initInstance(BinaryMessenger messenger) {
    FlutterFirebasePluginRegistry.registerPlugin(STORAGE_METHOD_CHANNEL_NAME, this);
    channel = new MethodChannel(messenger, STORAGE_METHOD_CHANNEL_NAME);
    GeneratedAndroidFirebaseStorage.FirebaseStorageHostApi.setup(messenger, this);
    this.messenger = messenger;
  }

  private String registerEventChannel(String prefix, String identifier, StreamHandler handler) {
    final String channelName = prefix + "/" + identifier;

    EventChannel channel = new EventChannel(messenger, channelName);
    channel.setStreamHandler(handler);
    eventChannels.put(identifier, channel);
    streamHandlers.put(identifier, handler);

    return identifier;
  }

  private synchronized void removeEventListeners() {
    // Create a list to hold the keys to remove after iteration
    List<String> eventChannelKeys = new ArrayList<>(eventChannels.keySet());
    for (String identifier : eventChannelKeys) {
      EventChannel eventChannel = eventChannels.get(identifier);
      if (eventChannel != null) {
        eventChannel.setStreamHandler(null);
      }
      eventChannels.remove(identifier);
    }

    // Create a list to hold the keys to remove after iteration
    List<String> streamHandlerKeys = new ArrayList<>(streamHandlers.keySet());
    for (String identifier : streamHandlerKeys) {
      StreamHandler streamHandler = streamHandlers.get(identifier);
      if (streamHandler != null) {
        streamHandler.onCancel(null);
      }
      streamHandlers.remove(identifier);
    }
  }

  private FirebaseStorage getStorageFromPigeon(
      GeneratedAndroidFirebaseStorage.PigeonStorageFirebaseApp app) {
    FirebaseApp androidApp = FirebaseApp.getInstance(app.getAppName());

    return FirebaseStorage.getInstance(androidApp, "gs://" + app.getBucket());
  }

  private StorageReference getReferenceFromPigeon(
      GeneratedAndroidFirebaseStorage.PigeonStorageFirebaseApp app,
      GeneratedAndroidFirebaseStorage.PigeonStorageReference reference) {
    FirebaseStorage androidStorage = getStorageFromPigeon(app);
    return androidStorage.getReference(reference.getFullPath());
  }

  private GeneratedAndroidFirebaseStorage.PigeonStorageReference convertToPigeonReference(
      StorageReference reference) {
    return new GeneratedAndroidFirebaseStorage.PigeonStorageReference.Builder()
        .setBucket(reference.getBucket())
        .setFullPath(reference.getPath())
        .setName(reference.getName())
        .build();
  }

  @Override
  public void getReferencebyPath(
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageFirebaseApp app,
      @NonNull String path,
      @Nullable String bucket,
      @NonNull
          GeneratedAndroidFirebaseStorage.Result<
                  GeneratedAndroidFirebaseStorage.PigeonStorageReference>
              result) {
    StorageReference androidReference = getStorageFromPigeon(app).getReference(path);

    result.success(convertToPigeonReference(androidReference));
  }

  @Override
  public void useStorageEmulator(
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageFirebaseApp app,
      @NonNull String host,
      @NonNull Long port,
      @NonNull GeneratedAndroidFirebaseStorage.Result<Void> result) {
    try {
      FirebaseStorage androidStorage = getStorageFromPigeon(app);
      androidStorage.useEmulator(host, port.intValue());
      result.success(null);
    } catch (Exception e) {
      result.error(FlutterFirebaseStorageException.parserExceptionToFlutter(e));
    }
  }

  // FirebaseStorageHostApi Reference related api override
  @Override
  public void referenceDelete(
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageReference reference,
      @NonNull GeneratedAndroidFirebaseStorage.Result<Void> result) {
    FirebaseStorage firebaseStorage = getStorageFromPigeon(app);
    StorageReference androidReference = firebaseStorage.getReference(reference.getFullPath());
    androidReference
        .delete()
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                result.success(null);
              } else {
                result.error(
                    FlutterFirebaseStorageException.parserExceptionToFlutter(task.getException()));
              }
            });
  }

  @Override
  public void referenceGetDownloadURL(
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageReference reference,
      @NonNull GeneratedAndroidFirebaseStorage.Result<String> result) {
    FirebaseStorage firebaseStorage = getStorageFromPigeon(app);

    StorageReference androidReference = firebaseStorage.getReference(reference.getFullPath());
    androidReference
        .getDownloadUrl()
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                Uri androidUrl = task.getResult();
                result.success(androidUrl.toString());
              } else {
                result.error(
                    FlutterFirebaseStorageException.parserExceptionToFlutter(task.getException()));
              }
            });
  }

  @Override
  public void referenceGetData(
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageReference reference,
      @NonNull Long maxSize,
      @NonNull GeneratedAndroidFirebaseStorage.Result<byte[]> result) {
    FirebaseStorage firebaseStorage = getStorageFromPigeon(app);
    StorageReference androidReference = firebaseStorage.getReference(reference.getFullPath());
    androidReference
        .getBytes(maxSize)
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                byte[] androidData = task.getResult();
                result.success(androidData);
              } else {
                result.error(
                    FlutterFirebaseStorageException.parserExceptionToFlutter(task.getException()));
              }
            });
  }

  GeneratedAndroidFirebaseStorage.PigeonFullMetaData convertToPigeonMetaData(
      StorageMetadata meteData) {
    return new GeneratedAndroidFirebaseStorage.PigeonFullMetaData.Builder()
        .setMetadata(parseMetadataToMap(meteData))
        .build();
  }

  @Override
  public void referenceGetMetaData(
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageReference reference,
      @NonNull
          GeneratedAndroidFirebaseStorage.Result<GeneratedAndroidFirebaseStorage.PigeonFullMetaData>
              result) {
    FirebaseStorage firebaseStorage = getStorageFromPigeon(app);
    StorageReference androidReference = firebaseStorage.getReference(reference.getFullPath());
    androidReference
        .getMetadata()
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                StorageMetadata androidMetaData = task.getResult();
                result.success(convertToPigeonMetaData(androidMetaData));
              } else {
                result.error(
                    FlutterFirebaseStorageException.parserExceptionToFlutter(task.getException()));
              }
            });
  }

  GeneratedAndroidFirebaseStorage.PigeonListResult convertToPigeonListResult(
      ListResult listResult) {
    List<GeneratedAndroidFirebaseStorage.PigeonStorageReference> pigeonItems = new ArrayList<>();
    for (StorageReference storageReference : listResult.getItems()) {
      pigeonItems.add(convertToPigeonReference(storageReference));
    }
    List<GeneratedAndroidFirebaseStorage.PigeonStorageReference> pigeonPrefixes = new ArrayList<>();
    for (StorageReference storageReference : listResult.getPrefixes()) {
      pigeonPrefixes.add(convertToPigeonReference(storageReference));
    }
    return new GeneratedAndroidFirebaseStorage.PigeonListResult.Builder()
        .setItems(pigeonItems)
        .setPageToken(listResult.getPageToken())
        .setPrefixs(pigeonPrefixes)
        .build();
  }

  @Override
  public void referenceList(
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageReference reference,
      @NonNull GeneratedAndroidFirebaseStorage.PigeonListOptions options,
      @NonNull
          GeneratedAndroidFirebaseStorage.Result<GeneratedAndroidFirebaseStorage.PigeonListResult>
              result) {
    FirebaseStorage firebaseStorage = getStorageFromPigeon(app);
    StorageReference androidReference = firebaseStorage.getReference(reference.getFullPath());
    Task<ListResult> androidResult;
    if (options.getPageToken() != null) {
      androidResult =
          androidReference.list(options.getMaxResults().intValue(), options.getPageToken());
    } else {
      androidResult = androidReference.list(options.getMaxResults().intValue());
    }
    androidResult.addOnCompleteListener(
        task -> {
          if (task.isSuccessful()) {
            ListResult androidListResult = task.getResult();
            result.success(convertToPigeonListResult(androidListResult));
          } else {
            result.error(
                FlutterFirebaseStorageException.parserExceptionToFlutter(task.getException()));
          }
        });
  }

  @Override
  public void referenceListAll(
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageReference reference,
      @NonNull
          GeneratedAndroidFirebaseStorage.Result<GeneratedAndroidFirebaseStorage.PigeonListResult>
              result) {
    FirebaseStorage firebaseStorage = getStorageFromPigeon(app);
    StorageReference androidReference = firebaseStorage.getReference(reference.getFullPath());
    androidReference
        .listAll()
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                ListResult androidListResult = task.getResult();
                result.success(convertToPigeonListResult(androidListResult));
              } else {
                result.error(
                    FlutterFirebaseStorageException.parserExceptionToFlutter(task.getException()));
              }
            });
  }

  StorageMetadata getMetaDataFromPigeon(
      GeneratedAndroidFirebaseStorage.PigeonSettableMetadata pigeonSettableMetatdata) {
    StorageMetadata.Builder androidMetaDataBuilder = new StorageMetadata.Builder();

    if (pigeonSettableMetatdata.getContentType() != null) {
      androidMetaDataBuilder.setContentType(pigeonSettableMetatdata.getContentType());
    }
    if (pigeonSettableMetatdata.getCacheControl() != null) {
      androidMetaDataBuilder.setCacheControl(pigeonSettableMetatdata.getCacheControl());
    }
    if (pigeonSettableMetatdata.getContentDisposition() != null) {
      androidMetaDataBuilder.setContentDisposition(pigeonSettableMetatdata.getContentDisposition());
    }
    if (pigeonSettableMetatdata.getContentEncoding() != null) {
      androidMetaDataBuilder.setContentEncoding(pigeonSettableMetatdata.getContentEncoding());
    }
    if (pigeonSettableMetatdata.getContentLanguage() != null) {
      androidMetaDataBuilder.setContentLanguage(pigeonSettableMetatdata.getContentLanguage());
    }

    Map<String, String> pigeonCustomMetadata = pigeonSettableMetatdata.getCustomMetadata();
    if (pigeonCustomMetadata != null) {
      for (Map.Entry<String, String> entry : pigeonCustomMetadata.entrySet()) {
        androidMetaDataBuilder.setCustomMetadata(entry.getKey(), entry.getValue());
      }
    }

    return androidMetaDataBuilder.build();
  }

  @Override
  public void referenceUpdateMetadata(
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageReference reference,
      @NonNull GeneratedAndroidFirebaseStorage.PigeonSettableMetadata metadata,
      @NonNull
          GeneratedAndroidFirebaseStorage.Result<GeneratedAndroidFirebaseStorage.PigeonFullMetaData>
              result) {
    FirebaseStorage firebaseStorage = getStorageFromPigeon(app);
    StorageReference androidReference = firebaseStorage.getReference(reference.getFullPath());
    androidReference
        .updateMetadata(getMetaDataFromPigeon(metadata))
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                StorageMetadata androidMetadata = task.getResult();
                result.success(convertToPigeonMetaData(androidMetadata));
              } else {
                result.error(
                    FlutterFirebaseStorageException.parserExceptionToFlutter(task.getException()));
              }
            });
  }

  @Override
  public void referencePutData(
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageReference reference,
      @NonNull byte[] data,
      @NonNull GeneratedAndroidFirebaseStorage.PigeonSettableMetadata settableMetaData,
      @NonNull Long handle,
      @NonNull GeneratedAndroidFirebaseStorage.Result<String> result) {

    StorageReference androidReference = getReferenceFromPigeon(app, reference);
    StorageMetadata androidMetaData = getMetaDataFromPigeon(settableMetaData);

    FlutterFirebaseStorageTask storageTask =
        FlutterFirebaseStorageTask.uploadBytes(
            handle.intValue(), androidReference, data, androidMetaData);
    try {
      String identifier = UUID.randomUUID().toString().toLowerCase(Locale.US);
      TaskStateChannelStreamHandler handler =
          storageTask.startTaskWithMethodChannel(channel, identifier);
      result.success(
          registerEventChannel(
              STORAGE_METHOD_CHANNEL_NAME + "/" + STORAGE_TASK_EVENT_NAME, identifier, handler));
    } catch (Exception e) {
      result.error(FlutterFirebaseStorageException.parserExceptionToFlutter(e));
    }
  }

  @Override
  public void referencePutString(
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageReference reference,
      @NonNull String data,
      @NonNull Long format,
      @NonNull GeneratedAndroidFirebaseStorage.PigeonSettableMetadata settableMetaData,
      @NonNull Long handle,
      @NonNull GeneratedAndroidFirebaseStorage.Result<String> result) {

    StorageReference androidReference = getReferenceFromPigeon(app, reference);
    StorageMetadata androidMetaData = getMetaDataFromPigeon(settableMetaData);

    FlutterFirebaseStorageTask storageTask =
        FlutterFirebaseStorageTask.uploadBytes(
            handle.intValue(),
            androidReference,
            stringToByteData(data, format.intValue()),
            androidMetaData);

    try {
      String identifier = UUID.randomUUID().toString().toLowerCase(Locale.US);
      TaskStateChannelStreamHandler handler =
          storageTask.startTaskWithMethodChannel(channel, identifier);
      result.success(
          registerEventChannel(
              STORAGE_METHOD_CHANNEL_NAME + "/" + STORAGE_TASK_EVENT_NAME, identifier, handler));
    } catch (Exception e) {
      result.error(FlutterFirebaseStorageException.parserExceptionToFlutter(e));
    }
  }

  @Override
  public void referencePutFile(
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageReference reference,
      @NonNull String filePath,
      @Nullable GeneratedAndroidFirebaseStorage.PigeonSettableMetadata settableMetaData,
      @NonNull Long handle,
      @NonNull GeneratedAndroidFirebaseStorage.Result<String> result) {

    StorageReference androidReference = getReferenceFromPigeon(app, reference);

    FlutterFirebaseStorageTask storageTask =
        FlutterFirebaseStorageTask.uploadFile(
            handle.intValue(),
            androidReference,
            Uri.fromFile(new File(filePath)),
            settableMetaData == null ? null : getMetaDataFromPigeon(settableMetaData));

    try {
      String identifier = UUID.randomUUID().toString().toLowerCase(Locale.US);
      TaskStateChannelStreamHandler handler =
          storageTask.startTaskWithMethodChannel(channel, identifier);
      result.success(
          registerEventChannel(
              STORAGE_METHOD_CHANNEL_NAME + "/" + STORAGE_TASK_EVENT_NAME, identifier, handler));
    } catch (Exception e) {
      result.error(FlutterFirebaseStorageException.parserExceptionToFlutter(e));
    }
  }

  @Override
  public void referenceDownloadFile(
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageReference reference,
      @NonNull String filePath,
      @NonNull Long handle,
      @NonNull GeneratedAndroidFirebaseStorage.Result<String> result) {

    StorageReference androidReference = getReferenceFromPigeon(app, reference);
    FlutterFirebaseStorageTask storageTask =
        FlutterFirebaseStorageTask.downloadFile(
            handle.intValue(), androidReference, new File(filePath));

    try {
      String identifier = UUID.randomUUID().toString().toLowerCase(Locale.US);
      TaskStateChannelStreamHandler handler =
          storageTask.startTaskWithMethodChannel(channel, identifier);
      result.success(
          registerEventChannel(
              STORAGE_METHOD_CHANNEL_NAME + "/" + STORAGE_TASK_EVENT_NAME, identifier, handler));
    } catch (Exception e) {
      result.error(FlutterFirebaseStorageException.parserExceptionToFlutter(e));
    }
  }

  // FirebaseStorageHostApi Task related api override
  @Override
  public void taskPause(
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageFirebaseApp app,
      @NonNull Long handle,
      @NonNull GeneratedAndroidFirebaseStorage.Result<Map<String, Object>> result) {

    FlutterFirebaseStorageTask storageTask =
        FlutterFirebaseStorageTask.getInProgressTaskForHandle(handle.intValue());

    if (storageTask == null) {
      result.error(
          new GeneratedAndroidFirebaseStorage.FlutterError(
              "unknown", "Pause operation was called on a task which does not exist.", null));
      return;
    }

    Map<String, Object> statusMap = new HashMap<>();
    try {
      boolean paused = storageTask.getAndroidTask().pause();
      statusMap.put("status", paused);
      if (paused) {
        statusMap.put(
            "snapshot", FlutterFirebaseStorageTask.parseTaskSnapshot(storageTask.getSnapshot()));
      }
      result.success(statusMap);
    } catch (Exception e) {
      result.error(FlutterFirebaseStorageException.parserExceptionToFlutter(e));
    }
  }

  @Override
  public void taskResume(
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageFirebaseApp app,
      @NonNull Long handle,
      @NonNull GeneratedAndroidFirebaseStorage.Result<Map<String, Object>> result) {

    FlutterFirebaseStorageTask storageTask =
        FlutterFirebaseStorageTask.getInProgressTaskForHandle(handle.intValue());

    if (storageTask == null) {
      result.error(
          new GeneratedAndroidFirebaseStorage.FlutterError(
              "unknown", "Resume operation was called on a task which does not exist.", null));
      return;
    }

    try {
      boolean resumed = storageTask.getAndroidTask().resume();
      Map<String, Object> statusMap = new HashMap<>();
      statusMap.put("status", resumed);
      if (resumed) {
        statusMap.put(
            "snapshot", FlutterFirebaseStorageTask.parseTaskSnapshot(storageTask.getSnapshot()));
      }
      result.success(statusMap);
    } catch (Exception e) {
      result.error(FlutterFirebaseStorageException.parserExceptionToFlutter(e));
    }
  }

  @Override
  public void taskCancel(
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageFirebaseApp app,
      @NonNull Long handle,
      @NonNull GeneratedAndroidFirebaseStorage.Result<Map<String, Object>> result) {
    FlutterFirebaseStorageTask storageTask =
        FlutterFirebaseStorageTask.getInProgressTaskForHandle(handle.intValue());
    if (storageTask == null) {
      result.error(
          new GeneratedAndroidFirebaseStorage.FlutterError(
              "unknown", "Cancel operation was called on a task which does not exist.", null));
      return;
    }

    try {
      boolean canceled = storageTask.getAndroidTask().cancel();
      Map<String, Object> statusMap = new HashMap<>();
      statusMap.put("status", canceled);
      if (canceled) {
        statusMap.put(
            "snapshot", FlutterFirebaseStorageTask.parseTaskSnapshot(storageTask.getSnapshot()));
      }
      result.success(statusMap);
    } catch (Exception e) {
      result.error(FlutterFirebaseStorageException.parserExceptionToFlutter(e));
    }
  }

  @Override
  public void setMaxOperationRetryTime(
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageFirebaseApp app,
      @NonNull Long time,
      @NonNull GeneratedAndroidFirebaseStorage.Result<Void> result) {
    FirebaseStorage androidStorage = getStorageFromPigeon(app);
    androidStorage.setMaxOperationRetryTimeMillis(time);
    result.success(null);
  }

  @Override
  public void setMaxUploadRetryTime(
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageFirebaseApp app,
      @NonNull Long time,
      @NonNull GeneratedAndroidFirebaseStorage.Result<Void> result) {
    FirebaseStorage androidStorage = getStorageFromPigeon(app);
    androidStorage.setMaxUploadRetryTimeMillis(time);
    result.success(null);
  }

  @Override
  public void setMaxDownloadRetryTime(
      @NonNull GeneratedAndroidFirebaseStorage.PigeonStorageFirebaseApp app,
      @NonNull Long time,
      @NonNull GeneratedAndroidFirebaseStorage.Result<Void> result) {
    FirebaseStorage androidStorage = getStorageFromPigeon(app);
    androidStorage.setMaxDownloadRetryTimeMillis(time);
    result.success(null);
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
          removeEventListeners();
        });

    return taskCompletionSource.getTask();
  }
}
