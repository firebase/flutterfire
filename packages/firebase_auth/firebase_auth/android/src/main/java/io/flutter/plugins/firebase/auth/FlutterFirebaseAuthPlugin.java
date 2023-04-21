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
import com.google.firebase.auth.ActionCodeEmailInfo;
import com.google.firebase.auth.ActionCodeInfo;
import com.google.firebase.auth.ActionCodeResult;
import com.google.firebase.auth.ActionCodeSettings;
import com.google.firebase.auth.AuthCredential;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseAuthMultiFactorException;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.GetTokenResult;
import com.google.firebase.auth.MultiFactor;
import com.google.firebase.auth.MultiFactorAssertion;
import com.google.firebase.auth.MultiFactorInfo;
import com.google.firebase.auth.MultiFactorResolver;
import com.google.firebase.auth.MultiFactorSession;
import com.google.firebase.auth.OAuthProvider;
import com.google.firebase.auth.PhoneAuthCredential;
import com.google.firebase.auth.PhoneAuthProvider;
import com.google.firebase.auth.PhoneMultiFactorGenerator;
import com.google.firebase.auth.PhoneMultiFactorInfo;
import com.google.firebase.auth.SignInMethodQueryResult;
import com.google.firebase.auth.UserProfileChangeRequest;
import com.google.firebase.internal.api.FirebaseNoSignedInUserException;
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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.concurrent.ExecutionException;

