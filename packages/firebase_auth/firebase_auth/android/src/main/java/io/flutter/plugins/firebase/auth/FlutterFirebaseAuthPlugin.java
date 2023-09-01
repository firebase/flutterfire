// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.auth;

import static io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry.registerPlugin;

import android.app.Activity;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.firebase.FirebaseApp;
import com.google.firebase.auth.ActionCodeResult;
import com.google.firebase.auth.AuthCredential;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.MultiFactorInfo;
import com.google.firebase.auth.MultiFactorSession;
import com.google.firebase.auth.OAuthProvider;
import com.google.firebase.auth.PhoneMultiFactorInfo;
import com.google.firebase.auth.SignInMethodQueryResult;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/** Flutter plugin for Firebase Auth. */
public class FlutterFirebaseAuthPlugin
    implements FlutterFirebasePlugin,
        FlutterPlugin,
        ActivityAware,
        GeneratedAndroidFirebaseAuth.FirebaseAuthHostApi {

  private static final String METHOD_CHANNEL_NAME = "plugins.flutter.io/firebase_auth";

  // Stores the instances of native AuthCredentials by their hashCode
  static final HashMap<Integer, AuthCredential> authCredentials = new HashMap<>();

  @Nullable private BinaryMessenger messenger;

  private MethodChannel channel;
  private Activity activity;

  private final Map<EventChannel, StreamHandler> streamHandlers = new HashMap<>();

  private final FlutterFirebaseAuthUser firebaseAuthUser = new FlutterFirebaseAuthUser();
  private final FlutterFirebaseMultiFactor firebaseMultiFactor = new FlutterFirebaseMultiFactor();

  private final FlutterFirebaseTotpMultiFactor firebaseTotpMultiFactor =
      new FlutterFirebaseTotpMultiFactor();
  private final FlutterFirebaseTotpSecret firebaseTotpSecret = new FlutterFirebaseTotpSecret();

  private void initInstance(BinaryMessenger messenger) {
    registerPlugin(METHOD_CHANNEL_NAME, this);
    channel = new MethodChannel(messenger, METHOD_CHANNEL_NAME);
    GeneratedAndroidFirebaseAuth.FirebaseAuthHostApi.setup(messenger, this);
    GeneratedAndroidFirebaseAuth.FirebaseAuthUserHostApi.setup(messenger, firebaseAuthUser);
    GeneratedAndroidFirebaseAuth.MultiFactorUserHostApi.setup(messenger, firebaseMultiFactor);
    GeneratedAndroidFirebaseAuth.MultiFactoResolverHostApi.setup(messenger, firebaseMultiFactor);
    GeneratedAndroidFirebaseAuth.MultiFactorTotpHostApi.setup(messenger, firebaseTotpMultiFactor);
    GeneratedAndroidFirebaseAuth.MultiFactorTotpSecretHostApi.setup(messenger, firebaseTotpSecret);

    this.messenger = messenger;
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    initInstance(binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);

    assert messenger != null;
    GeneratedAndroidFirebaseAuth.FirebaseAuthHostApi.setup(messenger, null);
    GeneratedAndroidFirebaseAuth.FirebaseAuthUserHostApi.setup(messenger, null);
    GeneratedAndroidFirebaseAuth.MultiFactorUserHostApi.setup(messenger, null);
    GeneratedAndroidFirebaseAuth.MultiFactoResolverHostApi.setup(messenger, null);
    GeneratedAndroidFirebaseAuth.MultiFactorTotpHostApi.setup(messenger, null);
    GeneratedAndroidFirebaseAuth.MultiFactorTotpSecretHostApi.setup(messenger, null);

    channel = null;
    messenger = null;

    removeEventListeners();
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
    activity = activityPluginBinding.getActivity();
    firebaseAuthUser.setActivity(activity);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    activity = null;
    firebaseAuthUser.setActivity(null);
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
    activity = activityPluginBinding.getActivity();
    firebaseAuthUser.setActivity(activity);
  }

  @Override
  public void onDetachedFromActivity() {
    activity = null;
    firebaseAuthUser.setActivity(null);
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
    FirebaseAuth firebaseAuth = getAuthFromPigeon(app);
    firebaseAuth
        .applyActionCode(code)
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                result.success(null);
              } else {
                result.error(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                        task.getException()));
              }
            });
  }

  @Override
  public void checkActionCode(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull String code,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonActionCodeInfo>
              result) {
    FirebaseAuth firebaseAuth = getAuthFromPigeon(app);
    firebaseAuth
        .checkActionCode(code)
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                ActionCodeResult actionCodeInfo = task.getResult();
                result.success(PigeonParser.parseActionCodeResult(actionCodeInfo));
              } else {
                result.error(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                        task.getException()));
              }
            });
  }

  @Override
  public void confirmPasswordReset(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull String code,
      @NonNull String newPassword,
      @NonNull GeneratedAndroidFirebaseAuth.Result<Void> result) {
    FirebaseAuth firebaseAuth = getAuthFromPigeon(app);

    firebaseAuth
        .confirmPasswordReset(code, newPassword)
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                result.success(null);
              } else {
                result.error(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                        task.getException()));
              }
            });
  }

  @Override
  public void createUserWithEmailAndPassword(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull String email,
      @NonNull String password,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserCredential>
              result) {
    FirebaseAuth firebaseAuth = getAuthFromPigeon(app);

    firebaseAuth
        .createUserWithEmailAndPassword(email, password)
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                AuthResult authResult = task.getResult();
                result.success(PigeonParser.parseAuthResult(authResult));
              } else {
                result.error(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                        task.getException()));
              }
            });
  }

  @Override
  public void signInAnonymously(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserCredential>
              result) {
    FirebaseAuth firebaseAuth = getAuthFromPigeon(app);
    firebaseAuth
        .signInAnonymously()
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                AuthResult authResult = task.getResult();
                result.success(PigeonParser.parseAuthResult(authResult));
              } else {
                result.error(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                        task.getException()));
              }
            });
  }

  @Override
  public void signInWithCredential(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull Map<String, Object> input,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserCredential>
              result) {
    FirebaseAuth firebaseAuth = getAuthFromPigeon(app);
    AuthCredential credential = PigeonParser.getCredential(input);

    if (credential == null) {
      throw FlutterFirebaseAuthPluginException.invalidCredential();
    }
    firebaseAuth
        .signInWithCredential(credential)
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                AuthResult authResult = task.getResult();
                result.success(PigeonParser.parseAuthResult(authResult));
              } else {
                result.error(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                        task.getException()));
              }
            });
  }

  @Override
  public void signInWithCustomToken(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull String token,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserCredential>
              result) {
    FirebaseAuth firebaseAuth = getAuthFromPigeon(app);

    firebaseAuth
        .signInWithCustomToken(token)
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                AuthResult authResult = task.getResult();
                result.success(PigeonParser.parseAuthResult(authResult));
              } else {
                result.error(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                        task.getException()));
              }
            });
  }

  @Override
  public void signInWithEmailAndPassword(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull String email,
      @NonNull String password,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserCredential>
              result) {
    FirebaseAuth firebaseAuth = getAuthFromPigeon(app);
    firebaseAuth
        .signInWithEmailAndPassword(email, password)
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                result.success(PigeonParser.parseAuthResult(task.getResult()));
              } else {
                result.error(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                        task.getException()));
              }
            });
  }

  @Override
  public void signInWithEmailLink(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull String email,
      @NonNull String emailLink,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserCredential>
              result) {
    FirebaseAuth firebaseAuth = getAuthFromPigeon(app);
    firebaseAuth
        .signInWithEmailLink(email, emailLink)
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                AuthResult authResult = task.getResult();
                result.success(PigeonParser.parseAuthResult(authResult));
              } else {
                result.error(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                        task.getException()));
              }
            });
  }

  @Override
  public void signInWithProvider(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseAuth.PigeonSignInProvider signInProvider,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserCredential>
              result) {
    FirebaseAuth firebaseAuth = getAuthFromPigeon(app);

    OAuthProvider.Builder provider = OAuthProvider.newBuilder(signInProvider.getProviderId());
    if (signInProvider.getScopes() != null) {
      provider.setScopes(signInProvider.getScopes());
    }
    if (signInProvider.getCustomParameters() != null) {
      provider.addCustomParameters(signInProvider.getCustomParameters());
    }

    firebaseAuth
        .startActivityForSignInWithProvider(getActivity(), provider.build())
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                AuthResult authResult = task.getResult();
                result.success(PigeonParser.parseAuthResult(authResult));
              } else {
                result.error(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                        task.getException()));
              }
            });
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
    FirebaseAuth firebaseAuth = getAuthFromPigeon(app);

    firebaseAuth
        .fetchSignInMethodsForEmail(email)
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                SignInMethodQueryResult signInMethodQueryResult = task.getResult();
                result.success(signInMethodQueryResult.getSignInMethods());
              } else {
                result.error(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                        task.getException()));
              }
            });
  }

  @Override
  public void sendPasswordResetEmail(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull String email,
      @Nullable GeneratedAndroidFirebaseAuth.PigeonActionCodeSettings actionCodeSettings,
      @NonNull GeneratedAndroidFirebaseAuth.Result<Void> result) {
    FirebaseAuth firebaseAuth = getAuthFromPigeon(app);

    if (actionCodeSettings == null) {
      firebaseAuth
          .sendPasswordResetEmail(email)
          .addOnCompleteListener(
              task -> {
                if (task.isSuccessful()) {
                  result.success(null);
                } else {
                  result.error(
                      FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                          task.getException()));
                }
              });
      return;
    }

    firebaseAuth
        .sendPasswordResetEmail(email, PigeonParser.getActionCodeSettings(actionCodeSettings))
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                result.success(null);
              } else {
                result.error(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                        task.getException()));
              }
            });
  }

  @Override
  public void sendSignInLinkToEmail(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull String email,
      @NonNull GeneratedAndroidFirebaseAuth.PigeonActionCodeSettings actionCodeSettings,
      @NonNull GeneratedAndroidFirebaseAuth.Result<Void> result) {
    FirebaseAuth firebaseAuth = getAuthFromPigeon(app);

    firebaseAuth
        .sendSignInLinkToEmail(email, PigeonParser.getActionCodeSettings(actionCodeSettings))
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                result.success(null);
              } else {
                result.error(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                        task.getException()));
              }
            });
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
    FirebaseAuth firebaseAuth = getAuthFromPigeon(app);

    firebaseAuth
        .verifyPasswordResetCode(code)
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                result.success(task.getResult());
              } else {
                result.error(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                        task.getException()));
              }
            });
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

  @Override
  public void revokeTokenWithAuthorizationCode(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull String authorizationCode,
      @NonNull GeneratedAndroidFirebaseAuth.Result<Void> result) {
    // Should never get here as we throw Exception on Dart side.
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

            GeneratedAndroidFirebaseAuth.PigeonUserDetails user =
                firebaseUser == null ? null : PigeonParser.parseFirebaseUser(firebaseUser);

            if (languageCode != null) {
              constants.put("APP_LANGUAGE_CODE", languageCode);
            }

            if (user != null) {
              final Object parsedUser = user.toList();
              constants.put("APP_CURRENT_USER", parsedUser);
            }

            taskCompletionSource.setResult(constants);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
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
