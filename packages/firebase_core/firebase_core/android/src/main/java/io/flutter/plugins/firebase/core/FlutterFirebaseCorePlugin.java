// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.core;

import static io.flutter.plugins.firebase.core.FlutterFirebasePlugin.cachedThreadPool;

import android.content.Context;
import android.os.Looper;
import androidx.annotation.NonNull;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Flutter plugin implementation controlling the entrypoint for the Firebase SDK.
 *
 * <p>Instantiate this in an add to app scenario to gracefully handle activity and context changes.
 */
public class FlutterFirebaseCorePlugin
    implements FlutterPlugin,
        GeneratedAndroidFirebaseCore.FirebaseCoreHostApi,
        GeneratedAndroidFirebaseCore.FirebaseAppHostApi {
  private Context applicationContext;
  private boolean coreInitialized = false;

  public static Map<String, String> customAuthDomain = new HashMap<>();

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    GeneratedAndroidFirebaseCore.FirebaseCoreHostApi.setUp(binding.getBinaryMessenger(), this);
    GeneratedAndroidFirebaseCore.FirebaseAppHostApi.setUp(binding.getBinaryMessenger(), this);
    applicationContext = binding.getApplicationContext();
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    applicationContext = null;
    GeneratedAndroidFirebaseCore.FirebaseCoreHostApi.setUp(binding.getBinaryMessenger(), null);
    GeneratedAndroidFirebaseCore.FirebaseAppHostApi.setUp(binding.getBinaryMessenger(), null);
  }

  private GeneratedAndroidFirebaseCore.CoreFirebaseOptions firebaseOptionsToMap(
      FirebaseOptions options) {
    GeneratedAndroidFirebaseCore.CoreFirebaseOptions.Builder firebaseOptions =
        new GeneratedAndroidFirebaseCore.CoreFirebaseOptions.Builder();

    firebaseOptions.setApiKey(options.getApiKey());
    firebaseOptions.setAppId(options.getApplicationId());
    if (options.getGcmSenderId() != null) {
      firebaseOptions.setMessagingSenderId(options.getGcmSenderId());
    }
    if (options.getProjectId() != null) {
      firebaseOptions.setProjectId(options.getProjectId());
    }
    firebaseOptions.setDatabaseURL(options.getDatabaseUrl());
    firebaseOptions.setStorageBucket(options.getStorageBucket());
    firebaseOptions.setTrackingId(options.getGaTrackingId());

    return firebaseOptions.build();
  }

  private Task<GeneratedAndroidFirebaseCore.CoreInitializeResponse> firebaseAppToMap(
      FirebaseApp firebaseApp) {
    TaskCompletionSource<GeneratedAndroidFirebaseCore.CoreInitializeResponse> taskCompletionSource =
        new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            GeneratedAndroidFirebaseCore.CoreInitializeResponse.Builder initializeResponse =
                new GeneratedAndroidFirebaseCore.CoreInitializeResponse.Builder();

            initializeResponse.setName(firebaseApp.getName());
            initializeResponse.setOptions(firebaseOptionsToMap(firebaseApp.getOptions()));

            initializeResponse.setIsAutomaticDataCollectionEnabled(
                firebaseApp.isDataCollectionDefaultEnabled());
            initializeResponse.setPluginConstants(
                Tasks.await(
                    FlutterFirebasePluginRegistry.getPluginConstantsForFirebaseApp(firebaseApp)));

            taskCompletionSource.setResult(initializeResponse.build());
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private <T> void listenToResponse(
      TaskCompletionSource<T> taskCompletionSource, GeneratedAndroidFirebaseCore.Result<T> result) {
    taskCompletionSource
        .getTask()
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                result.success(task.getResult());
              } else {
                Exception exception = task.getException();
                result.error(exception);
              }
            });
  }

  private void listenToVoidResponse(
      TaskCompletionSource<Void> taskCompletionSource,
      GeneratedAndroidFirebaseCore.VoidResult result) {
    taskCompletionSource
        .getTask()
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                result.success();
              } else {
                Exception exception = task.getException();
                result.error(exception);
              }
            });
  }

  @Override
  public void initializeApp(
      @NonNull String appName,
      @NonNull GeneratedAndroidFirebaseCore.CoreFirebaseOptions initializeAppRequest,
      GeneratedAndroidFirebaseCore.Result<GeneratedAndroidFirebaseCore.CoreInitializeResponse>
          result) {
    TaskCompletionSource<GeneratedAndroidFirebaseCore.CoreInitializeResponse> taskCompletionSource =
        new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {

            FirebaseOptions options =
                new FirebaseOptions.Builder()
                    .setApiKey(initializeAppRequest.getApiKey())
                    .setApplicationId(initializeAppRequest.getAppId())
                    .setDatabaseUrl(initializeAppRequest.getDatabaseURL())
                    .setGcmSenderId(initializeAppRequest.getMessagingSenderId())
                    .setProjectId(initializeAppRequest.getProjectId())
                    .setStorageBucket(initializeAppRequest.getStorageBucket())
                    .setGaTrackingId(initializeAppRequest.getTrackingId())
                    .build();
            // TODO(Salakar) hacky workaround a bug with FirebaseInAppMessaging causing the error:
            //    Can't create handler inside thread Thread[pool-3-thread-1,5,main] that has not called Looper.prepare()
            //     at com.google.firebase.inappmessaging.internal.ForegroundNotifier.<init>(ForegroundNotifier.java:61)
            try {
              Looper.prepare();
            } catch (Exception e) {
              // do nothing
            }

            if (initializeAppRequest.getAuthDomain() != null) {
              customAuthDomain.put(appName, initializeAppRequest.getAuthDomain());
            }

            FirebaseApp firebaseApp =
                FirebaseApp.initializeApp(applicationContext, options, appName);
            taskCompletionSource.setResult(Tasks.await(firebaseAppToMap(firebaseApp)));
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    listenToResponse(taskCompletionSource, result);
  }

  @Override
  public void initializeCore(
      GeneratedAndroidFirebaseCore.Result<List<GeneratedAndroidFirebaseCore.CoreInitializeResponse>>
          result) {
    TaskCompletionSource<List<GeneratedAndroidFirebaseCore.CoreInitializeResponse>>
        taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            if (!coreInitialized) {
              coreInitialized = true;
            } else {
              Tasks.await(FlutterFirebasePluginRegistry.didReinitializeFirebaseCore());
            }

            List<FirebaseApp> firebaseApps = FirebaseApp.getApps(applicationContext);
            List<GeneratedAndroidFirebaseCore.CoreInitializeResponse> firebaseAppsList =
                new ArrayList<>(firebaseApps.size());

            for (FirebaseApp firebaseApp : firebaseApps) {
              firebaseAppsList.add(Tasks.await(firebaseAppToMap(firebaseApp)));
            }

            taskCompletionSource.setResult(firebaseAppsList);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    listenToResponse(taskCompletionSource, result);
  }

  @Override
  public void optionsFromResource(
      GeneratedAndroidFirebaseCore.Result<GeneratedAndroidFirebaseCore.CoreFirebaseOptions>
          result) {
    TaskCompletionSource<GeneratedAndroidFirebaseCore.CoreFirebaseOptions> taskCompletionSource =
        new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final FirebaseOptions options = FirebaseOptions.fromResource(applicationContext);
            if (options == null) {
              taskCompletionSource.setException(
                  new Exception(
                      "Failed to load FirebaseOptions from resource. Check that you have defined values.xml correctly."));
              return;
            }
            taskCompletionSource.setResult(firebaseOptionsToMap(options));
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    listenToResponse(taskCompletionSource, result);
  }

  @Override
  public void setAutomaticDataCollectionEnabled(
      @NonNull String appName,
      @NonNull Boolean enabled,
      GeneratedAndroidFirebaseCore.VoidResult result) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseApp firebaseApp = FirebaseApp.getInstance(appName);
            firebaseApp.setDataCollectionDefaultEnabled(enabled);

            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    listenToVoidResponse(taskCompletionSource, result);
  }

  @Override
  public void setAutomaticResourceManagementEnabled(
      @NonNull String appName,
      @NonNull Boolean enabled,
      GeneratedAndroidFirebaseCore.VoidResult result) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseApp firebaseApp = FirebaseApp.getInstance(appName);
            firebaseApp.setAutomaticResourceManagementEnabled(enabled);

            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    listenToVoidResponse(taskCompletionSource, result);
  }

  @Override
  public void delete(@NonNull String appName, GeneratedAndroidFirebaseCore.VoidResult result) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseApp firebaseApp = FirebaseApp.getInstance(appName);
            try {
              firebaseApp.delete();
            } catch (IllegalStateException appNotFoundException) {
              // Ignore app not found exceptions.
            }

            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    listenToVoidResponse(taskCompletionSource, result);
  }
}