/** Flutter plugin for Firebase Auth. */
public class FlutterFirebaseAuthPlugin
    implements FlutterFirebasePlugin,
        MethodCallHandler,
        FlutterPlugin,
        ActivityAware,
        GeneratedAndroidFirebaseAuth.FirebaseAuthHostApi,
        GeneratedAndroidFirebaseAuth.MultiFactorUserHostApi,
        GeneratedAndroidFirebaseAuth.MultiFactoResolverHostApi {

  private static final String METHOD_CHANNEL_NAME = "plugins.flutter.io/firebase_auth";

  // Stores the instances of native AuthCredentials by their hashCode
  static final HashMap<Integer, AuthCredential> authCredentials = new HashMap<>();

  @Nullable private BinaryMessenger messenger;

  private MethodChannel channel;
  private Activity activity;

  private final Map<EventChannel, StreamHandler> streamHandlers = new HashMap<>();

  private void initInstance(BinaryMessenger messenger) {
    registerPlugin(METHOD_CHANNEL_NAME, this);
    channel = new MethodChannel(messenger, METHOD_CHANNEL_NAME);
    channel.setMethodCallHandler(this);
    GeneratedAndroidFirebaseAuth.MultiFactorUserHostApi.setup(messenger, this);
    GeneratedAndroidFirebaseAuth.MultiFactoResolverHostApi.setup(messenger, this);

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
    GeneratedAndroidFirebaseAuth.MultiFactorUserHostApi.setup(binding.getBinaryMessenger(), null);
    GeneratedAndroidFirebaseAuth.MultiFactoResolverHostApi.setup(
        binding.getBinaryMessenger(), null);

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

  static FirebaseAuth getAuth(Map<String, Object> arguments) {
    String appName = (String) Objects.requireNonNull(arguments.get(Constants.APP_NAME));
    FirebaseApp app = FirebaseApp.getInstance(appName);
    FirebaseAuth auth = FirebaseAuth.getInstance(app);
    String tenantId = (String) arguments.get(Constants.TENANT_ID);
    if (tenantId != null) {
      auth.setTenantId(tenantId);
    }
    return auth;
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

  private FirebaseUser getCurrentUser(String appName) {
    FirebaseApp app = FirebaseApp.getInstance(appName);
    return FirebaseAuth.getInstance(app).getCurrentUser();
  }

  private ActionCodeSettings getActionCodeSettings(
      @NonNull Map<String, Object> actionCodeSettingsMap) {
    ActionCodeSettings.Builder builder = ActionCodeSettings.newBuilder();

    builder.setUrl((String) Objects.requireNonNull(actionCodeSettingsMap.get(Constants.URL)));

    if (actionCodeSettingsMap.get(Constants.DYNAMIC_LINK_DOMAIN) != null) {
      builder.setDynamicLinkDomain(
          (String)
              Objects.requireNonNull(actionCodeSettingsMap.get(Constants.DYNAMIC_LINK_DOMAIN)));
    }

    if (actionCodeSettingsMap.get(Constants.HANDLE_CODE_IN_APP) != null) {
      builder.setHandleCodeInApp(
          (Boolean)
              Objects.requireNonNull(actionCodeSettingsMap.get(Constants.HANDLE_CODE_IN_APP)));
    }

    if (actionCodeSettingsMap.get(Constants.ANDROID) != null) {
      @SuppressWarnings("unchecked")
      Map<String, Object> android =
          (Map<String, Object>)
              Objects.requireNonNull(actionCodeSettingsMap.get(Constants.ANDROID));

      boolean installIfNotAvailable = false;
      if (android.get(Constants.INSTALL_APP) != null) {
        installIfNotAvailable =
            (Boolean) Objects.requireNonNull(android.get(Constants.INSTALL_APP));
      }
      String minimumVersion = null;
      if (android.get(Constants.MINIMUM_VERSION) != null) {
        minimumVersion = (String) android.get(Constants.MINIMUM_VERSION);
      }

      builder.setAndroidPackageName(
          (String) Objects.requireNonNull(android.get(Constants.PACKAGE_NAME)),
          installIfNotAvailable,
          minimumVersion);
    }

    if (actionCodeSettingsMap.get(Constants.IOS) != null) {
      @SuppressWarnings("unchecked")
      Map<String, Object> iOS =
          (Map<String, Object>) Objects.requireNonNull(actionCodeSettingsMap.get(Constants.IOS));
      builder.setIOSBundleId((String) Objects.requireNonNull(iOS.get(Constants.BUNDLE_ID)));
    }

    return builder.build();
  }

  private Map<String, Object> parseTokenResult(@NonNull GetTokenResult tokenResult) {
    Map<String, Object> output = new HashMap<>();

    output.put(Constants.AUTH_TIMESTAMP, tokenResult.getAuthTimestamp() * 1000);
    output.put(Constants.CLAIMS, tokenResult.getClaims());
    output.put(Constants.EXPIRATION_TIMESTAMP, tokenResult.getExpirationTimestamp() * 1000);
    output.put(Constants.ISSUED_AT_TIMESTAMP, tokenResult.getIssuedAtTimestamp() * 1000);
    output.put(Constants.SIGN_IN_PROVIDER, tokenResult.getSignInProvider());
    output.put(Constants.SIGN_IN_SECOND_FACTOR, tokenResult.getSignInSecondFactor());
    output.put(Constants.TOKEN, tokenResult.getToken());

    return output;
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

  private GeneratedAndroidFirebaseAuth.PigeonActionCodeInfo parseActionCodeResult(
      @NonNull ActionCodeResult actionCodeResult) {
    GeneratedAndroidFirebaseAuth.PigeonActionCodeInfo.Builder builder =
        new GeneratedAndroidFirebaseAuth.PigeonActionCodeInfo.Builder();
    GeneratedAndroidFirebaseAuth.PigeonActionCodeInfoData.Builder builderData =
        new GeneratedAndroidFirebaseAuth.PigeonActionCodeInfoData.Builder();

    int operation = actionCodeResult.getOperation();

    switch (operation) {
      case ActionCodeResult.PASSWORD_RESET:
        builder.setOperation(GeneratedAndroidFirebaseAuth.ActionCodeInfoOperation.PASSWORD_RESET);
        break;
      case ActionCodeResult.VERIFY_EMAIL:
        builder.setOperation(GeneratedAndroidFirebaseAuth.ActionCodeInfoOperation.VERIFY_EMAIL);
        break;
      case ActionCodeResult.RECOVER_EMAIL:
        builder.setOperation(GeneratedAndroidFirebaseAuth.ActionCodeInfoOperation.RECOVER_EMAIL);
        break;
      case ActionCodeResult.SIGN_IN_WITH_EMAIL_LINK:
        builder.setOperation(GeneratedAndroidFirebaseAuth.ActionCodeInfoOperation.EMAIL_SIGN_IN);
        break;
      case ActionCodeResult.VERIFY_BEFORE_CHANGE_EMAIL:
        builder.setOperation(
            GeneratedAndroidFirebaseAuth.ActionCodeInfoOperation.VERIFY_AND_CHANGE_EMAIL);
        break;
      case ActionCodeResult.REVERT_SECOND_FACTOR_ADDITION:
        builder.setOperation(
            GeneratedAndroidFirebaseAuth.ActionCodeInfoOperation.REVERT_SECOND_FACTOR_ADDITION);
        break;
    }

    ActionCodeInfo actionCodeInfo = actionCodeResult.getInfo();

    if (actionCodeInfo != null && operation == ActionCodeResult.VERIFY_EMAIL
        || operation == ActionCodeResult.PASSWORD_RESET) {
      builderData.setEmail(actionCodeInfo.getEmail());
    } else if (operation == ActionCodeResult.RECOVER_EMAIL
        || operation == ActionCodeResult.VERIFY_BEFORE_CHANGE_EMAIL) {
      ActionCodeEmailInfo actionCodeEmailInfo =
          (ActionCodeEmailInfo) Objects.requireNonNull(actionCodeInfo);
      builderData.setEmail(actionCodeEmailInfo.getEmail());
      builderData.setPreviousEmail(actionCodeEmailInfo.getPreviousEmail());
    }

    builder.setData(builderData.build());

    return builder.build();
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
      result.success(parseActionCodeResult(actionCodeResult));
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
        handleMultiFactorException(app, result, e);
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
        handleMultiFactorException(app, result, e);
      } else {
        result.error(e);
      }
    }
  }

  private Task<Map<String, Object>> fetchSignInMethodsForEmail(Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseAuth firebaseAuth = getAuth(arguments);
            String email = (String) Objects.requireNonNull(arguments.get(Constants.EMAIL));

            SignInMethodQueryResult result =
                Tasks.await(firebaseAuth.fetchSignInMethodsForEmail(email));

            Map<String, Object> output = new HashMap<>();
            output.put(Constants.PROVIDERS, result.getSignInMethods());

            taskCompletionSource.setResult(output);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> sendPasswordResetEmail(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseAuth firebaseAuth = getAuth(arguments);
            String email = (String) Objects.requireNonNull(arguments.get(Constants.EMAIL));
            Object rawActionCodeSettings = arguments.get(Constants.ACTION_CODE_SETTINGS);

            if (rawActionCodeSettings == null) {
              Tasks.await(firebaseAuth.sendPasswordResetEmail(email));
              taskCompletionSource.setResult(null);
              return;
            }

            @SuppressWarnings("unchecked")
            Map<String, Object> actionCodeSettings = (Map<String, Object>) rawActionCodeSettings;

            Tasks.await(
                firebaseAuth.sendPasswordResetEmail(
                    email, getActionCodeSettings(actionCodeSettings)));
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> sendSignInLinkToEmail(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseAuth firebaseAuth = getAuth(arguments);
            String email = (String) Objects.requireNonNull(arguments.get(Constants.EMAIL));

            @SuppressWarnings("unchecked")
            Map<String, Object> actionCodeSettings =
                (Map<String, Object>)
                    Objects.requireNonNull(arguments.get(Constants.ACTION_CODE_SETTINGS));

            Tasks.await(
                firebaseAuth.sendSignInLinkToEmail(
                    email, getActionCodeSettings(actionCodeSettings)));
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Map<String, Object>> setLanguageCode(Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseAuth firebaseAuth = getAuth(arguments);
            String languageCode = (String) arguments.get(Constants.LANGUAGE_CODE);

            if (languageCode == null) {
              firebaseAuth.useAppLanguage();
            } else {
              firebaseAuth.setLanguageCode(languageCode);
            }

            taskCompletionSource.setResult(
                new HashMap<String, Object>() {
                  {
                    put(Constants.LANGUAGE_CODE, firebaseAuth.getLanguageCode());
                  }
                });
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> setSettings(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseAuth firebaseAuth = getAuth(arguments);
            Boolean appVerificationDisabledForTesting =
                (Boolean) arguments.get(Constants.APP_VERIFICATION_DISABLED_FOR_TESTING);
            Boolean forceRecaptchaFlow = (Boolean) arguments.get(Constants.FORCE_RECAPTCHA_FLOW);
            String phoneNumber = (String) arguments.get(Constants.PHONE_NUMBER);
            String smsCode = (String) arguments.get(Constants.SMS_CODE);

            if (appVerificationDisabledForTesting != null) {
              firebaseAuth
                  .getFirebaseAuthSettings()
                  .setAppVerificationDisabledForTesting(appVerificationDisabledForTesting);
            }

            if (forceRecaptchaFlow != null) {
              firebaseAuth
                  .getFirebaseAuthSettings()
                  .forceRecaptchaFlowForTesting(forceRecaptchaFlow);
            }

            if (phoneNumber != null && smsCode != null) {
              firebaseAuth
                  .getFirebaseAuthSettings()
                  .setAutoRetrievedSmsCodeForPhoneNumber(phoneNumber, smsCode);
            }

            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Map<String, Object>> signInWithEmailAndPassword(Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseAuth firebaseAuth = getAuth(arguments);
            String email = (String) Objects.requireNonNull(arguments.get(Constants.EMAIL));
            String password = (String) Objects.requireNonNull(arguments.get(Constants.PASSWORD));

            AuthResult authResult =
                Tasks.await(firebaseAuth.signInWithEmailAndPassword(email, password));

            taskCompletionSource.setResult(parseAuthResult(authResult));
          } catch (Exception e) {
            if (e.getCause() instanceof FirebaseAuthMultiFactorException) {
              handleMultiFactorException(arguments, taskCompletionSource, e);
            } else {
              taskCompletionSource.setException(e);
            }
          }
        });

    return taskCompletionSource.getTask();
  }

  private void handleMultiFactorException(
      GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserCredential> result,
      Exception e) {
    final FirebaseAuthMultiFactorException multiFactorException =
        (FirebaseAuthMultiFactorException) e.getCause();
    Map<String, Object> output = new HashMap<>();

    assert multiFactorException != null;
    MultiFactorResolver multiFactorResolver = multiFactorException.getResolver();
    final List<MultiFactorInfo> hints = multiFactorResolver.getHints();

    final MultiFactorSession session = multiFactorResolver.getSession();
    final String sessionId = UUID.randomUUID().toString();
    multiFactorSessionMap.put(sessionId, session);

    final String resolverId = UUID.randomUUID().toString();
    multiFactorResolverMap.put(resolverId, multiFactorResolver);

    final List<List<Object>> pigeonHints = multiFactorInfoToMap(hints);

    output.put(Constants.APP_NAME, getAuthFromPigeon(app).getApp().getName());

    output.put(Constants.MULTI_FACTOR_HINTS, pigeonHints);

    output.put(Constants.MULTI_FACTOR_SESSION_ID, sessionId);
    output.put(Constants.MULTI_FACTOR_RESOLVER_ID, resolverId);

    result.error(
        new FlutterFirebaseAuthPluginException(
            multiFactorException.getErrorCode(),
            multiFactorException.getLocalizedMessage(),
            output));
  }

  private List<GeneratedAndroidFirebaseAuth.PigeonMultiFactorInfo> multiFactorInfoToPigeon(
      List<MultiFactorInfo> hints) {
    List<GeneratedAndroidFirebaseAuth.PigeonMultiFactorInfo> pigeonHints = new ArrayList<>();
    for (MultiFactorInfo info : hints) {
      if (info instanceof PhoneMultiFactorInfo) {
        pigeonHints.add(
            new GeneratedAndroidFirebaseAuth.PigeonMultiFactorInfo.Builder()
                .setPhoneNumber(((PhoneMultiFactorInfo) info).getPhoneNumber())
                .setDisplayName(info.getDisplayName())
                .setEnrollmentTimestamp((double) info.getEnrollmentTimestamp())
                .setUid(info.getUid())
                .setFactorId(info.getFactorId())
                .build());

      } else {
        pigeonHints.add(
            new GeneratedAndroidFirebaseAuth.PigeonMultiFactorInfo.Builder()
                .setDisplayName(info.getDisplayName())
                .setEnrollmentTimestamp((double) info.getEnrollmentTimestamp())
                .setUid(info.getUid())
                .setFactorId(info.getFactorId())
                .build());
      }
    }
    return pigeonHints;
  }

  private List<List<Object>> multiFactorInfoToMap(List<MultiFactorInfo> hints) {
    List<List<Object>> pigeonHints = new ArrayList<>();
    for (GeneratedAndroidFirebaseAuth.PigeonMultiFactorInfo info : multiFactorInfoToPigeon(hints)) {
      pigeonHints.add(info.toList());
    }
    return pigeonHints;
  }

  private Task<Map<String, Object>> signInWithEmailLink(Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseAuth firebaseAuth = getAuth(arguments);
            String email = (String) Objects.requireNonNull(arguments.get(Constants.EMAIL));
            String emailLink = (String) Objects.requireNonNull(arguments.get(Constants.EMAIL_LINK));

            AuthResult authResult = Tasks.await(firebaseAuth.signInWithEmailLink(email, emailLink));
            taskCompletionSource.setResult(parseAuthResult(authResult));
          } catch (Exception e) {
            if (e.getCause() instanceof FirebaseAuthMultiFactorException) {
              handleMultiFactorException(arguments, taskCompletionSource, e);
            } else {
              taskCompletionSource.setException(e);
            }
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> signOut(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseAuth firebaseAuth = getAuth(arguments);
            firebaseAuth.signOut();
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Map<String, Object>> verifyPasswordResetCode(Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseAuth firebaseAuth = getAuth(arguments);
            String code = (String) Objects.requireNonNull(arguments.get(Constants.CODE));

            Map<String, Object> output = new HashMap<>();
            output.put(Constants.EMAIL, Tasks.await(firebaseAuth.verifyPasswordResetCode(code)));

            taskCompletionSource.setResult(output);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<String> verifyPhoneNumber(Map<String, Object> arguments) {
    TaskCompletionSource<String> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            String eventChannelName =
                METHOD_CHANNEL_NAME + "/phone/" + UUID.randomUUID().toString();
            EventChannel channel = new EventChannel(messenger, eventChannelName);

            final String multiFactorSessionId =
                (String) arguments.get(Constants.MULTI_FACTOR_SESSION_ID);
            MultiFactorSession multiFactorSession = null;

            if (multiFactorSessionId != null) {
              multiFactorSession = multiFactorSessionMap.get(multiFactorSessionId);
            }

            final String multiFactorInfoId = (String) arguments.get(Constants.MULTI_FACTOR_INFO);
            PhoneMultiFactorInfo multiFactorInfo = null;

            if (multiFactorInfoId != null) {
              for (String resolverId : multiFactorResolverMap.keySet()) {
                for (MultiFactorInfo info : multiFactorResolverMap.get(resolverId).getHints()) {
                  if (info.getUid().equals(multiFactorInfoId)
                      && info instanceof PhoneMultiFactorInfo) {
                    multiFactorInfo = (PhoneMultiFactorInfo) info;
                    break;
                  }
                }
              }
            }

            PhoneNumberVerificationStreamHandler handler =
                new PhoneNumberVerificationStreamHandler(
                    getActivity(),
                    arguments,
                    multiFactorSession,
                    multiFactorInfo,
                    credential -> {
                      int hashCode = credential.hashCode();
                      authCredentials.put(hashCode, credential);
                    });

            channel.setStreamHandler(handler);
            streamHandlers.put(channel, handler);

            taskCompletionSource.setResult(eventChannelName);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> deleteUser(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseUser firebaseUser = getCurrentUser(arguments);

            if (firebaseUser == null) {
              taskCompletionSource.setException(FlutterFirebaseAuthPluginException.noUser());
              return;
            }

            Tasks.await(firebaseUser.delete());
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Map<String, Object>> getIdToken(Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseUser firebaseUser = getCurrentUser(arguments);
            Boolean forceRefresh =
                (Boolean) Objects.requireNonNull(arguments.get(Constants.FORCE_REFRESH));
            Boolean tokenOnly =
                (Boolean) Objects.requireNonNull(arguments.get(Constants.TOKEN_ONLY));

            if (firebaseUser == null) {
              taskCompletionSource.setException(FlutterFirebaseAuthPluginException.noUser());
              return;
            }

            GetTokenResult tokenResult = Tasks.await(firebaseUser.getIdToken(forceRefresh));

            if (tokenOnly) {
              Map<String, Object> output = new HashMap<>();
              output.put("token", tokenResult.getToken());

              taskCompletionSource.setResult(output);
            } else {
              taskCompletionSource.setResult(parseTokenResult(tokenResult));
            }

          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Map<String, Object>> linkUserWithCredential(Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseUser firebaseUser = getCurrentUser(arguments);
            AuthCredential credential = getCredential(arguments);

            if (firebaseUser == null) {
              taskCompletionSource.setException(FlutterFirebaseAuthPluginException.noUser());
              return;
            }

            if (credential == null) {
              taskCompletionSource.setException(
                  FlutterFirebaseAuthPluginException.invalidCredential());
              return;
            }

            AuthResult authResult;

            authResult = Tasks.await(firebaseUser.linkWithCredential(credential));

            taskCompletionSource.setResult(parseAuthResult(authResult));
          } catch (Exception e) {
            if (e.getCause() instanceof FirebaseAuthMultiFactorException) {
              handleMultiFactorException(arguments, taskCompletionSource, e);
              return;
            }
            String message = e.getMessage();

            if (message != null
                && message.contains("User has already been linked to the given provider.")) {
              taskCompletionSource.setException(
                  FlutterFirebaseAuthPluginException.alreadyLinkedProvider());
              return;
            }

            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Map<String, Object>> reauthenticateUserWithCredential(
      Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseUser firebaseUser = getCurrentUser(arguments);
            AuthCredential credential = getCredential(arguments);

            if (firebaseUser == null) {
              taskCompletionSource.setException(FlutterFirebaseAuthPluginException.noUser());
              return;
            }

            if (credential == null) {
              taskCompletionSource.setException(
                  FlutterFirebaseAuthPluginException.invalidCredential());
              return;
            }

            AuthResult authResult =
                Tasks.await(firebaseUser.reauthenticateAndRetrieveData(credential));
            taskCompletionSource.setResult(parseAuthResult(authResult));
          } catch (Exception e) {
            if (e.getCause() instanceof FirebaseAuthMultiFactorException) {
              handleMultiFactorException(arguments, taskCompletionSource, e);
            } else {
              taskCompletionSource.setException(e);
            }
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Map<String, Object>> reloadUser(Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseUser firebaseUser = getCurrentUser(arguments);

            if (firebaseUser == null) {
              taskCompletionSource.setException(FlutterFirebaseAuthPluginException.noUser());
              return;
            }

            // Wait for the user to reload, and send back the updated user
            Tasks.await(firebaseUser.reload());

            taskCompletionSource.setResult(parseFirebaseUser(getCurrentUser(arguments)));
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> sendEmailVerification(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseUser firebaseUser = getCurrentUser(arguments);

            if (firebaseUser == null) {
              taskCompletionSource.setException(FlutterFirebaseAuthPluginException.noUser());
              return;
            }

            Object rawActionCodeSettings = arguments.get(Constants.ACTION_CODE_SETTINGS);
            if (rawActionCodeSettings == null) {
              Tasks.await(firebaseUser.sendEmailVerification());
              taskCompletionSource.setResult(null);
              return;
            }

            @SuppressWarnings("unchecked")
            Map<String, Object> actionCodeSettings = (Map<String, Object>) rawActionCodeSettings;

            Tasks.await(
                firebaseUser.sendEmailVerification(getActionCodeSettings(actionCodeSettings)));
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Map<String, Object>> unlinkUserProvider(Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseUser firebaseUser = getCurrentUser(arguments);

            if (firebaseUser == null) {
              taskCompletionSource.setException(FlutterFirebaseAuthPluginException.noUser());
              return;
            }

            String providerId =
                (String) Objects.requireNonNull(arguments.get(Constants.PROVIDER_ID));

            AuthResult result = Tasks.await(firebaseUser.unlink(providerId));
            taskCompletionSource.setResult(parseAuthResult(result));

          } catch (ExecutionException e) {
            // If the provider ID was not found an ExecutionException is thrown.
            // On web, this is automatically handled, so we catch the specific exception here
            // to ensure consistency.
            taskCompletionSource.setException(FlutterFirebaseAuthPluginException.noSuchProvider());
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Map<String, Object>> updateEmail(Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseUser firebaseUser = getCurrentUser(arguments);

            if (firebaseUser == null) {
              taskCompletionSource.setException(FlutterFirebaseAuthPluginException.noUser());
              return;
            }

            String newEmail = (String) Objects.requireNonNull(arguments.get(Constants.NEW_EMAIL));
            Tasks.await(firebaseUser.updateEmail(newEmail));
            Tasks.await(firebaseUser.reload());
            taskCompletionSource.setResult(parseFirebaseUser(firebaseUser));
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Map<String, Object>> updatePassword(Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseUser firebaseUser = getCurrentUser(arguments);

            if (firebaseUser == null) {
              taskCompletionSource.setException(FlutterFirebaseAuthPluginException.noUser());
              return;
            }

            String newPassword =
                (String) Objects.requireNonNull(arguments.get(Constants.NEW_PASSWORD));
            Tasks.await(firebaseUser.updatePassword(newPassword));
            Tasks.await(firebaseUser.reload());
            taskCompletionSource.setResult(parseFirebaseUser(firebaseUser));
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Map<String, Object>> updatePhoneNumber(Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseUser firebaseUser = getCurrentUser(arguments);

            if (firebaseUser == null) {
              taskCompletionSource.setException(FlutterFirebaseAuthPluginException.noUser());
              return;
            }

            PhoneAuthCredential phoneAuthCredential =
                (PhoneAuthCredential) getCredential(arguments);

            if (phoneAuthCredential == null) {
              taskCompletionSource.setException(
                  FlutterFirebaseAuthPluginException.invalidCredential());
              return;
            }

            Tasks.await(firebaseUser.updatePhoneNumber(phoneAuthCredential));
            Tasks.await(firebaseUser.reload());
            taskCompletionSource.setResult(parseFirebaseUser(firebaseUser));
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
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
      case "Auth#fetchSignInMethodsForEmail":
        methodCallTask = fetchSignInMethodsForEmail(call.arguments());
        break;
      case "Auth#sendPasswordResetEmail":
        methodCallTask = sendPasswordResetEmail(call.arguments());
        break;
      case "Auth#sendSignInLinkToEmail":
        methodCallTask = sendSignInLinkToEmail(call.arguments());
        break;
      case "Auth#setLanguageCode":
        methodCallTask = setLanguageCode(call.arguments());
        break;
      case "Auth#setSettings":
        methodCallTask = setSettings(call.arguments());
        break;
      case "Auth#signInWithEmailAndPassword":
        methodCallTask = signInWithEmailAndPassword(call.arguments());
        break;
      case "Auth#signInWithEmailLink":
        methodCallTask = signInWithEmailLink(call.arguments());
        break;
      case "Auth#signOut":
        methodCallTask = signOut(call.arguments());
        break;
      case "Auth#verifyPasswordResetCode":
        methodCallTask = verifyPasswordResetCode(call.arguments());
        break;
      case "Auth#verifyPhoneNumber":
        methodCallTask = verifyPhoneNumber(call.arguments());
        break;
      case "Auth#signInWithProvider":
        methodCallTask = signInWithProvider(call.arguments());
        break;
      case "User#linkWithProvider":
        methodCallTask = startActivityForLinkWithProvider(call.arguments());
        break;
      case "User#reauthenticateWithProvider":
        methodCallTask = reauthenticateWithProvider(call.arguments());
        break;
      case "User#delete":
        methodCallTask = deleteUser(call.arguments());
        break;
      case "User#getIdToken":
        methodCallTask = getIdToken(call.arguments());
        break;
      case "User#linkWithCredential":
        methodCallTask = linkUserWithCredential(call.arguments());
        break;
      case "User#reauthenticateUserWithCredential":
        methodCallTask = reauthenticateUserWithCredential(call.arguments());
        break;
      case "User#reload":
        methodCallTask = reloadUser(call.arguments());
        break;
      case "User#sendEmailVerification":
        methodCallTask = sendEmailVerification(call.arguments());
        break;
      case "User#unlink":
        methodCallTask = unlinkUserProvider(call.arguments());
        break;
      case "User#updateEmail":
        methodCallTask = updateEmail(call.arguments());
        break;
      case "User#updatePassword":
        methodCallTask = updatePassword(call.arguments());
        break;
      case "User#updatePhoneNumber":
        methodCallTask = updatePhoneNumber(call.arguments());
        break;
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

  private Task<Map<String, Object>> startActivityForLinkWithProvider(
      Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseUser firebaseUser = getCurrentUser(arguments);

            String providerId =
                (String) Objects.requireNonNull(arguments.get(Constants.SIGN_IN_PROVIDER));
            @SuppressWarnings("unchecked")
            List<String> scopes = (List<String>) arguments.get(Constants.SIGN_IN_PROVIDER_SCOPE);
            @SuppressWarnings("unchecked")
            Map<String, String> customParameters =
                (Map<String, String>) arguments.get(Constants.SIGN_IN_PROVIDER_CUSTOM_PARAMETERS);

            OAuthProvider.Builder provider = OAuthProvider.newBuilder(providerId);
            if (scopes != null) {
              provider.setScopes(scopes);
            }
            if (customParameters != null) {
              provider.addCustomParameters(customParameters);
            }

            AuthResult authResult =
                Tasks.await(
                    firebaseUser.startActivityForLinkWithProvider(
                        /* activity= */ activity, provider.build()));
            taskCompletionSource.setResult(parseAuthResult(authResult));
          } catch (Exception e) {
            if (e.getCause() instanceof FirebaseAuthMultiFactorException) {
              handleMultiFactorException(arguments, taskCompletionSource, e);
            } else {
              taskCompletionSource.setException(e);
            }
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Map<String, Object>> reauthenticateWithProvider(Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseUser firebaseUser = getCurrentUser(arguments);

            String providerId =
                (String) Objects.requireNonNull(arguments.get(Constants.SIGN_IN_PROVIDER));
            @SuppressWarnings("unchecked")
            List<String> scopes = (List<String>) arguments.get(Constants.SIGN_IN_PROVIDER_SCOPE);
            @SuppressWarnings("unchecked")
            Map<String, String> customParameters =
                (Map<String, String>) arguments.get(Constants.SIGN_IN_PROVIDER_CUSTOM_PARAMETERS);

            OAuthProvider.Builder provider = OAuthProvider.newBuilder(providerId);
            if (scopes != null) {
              provider.setScopes(scopes);
            }
            if (customParameters != null) {
              provider.addCustomParameters(customParameters);
            }

            AuthResult authResult =
                Tasks.await(
                    firebaseUser.startActivityForReauthenticateWithProvider(
                        /* activity= */ activity, provider.build()));
            taskCompletionSource.setResult(parseAuthResult(authResult));
          } catch (Exception e) {
            if (e.getCause() instanceof FirebaseAuthMultiFactorException) {
              handleMultiFactorException(arguments, taskCompletionSource, e);
            } else {
              taskCompletionSource.setException(e);
            }
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Map<String, Object>> signInWithProvider(Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseAuth firebaseAuth = getAuth(arguments);
            String providerId =
                (String) Objects.requireNonNull(arguments.get(Constants.SIGN_IN_PROVIDER));
            @SuppressWarnings("unchecked")
            List<String> scopes = (List<String>) arguments.get(Constants.SIGN_IN_PROVIDER_SCOPE);
            @SuppressWarnings("unchecked")
            Map<String, String> customParameters =
                (Map<String, String>) arguments.get(Constants.SIGN_IN_PROVIDER_CUSTOM_PARAMETERS);

            OAuthProvider.Builder provider = OAuthProvider.newBuilder(providerId);
            if (scopes != null) {
              provider.setScopes(scopes);
            }
            if (customParameters != null) {
              provider.addCustomParameters(customParameters);
            }

            AuthResult authResult =
                Tasks.await(
                    firebaseAuth.startActivityForSignInWithProvider(
                        /* activity= */ activity, provider.build()));
            taskCompletionSource.setResult(parseAuthResult(authResult));
          } catch (Exception e) {
            if (e.getCause() instanceof FirebaseAuthMultiFactorException) {
              handleMultiFactorException(arguments, taskCompletionSource, e);
            } else {
              taskCompletionSource.setException(e);
            }
          }
        });

    return taskCompletionSource.getTask();
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

  // Map an app id to a map of user id to a MultiFactorUser object.
  private final Map<String, Map<String, MultiFactor>> multiFactorUserMap = new HashMap<>();

  // Map an id to a MultiFactorSession object.
  private final Map<String, MultiFactorSession> multiFactorSessionMap = new HashMap<>();

  // Map an id to a MultiFactorSession object.
  private final Map<String, MultiFactorResolver> multiFactorResolverMap = new HashMap<>();

  private MultiFactor getAppMultiFactor(@NonNull String appName)
      throws FirebaseNoSignedInUserException {
    final FirebaseUser currentUser = getCurrentUser(appName);
    if (currentUser == null) {
      throw new FirebaseNoSignedInUserException("No user is signed in");
    }
    if (multiFactorUserMap.get(appName) == null) {
      multiFactorUserMap.put(appName, new HashMap<>());
    }

    final Map<String, MultiFactor> appMultiFactorUser = multiFactorUserMap.get(appName);
    if (appMultiFactorUser.get(currentUser.getUid()) == null) {
      appMultiFactorUser.put(currentUser.getUid(), currentUser.getMultiFactor());
    }

    final MultiFactor multiFactor = appMultiFactorUser.get(currentUser.getUid());
    return multiFactor;
  }

  @Override
  public void enrollPhone(
      @NonNull String appName,
      @NonNull GeneratedAndroidFirebaseAuth.PigeonPhoneMultiFactorAssertion assertion,
      @Nullable String displayName,
      GeneratedAndroidFirebaseAuth.Result<Void> result) {
    final MultiFactor multiFactor;
    try {
      multiFactor = getAppMultiFactor(appName);
    } catch (FirebaseNoSignedInUserException e) {
      result.error(e);
      return;
    }

    PhoneAuthCredential credential =
        PhoneAuthProvider.getCredential(
            assertion.getVerificationId(), assertion.getVerificationCode());

    MultiFactorAssertion multiFactorAssertion = PhoneMultiFactorGenerator.getAssertion(credential);

    multiFactor
        .enroll(multiFactorAssertion, displayName)
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                result.success(null);
              } else {
                result.error(task.getException());
              }
            });
  }

  @Override
  public void getSession(
      @NonNull String appName,
      GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonMultiFactorSession>
          result) {
    final MultiFactor multiFactor;
    try {
      multiFactor = getAppMultiFactor(appName);
    } catch (FirebaseNoSignedInUserException e) {
      result.error(e);
      return;
    }

    multiFactor
        .getSession()
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                final MultiFactorSession sessionResult = task.getResult();
                final String id = UUID.randomUUID().toString();
                multiFactorSessionMap.put(id, sessionResult);
                result.success(
                    new GeneratedAndroidFirebaseAuth.PigeonMultiFactorSession.Builder()
                        .setId(id)
                        .build());
              } else {
                Exception exception = task.getException();
                result.error(exception);
              }
            });
  }

  @Override
  public void unenroll(
      @NonNull String appName,
      @Nullable String factorUid,
      GeneratedAndroidFirebaseAuth.Result<Void> result) {
    final MultiFactor multiFactor;
    try {
      multiFactor = getAppMultiFactor(appName);
    } catch (FirebaseNoSignedInUserException e) {
      result.error(e);
      return;
    }

    multiFactor
        .unenroll(factorUid)
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                result.success(null);
              } else {
                result.error(task.getException());
              }
            });
  }

  @Override
  public void getEnrolledFactors(
      @NonNull String appName,
      GeneratedAndroidFirebaseAuth.Result<List<GeneratedAndroidFirebaseAuth.PigeonMultiFactorInfo>>
          result) {
    final MultiFactor multiFactor;
    try {
      multiFactor = getAppMultiFactor(appName);
    } catch (FirebaseNoSignedInUserException e) {
      result.error(e);
      return;
    }

    final List<MultiFactorInfo> factors = multiFactor.getEnrolledFactors();

    final List<GeneratedAndroidFirebaseAuth.PigeonMultiFactorInfo> resultFactors =
        multiFactorInfoToPigeon(factors);

    result.success(resultFactors);
  }

  @Override
  public void resolveSignIn(
      @NonNull String resolverId,
      @NonNull GeneratedAndroidFirebaseAuth.PigeonPhoneMultiFactorAssertion assertion,
      GeneratedAndroidFirebaseAuth.Result<Map<String, Object>> result) {
    final MultiFactorResolver resolver = multiFactorResolverMap.get(resolverId);

    PhoneAuthCredential credential =
        PhoneAuthProvider.getCredential(
            assertion.getVerificationId(), assertion.getVerificationCode());

    MultiFactorAssertion multiFactorAssertion = PhoneMultiFactorGenerator.getAssertion(credential);

    resolver
        .resolveSignIn(multiFactorAssertion)
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                final AuthResult authResult = task.getResult();
                result.success(parseAuthResult(authResult));
              } else {
                Exception exception = task.getException();
                result.error(exception);
              }
            });
  }
}
