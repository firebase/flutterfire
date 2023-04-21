// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.auth;

import static io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry.registerPlugin;

import android.app.Activity;
import android.net.Uri;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApiNotAvailableException;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseNetworkException;
import com.google.firebase.FirebaseTooManyRequestsException;
import com.google.firebase.auth.ActionCodeResult;
import com.google.firebase.auth.AuthCredential;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseAuthMultiFactorException;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.MultiFactorInfo;
import com.google.firebase.auth.MultiFactorSession;
import com.google.firebase.auth.OAuthProvider;
import com.google.firebase.auth.PhoneMultiFactorInfo;
import com.google.firebase.auth.SignInMethodQueryResult;
import com.google.firebase.auth.UserProfileChangeRequest;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;

/** Flutter plugin for Firebase Auth. */
public class FlutterFirebaseAuthPlugin
    implements FlutterFirebasePlugin,
        MethodCallHandler,
        FlutterPlugin,
        ActivityAware,
        GeneratedAndroidFirebaseAuth.FirebaseAuthHostApi {

  private static final String METHOD_CHANNEL_NAME = "plugins.flutter.io/firebase_auth";

  // Stores the instances of native AuthCredentials by their hashCode
  static final HashMap<Integer, AuthCredential> authCredentials = new HashMap<>();

  @Nullable private BinaryMessenger messenger;

  private MethodChannel channel;
  public static Activity activity;

  private final Map<EventChannel, StreamHandler> streamHandlers = new HashMap<>();

  private final FlutterFirebaseAuthUser firebaseAuthUser = new FlutterFirebaseAuthUser();
  private final FlutterFirebaseMultiFactor firebaseMultiFactor = new FlutterFirebaseMultiFactor();

  private void initInstance(BinaryMessenger messenger) {
    registerPlugin(METHOD_CHANNEL_NAME, this);
    channel = new MethodChannel(messenger, METHOD_CHANNEL_NAME);
    channel.setMethodCallHandler(this);
    GeneratedAndroidFirebaseAuth.FirebaseAuthHostApi.setup(messenger, this);
    GeneratedAndroidFirebaseAuth.FirebaseAuthUserHostApi.setup(messenger, firebaseAuthUser);
    GeneratedAndroidFirebaseAuth.MultiFactorUserHostApi.setup(messenger, firebaseMultiFactor);
    GeneratedAndroidFirebaseAuth.MultiFactoResolverHostApi.setup(messenger, firebaseMultiFactor);

    this.messenger = messenger;
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    initInstance(binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    channel = null;
    messenger = null;
    GeneratedAndroidFirebaseAuth.FirebaseAuthHostApi.setup(messenger, null);
    GeneratedAndroidFirebaseAuth.FirebaseAuthUserHostApi.setup(messenger, null);
    GeneratedAndroidFirebaseAuth.MultiFactorUserHostApi.setup(null, null);
    GeneratedAndroidFirebaseAuth.MultiFactoResolverHostApi.setup(null, null);

    removeEventListeners();
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
    activity = activityPluginBinding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    activity = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
    activity = activityPluginBinding.getActivity();
  }

  @Override
  public void onDetachedFromActivity() {
    activity = null;
  }

  // Only access activity with this method.
  @Nullable
  private Activity getActivity() {
    return activity;
  }

  static FirebaseAuth getAuthFromPigeon(GeneratedAndroidFirebaseAuth.PigeonFirebaseApp pigeonApp) {
    FirebaseApp app = FirebaseApp.getInstance(pigeonApp.getAppName());
    FirebaseAuth auth = FirebaseAuth.getInstance(app);
    if (pigeonApp.getTenantId() != null) {
      auth.setTenantId(pigeonApp.getTenantId());
    }
    return auth;
  }

  private FirebaseUser getCurrentUser(Map<String, Object> arguments) {
    String appName = (String) Objects.requireNonNull(arguments.get(Constants.APP_NAME));
    FirebaseApp app = FirebaseApp.getInstance(appName);
    return FirebaseAuth.getInstance(app).getCurrentUser();
  }

  @Override
  public void registerIdTokenListener(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseAuth.Result<String> result) {
    try {
      final FirebaseAuth auth = getAuthFromPigeon(app);
      final IdTokenChannelStreamHandler handler = new IdTokenChannelStreamHandler(auth);
      final String name = METHOD_CHANNEL_NAME + "/id-token/" + auth.getApp().getName();
      final EventChannel channel = new EventChannel(messenger, name);
      channel.setStreamHandler(handler);
      streamHandlers.put(channel, handler);
      result.success(name);
    } catch (Exception e) {
      result.error(e);
    }
  }

  @Override
  public void registerAuthStateListener(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseAuth.Result<String> result) {
    try {
      final FirebaseAuth auth = getAuthFromPigeon(app);
      final AuthStateChannelStreamHandler handler = new AuthStateChannelStreamHandler(auth);
      final String name = METHOD_CHANNEL_NAME + "/auth-state/" + auth.getApp().getName();
      final EventChannel channel = new EventChannel(messenger, name);
      channel.setStreamHandler(handler);
      streamHandlers.put(channel, handler);
      result.success(name);
    } catch (Exception e) {
      result.error(e);
    }
  }

  @Override
  public void useEmulator(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull String host,
      @NonNull Long port,
      @NonNull GeneratedAndroidFirebaseAuth.Result<Void> result) {
    try {
      FirebaseAuth firebaseAuth = getAuthFromPigeon(app);
      firebaseAuth.useEmulator(host, port.intValue());
      result.success(null);
    } catch (Exception e) {
      result.error(e);
    }
  }

  @Override
  public void applyActionCode(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull String code,
      @NonNull GeneratedAndroidFirebaseAuth.Result<Void> result) {
    try {
      FirebaseAuth firebaseAuth = getAuthFromPigeon(app);
      Tasks.await(firebaseAuth.applyActionCode(code));
      result.success(null);
    } catch (Exception e) {
      result.error(e);
    }
  }

  @Override
  public void checkActionCode(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull String code,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonActionCodeInfo>
              result) {
    try {
      FirebaseAuth firebaseAuth = getAuthFromPigeon(app);
      ActionCodeResult actionCodeResult = Tasks.await(firebaseAuth.checkActionCode(code));
      result.success(PigeonParser.parseActionCodeResult(actionCodeResult));
    } catch (Exception e) {
      result.error(e);
    }
  }

  @Override
  public void confirmPasswordReset(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull String code,
      @NonNull String newPassword,
      @NonNull GeneratedAndroidFirebaseAuth.Result<Void> result) {
    try {
      FirebaseAuth firebaseAuth = getAuthFromPigeon(app);

      Tasks.await(firebaseAuth.confirmPasswordReset(code, newPassword));
      result.success(null);
    } catch (Exception e) {
      result.error(e);
    }
  }

  @Override
  public void createUserWithEmailAndPassword(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull String email,
      @NonNull String password,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserCredential>
              result) {
    try {
      FirebaseAuth firebaseAuth = getAuthFromPigeon(app);

      AuthResult authResult =
          Tasks.await(firebaseAuth.createUserWithEmailAndPassword(email, password));

      result.success(PigeonParser.parseAuthResult(authResult));
    } catch (Exception e) {
      result.error(e);
    }
  }

  @Override
  public void signInAnonymously(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserCredential>
              result) {
    try {
      FirebaseAuth firebaseAuth = getAuthFromPigeon(app);
      AuthResult authResult = Tasks.await(firebaseAuth.signInAnonymously());
      result.success(PigeonParser.parseAuthResult(authResult));
    } catch (Exception e) {
      result.error(e);
    }
  }

  @Override
  public void signInWithCredential(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull Map<String, Object> input,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserCredential>
              result) {
    try {
      FirebaseAuth firebaseAuth = getAuthFromPigeon(app);
      AuthCredential credential = PigeonParser.getCredential(input);

      if (credential == null) {
        throw FlutterFirebaseAuthPluginException.invalidCredential();
      }
      AuthResult authResult = Tasks.await(firebaseAuth.signInWithCredential(credential));
      result.success(PigeonParser.parseAuthResult(authResult));
    } catch (Exception e) {
      if (e.getCause() instanceof FirebaseAuthMultiFactorException) {
        FlutterFirebaseMultiFactor.handleMultiFactorException(app, result, e);
      } else {
        result.error(e);
      }
    }
  }

  @Override
  public void signInWithCustomToken(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull String token,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserCredential>
              result) {
    try {
      FirebaseAuth firebaseAuth = getAuthFromPigeon(app);
      AuthResult authResult = Tasks.await(firebaseAuth.signInWithCustomToken(token));

      result.success(PigeonParser.parseAuthResult(authResult));
    } catch (Exception e) {
      if (e.getCause() instanceof FirebaseAuthMultiFactorException) {
        FlutterFirebaseMultiFactor.handleMultiFactorException(app, result, e);
      } else {
        result.error(e);
      }
    }
  }

  @Override
  public void signInWithEmailAndPassword(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull String email,
      @NonNull String password,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserCredential>
              result) {
    try {
      FirebaseAuth firebaseAuth = getAuthFromPigeon(app);
      AuthResult authResult = Tasks.await(firebaseAuth.signInWithEmailAndPassword(email, password));

      result.success(PigeonParser.parseAuthResult(authResult));
    } catch (Exception e) {
      if (e.getCause() instanceof FirebaseAuthMultiFactorException) {
        FlutterFirebaseMultiFactor.handleMultiFactorException(app, result, e);
      } else {
        result.error(e);
      }
    }
  }

  @Override
  public void signInWithEmailLink(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull String email,
      @NonNull String emailLink,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserCredential>
              result) {
    try {
      FirebaseAuth firebaseAuth = getAuthFromPigeon(app);
      AuthResult authResult = Tasks.await(firebaseAuth.signInWithEmailLink(email, emailLink));

      result.success(PigeonParser.parseAuthResult(authResult));
    } catch (Exception e) {
      if (e.getCause() instanceof FirebaseAuthMultiFactorException) {
        FlutterFirebaseMultiFactor.handleMultiFactorException(app, result, e);
      } else {
        result.error(e);
      }
    }
  }

  @Override
  public void signInWithProvider(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseAuth.PigeonSignInProvider signInProvider,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserCredential>
              result) {
    try {
      FirebaseAuth firebaseAuth = getAuthFromPigeon(app);

      OAuthProvider.Builder provider = OAuthProvider.newBuilder(signInProvider.getProviderId());
      if (signInProvider.getScopes() != null) {
        provider.setScopes(signInProvider.getScopes());
      }
      if (signInProvider.getCustomParameters() != null) {
        provider.addCustomParameters(signInProvider.getCustomParameters());
      }

      AuthResult authResult =
          Tasks.await(
              firebaseAuth.startActivityForSignInWithProvider(
                  /* activity= */ activity, provider.build()));
      result.success(PigeonParser.parseAuthResult(authResult));
    } catch (Exception e) {
      if (e.getCause() instanceof FirebaseAuthMultiFactorException) {
        FlutterFirebaseMultiFactor.handleMultiFactorException(app, result, e);
      } else {
        result.error(e);
      }
    }
  }

  @Override
  public void signOut(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseAuth.Result<Void> result) {
    try {
      FirebaseAuth firebaseAuth = getAuthFromPigeon(app);
      firebaseAuth.signOut();
      result.success(null);
    } catch (Exception e) {
      result.error(e);
    }
  }

  @Override
  public void fetchSignInMethodsForEmail(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull String email,
      @NonNull GeneratedAndroidFirebaseAuth.Result<List<String>> result) {
    try {
      FirebaseAuth firebaseAuth = getAuthFromPigeon(app);

      SignInMethodQueryResult signInMethods =
          Tasks.await(firebaseAuth.fetchSignInMethodsForEmail(email));

      result.success(signInMethods.getSignInMethods());
    } catch (Exception e) {
      result.error(e);
    }
  }

  @Override
  public void sendPasswordResetEmail(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull String email,
      @Nullable GeneratedAndroidFirebaseAuth.PigeonActionCodeSettings actionCodeSettings,
      @NonNull GeneratedAndroidFirebaseAuth.Result<Void> result) {
    try {
      FirebaseAuth firebaseAuth = getAuthFromPigeon(app);

      if (actionCodeSettings == null) {
        Tasks.await(firebaseAuth.sendPasswordResetEmail(email));
        result.success(null);
        return;
      }

      Tasks.await(
          firebaseAuth.sendPasswordResetEmail(
              email, PigeonParser.getActionCodeSettings(actionCodeSettings)));
      result.success(null);
    } catch (Exception e) {
      result.error(e);
    }
  }

  @Override
  public void sendSignInLinkToEmail(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull String email,
      @NonNull GeneratedAndroidFirebaseAuth.PigeonActionCodeSettings actionCodeSettings,
      @NonNull GeneratedAndroidFirebaseAuth.Result<Void> result) {
    try {
      FirebaseAuth firebaseAuth = getAuthFromPigeon(app);

      Tasks.await(
          firebaseAuth.sendSignInLinkToEmail(
              email, PigeonParser.getActionCodeSettings(actionCodeSettings)));
      result.success(null);
    } catch (Exception e) {
      result.error(e);
    }
  }

  @Override
  public void setLanguageCode(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @Nullable String languageCode,
      @NonNull GeneratedAndroidFirebaseAuth.Result<String> result) {
    try {
      FirebaseAuth firebaseAuth = getAuthFromPigeon(app);

      if (languageCode == null) {
        firebaseAuth.useAppLanguage();
      } else {
        firebaseAuth.setLanguageCode(languageCode);
      }

      result.success(firebaseAuth.getLanguageCode());
    } catch (Exception e) {
      result.error(e);
    }
  }

  @Override
  public void setSettings(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseAuthSettings settings,
      @NonNull GeneratedAndroidFirebaseAuth.Result<Void> result) {
    try {
      FirebaseAuth firebaseAuth = getAuthFromPigeon(app);

      firebaseAuth
          .getFirebaseAuthSettings()
          .setAppVerificationDisabledForTesting(settings.getAppVerificationDisabledForTesting());

      if (settings.getForceRecaptchaFlow() != null) {
        firebaseAuth
            .getFirebaseAuthSettings()
            .forceRecaptchaFlowForTesting(settings.getForceRecaptchaFlow());
      }

      if (settings.getPhoneNumber() != null && settings.getSmsCode() != null) {
        firebaseAuth
            .getFirebaseAuthSettings()
            .setAutoRetrievedSmsCodeForPhoneNumber(
                settings.getPhoneNumber(), settings.getSmsCode());
      }

      result.success(null);
    } catch (Exception e) {
      result.error(e);
    }
  }

  @Override
  public void verifyPasswordResetCode(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull String code,
      @NonNull GeneratedAndroidFirebaseAuth.Result<String> result) {
    try {
      FirebaseAuth firebaseAuth = getAuthFromPigeon(app);

      result.success(Tasks.await(firebaseAuth.verifyPasswordResetCode(code)));
    } catch (Exception e) {
      result.error(e);
    }
  }

  @Override
  public void verifyPhoneNumber(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseAuth.PigeonVerifyPhoneNumberRequest request,
      @NonNull GeneratedAndroidFirebaseAuth.Result<String> result) {
    try {
      String eventChannelName = METHOD_CHANNEL_NAME + "/phone/" + UUID.randomUUID().toString();
      EventChannel channel = new EventChannel(messenger, eventChannelName);

      MultiFactorSession multiFactorSession = null;

      if (request.getMultiFactorSessionId() != null) {
        multiFactorSession =
            FlutterFirebaseMultiFactor.multiFactorSessionMap.get(request.getMultiFactorSessionId());
      }

      final String multiFactorInfoId = request.getMultiFactorInfoId();
      PhoneMultiFactorInfo multiFactorInfo = null;

      if (multiFactorInfoId != null) {
        for (String resolverId : FlutterFirebaseMultiFactor.multiFactorResolverMap.keySet()) {
          for (MultiFactorInfo info :
              FlutterFirebaseMultiFactor.multiFactorResolverMap.get(resolverId).getHints()) {
            if (info.getUid().equals(multiFactorInfoId) && info instanceof PhoneMultiFactorInfo) {
              multiFactorInfo = (PhoneMultiFactorInfo) info;
              break;
            }
          }
        }
      }

      PhoneNumberVerificationStreamHandler handler =
          new PhoneNumberVerificationStreamHandler(
              getActivity(),
              app,
              request,
              multiFactorSession,
              multiFactorInfo,
              credential -> {
                int hashCode = credential.hashCode();
                authCredentials.put(hashCode, credential);
              });

      channel.setStreamHandler(handler);
      streamHandlers.put(channel, handler);

      result.success(eventChannelName);
    } catch (Exception e) {
      result.error(e);
    }
  }

  private Task<Map<String, Object>> updateProfile(Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseUser firebaseUser = getCurrentUser(arguments);

            if (firebaseUser == null) {
              taskCompletionSource.setException(FlutterFirebaseAuthPluginException.noUser());
              return;
            }

            @SuppressWarnings("unchecked")
            Map<String, String> profile =
                (Map<String, String>) Objects.requireNonNull(arguments.get(Constants.PROFILE));
            UserProfileChangeRequest.Builder builder = new UserProfileChangeRequest.Builder();

            if (profile.containsKey(Constants.DISPLAY_NAME)) {
              String displayName = profile.get(Constants.DISPLAY_NAME);
              builder.setDisplayName(displayName);
            }

            if (profile.containsKey(Constants.PHOTO_URL)) {
              String photoURL = profile.get(Constants.PHOTO_URL);
              if (photoURL != null) {
                builder.setPhotoUri(Uri.parse(photoURL));
              } else {
                builder.setPhotoUri(null);
              }
            }

            Tasks.await(firebaseUser.updateProfile(builder.build()));
            Tasks.await(firebaseUser.reload());
            taskCompletionSource.setResult(parseFirebaseUser(firebaseUser));
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> verifyBeforeUpdateEmail(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseUser firebaseUser = getCurrentUser(arguments);

            if (firebaseUser == null) {
              taskCompletionSource.setException(FlutterFirebaseAuthPluginException.noUser());
            }

            String newEmail = (String) Objects.requireNonNull(arguments.get(Constants.NEW_EMAIL));
            Object rawActionCodeSettings = arguments.get(Constants.ACTION_CODE_SETTINGS);

            if (rawActionCodeSettings == null) {
              Tasks.await(firebaseUser.verifyBeforeUpdateEmail(newEmail));
              taskCompletionSource.setResult(null);
              return;
            }

            @SuppressWarnings("unchecked")
            Map<String, Object> actionCodeSettings = (Map<String, Object>) rawActionCodeSettings;

            Tasks.await(
                firebaseUser.verifyBeforeUpdateEmail(
                    newEmail, getActionCodeSettings(actionCodeSettings)));
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    final Task<?> methodCallTask;

    switch (call.method) {
      case "User#updateProfile":
        methodCallTask = updateProfile(call.arguments());
        break;
      case "User#verifyBeforeUpdateEmail":
        methodCallTask = verifyBeforeUpdateEmail(call.arguments());
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
            result.error(
                "firebase_auth",
                exception != null ? exception.getMessage() : null,
                getExceptionDetails(exception));
          }
        });
  }

  @Override
  public Task<Map<String, Object>> getPluginConstantsForFirebaseApp(FirebaseApp firebaseApp) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            Map<String, Object> constants = new HashMap<>();
            FirebaseAuth firebaseAuth = FirebaseAuth.getInstance(firebaseApp);
            FirebaseUser firebaseUser = firebaseAuth.getCurrentUser();
            String languageCode = firebaseAuth.getLanguageCode();

            Map<String, Object> user =
                firebaseUser == null ? null : parseFirebaseUser(firebaseUser);

            if (languageCode != null) {
              constants.put("APP_LANGUAGE_CODE", languageCode);
            }

            if (user != null) {
              constants.put("APP_CURRENT_USER", user);
            }

            taskCompletionSource.setResult(constants);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  static Map<String, Object> getExceptionDetails(Exception exception) {
    Map<String, Object> details = new HashMap<>();

    if (exception == null) {
      return details;
    }

    FlutterFirebaseAuthPluginException authException = null;

    if (exception instanceof FirebaseAuthException) {
      authException = new FlutterFirebaseAuthPluginException(exception, exception.getCause());
    } else if (exception.getCause() != null
        && exception.getCause() instanceof FirebaseAuthException) {
      authException =
          new FlutterFirebaseAuthPluginException(
              (FirebaseAuthException) exception.getCause(),
              exception.getCause().getCause() != null
                  ? exception.getCause().getCause()
                  : exception.getCause());
    } else if (exception instanceof FlutterFirebaseAuthPluginException) {
      authException = (FlutterFirebaseAuthPluginException) exception;
    }

    if (authException != null) {
      details.put("code", authException.getCode());
      details.put("message", authException.getMessage());
      details.put("additionalData", authException.getAdditionalData());
      return details;
    }

    if (exception instanceof FirebaseNetworkException
        || (exception.getCause() != null
            && exception.getCause() instanceof FirebaseNetworkException)) {
      details.put("code", "network-request-failed");
      details.put(
          "message",
          "A network error (such as timeout, interrupted connection or unreachable host) has occurred.");
      details.put("additionalData", new HashMap<>());
      return details;
    }

    if (exception instanceof FirebaseApiNotAvailableException
        || (exception.getCause() != null
            && exception.getCause() instanceof FirebaseApiNotAvailableException)) {
      details.put("code", "api-not-available");
      details.put("message", "The requested API is not available.");
      details.put("additionalData", new HashMap<>());
      return details;
    }

    if (exception instanceof FirebaseTooManyRequestsException
        || (exception.getCause() != null
            && exception.getCause() instanceof FirebaseTooManyRequestsException)) {
      details.put("code", "too-many-requests");
      details.put(
          "message",
          "We have blocked all requests from this device due to unusual activity. Try again later.");
      details.put("additionalData", new HashMap<>());
      return details;
    }

    // Manual message overrides to match other platforms.
    if (exception.getMessage() != null
        && exception
            .getMessage()
            .startsWith("Cannot create PhoneAuthCredential without either verificationProof")) {
      details.put("code", "invalid-verification-id");
      details.put(
          "message", "The verification ID used to create the phone auth credential is invalid.");
      details.put("additionalData", new HashMap<>());
      return details;
    }

    return details;
  }

  @Override
  public Task<Void> didReinitializeFirebaseCore() {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            removeEventListeners();
            authCredentials.clear();
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private void removeEventListeners() {
    for (EventChannel eventChannel : streamHandlers.keySet()) {
      StreamHandler streamHandler = streamHandlers.get(eventChannel);
      if (streamHandler != null) {
        streamHandler.onCancel(null);
      }
      eventChannel.setStreamHandler(null);
    }
    streamHandlers.clear();
  }
}
