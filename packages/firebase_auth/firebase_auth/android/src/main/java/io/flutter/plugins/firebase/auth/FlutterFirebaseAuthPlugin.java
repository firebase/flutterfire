// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.auth;

import static io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry.registerPlugin;

import android.app.Activity;
import android.net.Uri;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApiNotAvailableException;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseException;
import com.google.firebase.FirebaseNetworkException;
import com.google.firebase.FirebaseTooManyRequestsException;
import com.google.firebase.auth.ActionCodeEmailInfo;
import com.google.firebase.auth.ActionCodeInfo;
import com.google.firebase.auth.ActionCodeResult;
import com.google.firebase.auth.ActionCodeSettings;
import com.google.firebase.auth.AdditionalUserInfo;
import com.google.firebase.auth.AuthCredential;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.EmailAuthProvider;
import com.google.firebase.auth.FacebookAuthProvider;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseAuthProvider;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.FirebaseUserMetadata;
import com.google.firebase.auth.GetTokenResult;
import com.google.firebase.auth.GithubAuthProvider;
import com.google.firebase.auth.GoogleAuthProvider;
import com.google.firebase.auth.OAuthProvider;
import com.google.firebase.auth.PhoneAuthCredential;
import com.google.firebase.auth.PhoneAuthOptions;
import com.google.firebase.auth.PhoneAuthProvider;
import com.google.firebase.auth.SignInMethodQueryResult;
import com.google.firebase.auth.TwitterAuthProvider;
import com.google.firebase.auth.UserInfo;
import com.google.firebase.auth.UserProfileChangeRequest;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;

/** Flutter plugin for Firebase Auth. */
public class FlutterFirebaseAuthPlugin
    implements FlutterFirebasePlugin, MethodCallHandler, FlutterPlugin, ActivityAware {

  // Stores the instances of native AuthCredentials by their hashCode
  static final HashMap<Integer, AuthCredential> authCredentials = new HashMap<>();

  private static final HashMap<String, FirebaseAuth.AuthStateListener> authListeners =
      new HashMap<>();
  private static final HashMap<String, FirebaseAuth.IdTokenListener> idTokenListeners =
      new HashMap<>();
  private static final HashMap<Integer, PhoneAuthProvider.ForceResendingToken>
      forceResendingTokens = new HashMap<>();
  private PluginRegistry.Registrar registrar;
  private MethodChannel channel;
  private Activity activity;
  private static Boolean initialAuthState = true;

  @SuppressWarnings("unused")
  public static void registerWith(PluginRegistry.Registrar registrar) {
    FlutterFirebaseAuthPlugin instance = new FlutterFirebaseAuthPlugin();
    instance.registrar = registrar;
    instance.initInstance(registrar.messenger());
  }

  static Map<String, Object> parseAuthCredential(AuthCredential authCredential) {
    if (authCredential == null) {
      return null;
    }

    int authCredentialHashCode = authCredential.hashCode();
    authCredentials.put(authCredentialHashCode, authCredential);

    Map<String, Object> output = new HashMap<>();

    output.put(Constants.PROVIDER_ID, authCredential.getProvider());
    output.put(Constants.SIGN_IN_METHOD, authCredential.getSignInMethod());
    output.put(Constants.TOKEN, authCredentialHashCode);

    return output;
  }

  private void initInstance(BinaryMessenger messenger) {
    String channelName = "plugins.flutter.io/firebase_auth";
    registerPlugin(channelName, this);
    channel = new MethodChannel(messenger, channelName);
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    initInstance(binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    removeEventListeners();
    channel.setMethodCallHandler(null);
    channel = null;
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

  // Ensure any listeners are removed when the app
  // is detached from the FlutterEngine
  private void removeEventListeners() {
    Iterator<?> authListenerIterator = authListeners.entrySet().iterator();

    while (authListenerIterator.hasNext()) {
      Map.Entry<?, ?> pair = (Map.Entry<?, ?>) authListenerIterator.next();
      String appName = (String) pair.getKey();
      FirebaseApp firebaseApp = FirebaseApp.getInstance(appName);
      FirebaseAuth firebaseAuth = FirebaseAuth.getInstance(firebaseApp);
      FirebaseAuth.AuthStateListener authListener =
          (FirebaseAuth.AuthStateListener) pair.getValue();
      firebaseAuth.removeAuthStateListener(authListener);
      authListenerIterator.remove();
    }

    Iterator<?> idTokenListenerIterator = idTokenListeners.entrySet().iterator();

    while (idTokenListenerIterator.hasNext()) {
      Map.Entry<?, ?> pair = (Map.Entry<?, ?>) idTokenListenerIterator.next();
      String appName = (String) pair.getKey();
      FirebaseApp firebaseApp = FirebaseApp.getInstance(appName);
      FirebaseAuth firebaseAuth = FirebaseAuth.getInstance(firebaseApp);
      FirebaseAuth.IdTokenListener authListener = (FirebaseAuth.IdTokenListener) pair.getValue();
      firebaseAuth.removeIdTokenListener(authListener);
      idTokenListenerIterator.remove();
    }
  }

  // Only access activity with this method.
  private Activity getActivity() {
    return registrar != null ? registrar.activity() : activity;
  }

  private FirebaseAuth getAuth(Map<String, Object> arguments) {
    String appName = (String) Objects.requireNonNull(arguments.get(Constants.APP_NAME));
    FirebaseApp app = FirebaseApp.getInstance(appName);
    return FirebaseAuth.getInstance(app);
  }

  private MethodChannel.Result getMethodChannelResultHandler(String method) {
    return new Result() {
      @Override
      public void success(@Nullable Object result) {
        // Noop
      }

      @Override
      public void error(
          String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
        Log.e(Constants.TAG, method + " error (" + errorCode + "): " + errorMessage);
      }

      @Override
      public void notImplemented() {
        Log.e(Constants.TAG, method + " has not been implemented");
      }
    };
  }

  private FirebaseUser getCurrentUser(Map<String, Object> arguments) {
    String appName = (String) Objects.requireNonNull(arguments.get(Constants.APP_NAME));
    FirebaseApp app = FirebaseApp.getInstance(appName);
    return FirebaseAuth.getInstance(app).getCurrentUser();
  }

  private AuthCredential getCredential(Map<String, Object> arguments)
      throws FlutterFirebaseAuthPluginException {
    @SuppressWarnings("unchecked")
    Map<String, Object> credentialMap =
        (Map<String, Object>) Objects.requireNonNull(arguments.get(Constants.CREDENTIAL));

    // If the credential map contains a token, it means a native one has been stored
    if (credentialMap.get(Constants.TOKEN) != null) {
      int token = (int) credentialMap.get(Constants.TOKEN);
      AuthCredential credential = authCredentials.get(token);

      if (credential == null) {
        throw FlutterFirebaseAuthPluginException.invalidCredential();
      }

      return credential;
    }

    String signInMethod =
        (String) Objects.requireNonNull(credentialMap.get(Constants.SIGN_IN_METHOD));
    String secret = (String) credentialMap.get(Constants.SECRET);
    String idToken = (String) credentialMap.get(Constants.ID_TOKEN);
    String accessToken = (String) credentialMap.get(Constants.ACCESS_TOKEN);
    String rawNonce = (String) credentialMap.get(Constants.RAW_NONCE);

    switch (signInMethod) {
      case Constants.SIGN_IN_METHOD_PASSWORD:
        return EmailAuthProvider.getCredential(
            (String) Objects.requireNonNull(credentialMap.get(Constants.EMAIL)),
            Objects.requireNonNull(secret));
      case Constants.SIGN_IN_METHOD_EMAIL_LINK:
        return EmailAuthProvider.getCredentialWithLink(
            (String) Objects.requireNonNull(credentialMap.get(Constants.EMAIL)),
            (String) Objects.requireNonNull(credentialMap.get(Constants.EMAIL_LINK)));
      case Constants.SIGN_IN_METHOD_FACEBOOK:
        return FacebookAuthProvider.getCredential(Objects.requireNonNull(accessToken));
      case Constants.SIGN_IN_METHOD_GOOGLE:
        return GoogleAuthProvider.getCredential(idToken, accessToken);
      case Constants.SIGN_IN_METHOD_TWITTER:
        return TwitterAuthProvider.getCredential(
            Objects.requireNonNull(accessToken), Objects.requireNonNull(secret));
      case Constants.SIGN_IN_METHOD_GITHUB:
        return GithubAuthProvider.getCredential(Objects.requireNonNull(accessToken));
      case Constants.SIGN_IN_METHOD_PHONE:
        {
          String verificationId =
              (String) Objects.requireNonNull(credentialMap.get(Constants.VERIFICATION_ID));
          String smsCode = (String) Objects.requireNonNull(credentialMap.get(Constants.SMS_CODE));
          return PhoneAuthProvider.getCredential(verificationId, smsCode);
        }
      case Constants.SIGN_IN_METHOD_OAUTH:
        {
          String providerId =
              (String) Objects.requireNonNull(credentialMap.get(Constants.PROVIDER_ID));
          OAuthProvider.CredentialBuilder builder = OAuthProvider.newCredentialBuilder(providerId);
          builder.setAccessToken(Objects.requireNonNull(accessToken));
          if (rawNonce == null) {
            builder.setIdToken(Objects.requireNonNull(idToken));
          } else {
            builder.setIdTokenWithRawNonce(Objects.requireNonNull(idToken), rawNonce);
          }

          return builder.build();
        }
      default:
        return null;
    }
  }

  @SuppressWarnings("ConstantConditions")
  private Map<String, Object> parseActionCodeResult(@NonNull ActionCodeResult actionCodeResult) {
    Map<String, Object> output = new HashMap<>();
    Map<String, Object> data = new HashMap<>();

    int operation = actionCodeResult.getOperation();

    switch (operation) {
      case ActionCodeResult.PASSWORD_RESET:
        output.put("operation", 1);
        break;
      case ActionCodeResult.VERIFY_EMAIL:
        output.put("operation", 2);
        break;
      case ActionCodeResult.RECOVER_EMAIL:
        output.put("operation", 3);
        break;
      case ActionCodeResult.SIGN_IN_WITH_EMAIL_LINK:
        output.put("operation", 4);
        break;
      case ActionCodeResult.VERIFY_BEFORE_CHANGE_EMAIL:
        output.put("operation", 5);
        break;
      case ActionCodeResult.REVERT_SECOND_FACTOR_ADDITION:
        output.put("operation", 6);
        break;
      default:
        // Unknown / Error.
        output.put("operation", 0);
    }

    ActionCodeInfo actionCodeInfo = actionCodeResult.getInfo();

    if (actionCodeInfo != null && operation == ActionCodeResult.VERIFY_EMAIL
        || operation == ActionCodeResult.PASSWORD_RESET) {
      data.put(Constants.EMAIL, actionCodeInfo.getEmail());
      data.put(Constants.PREVIOUS_EMAIL, null);
    } else if (operation == ActionCodeResult.REVERT_SECOND_FACTOR_ADDITION) {
      data.put(Constants.EMAIL, null);
      data.put(Constants.PREVIOUS_EMAIL, null);
    } else if (operation == ActionCodeResult.RECOVER_EMAIL
        || operation == ActionCodeResult.VERIFY_BEFORE_CHANGE_EMAIL) {
      ActionCodeEmailInfo actionCodeEmailInfo =
          (ActionCodeEmailInfo) Objects.requireNonNull(actionCodeInfo);
      data.put(Constants.EMAIL, actionCodeEmailInfo.getEmail());
      data.put(Constants.PREVIOUS_EMAIL, actionCodeEmailInfo.getPreviousEmail());
    }

    output.put("data", data);
    return output;
  }

  @SuppressWarnings("ConstantConditions")
  private Map<String, Object> parseAuthResult(@NonNull AuthResult authResult) {
    Map<String, Object> output = new HashMap<>();

    output.put(
        Constants.ADDITIONAL_USER_INFO,
        parseAdditionalUserInfo(authResult.getAdditionalUserInfo()));
    output.put(Constants.AUTH_CREDENTIAL, parseAuthCredential(authResult.getCredential()));
    output.put(Constants.USER, parseFirebaseUser(authResult.getUser()));

    return output;
  }

  @SuppressWarnings("ConstantConditions")
  private Map<String, Object> parseAdditionalUserInfo(AdditionalUserInfo additionalUserInfo) {
    if (additionalUserInfo == null) {
      return null;
    }

    Map<String, Object> output = new HashMap<>();

    output.put(Constants.IS_NEW_USER, additionalUserInfo.isNewUser());
    output.put(Constants.PROFILE, additionalUserInfo.getProfile());
    output.put(Constants.PROVIDER_ID, additionalUserInfo.getProviderId());
    output.put(Constants.USERNAME, additionalUserInfo.getUsername());

    return output;
  }

  @SuppressWarnings("ConstantConditions")
  private Map<String, Object> parseFirebaseUser(FirebaseUser firebaseUser) {
    if (firebaseUser == null) {
      return null;
    }

    Map<String, Object> output = new HashMap<>();
    Map<String, Object> metadata = new HashMap<>();

    output.put(Constants.DISPLAY_NAME, firebaseUser.getDisplayName());
    output.put(Constants.EMAIL, firebaseUser.getEmail());
    output.put(Constants.EMAIL_VERIFIED, firebaseUser.isEmailVerified());
    output.put(Constants.IS_ANONYMOUS, firebaseUser.isAnonymous());

    // TODO(Salakar): add an integration test to check for null, if possible
    // See https://github.com/FirebaseExtended/flutterfire/issues/3643
    final FirebaseUserMetadata userMetadata = firebaseUser.getMetadata();
    if (userMetadata != null) {
      metadata.put(Constants.CREATION_TIME, firebaseUser.getMetadata().getCreationTimestamp());
      metadata.put(
          Constants.LAST_SIGN_IN_TIME, firebaseUser.getMetadata().getLastSignInTimestamp());
    }
    output.put(Constants.METADATA, metadata);
    output.put(Constants.PHONE_NUMBER, firebaseUser.getPhoneNumber());
    output.put(Constants.PHOTO_URL, parsePhotoUrl(firebaseUser.getPhotoUrl()));
    output.put(Constants.PROVIDER_DATA, parseUserInfoList(firebaseUser.getProviderData()));
    output.put(Constants.REFRESH_TOKEN, ""); // native does not provide refresh tokens
    output.put(Constants.UID, firebaseUser.getUid());

    return output;
  }

  private List<Map<String, Object>> parseUserInfoList(List<? extends UserInfo> userInfoList) {
    List<Map<String, Object>> output = new ArrayList<>();

    for (UserInfo userInfo : userInfoList) {
      if (!FirebaseAuthProvider.PROVIDER_ID.equals(userInfo.getProviderId())) {
        output.add(parseUserInfo(userInfo));
      }
    }

    return output;
  }

  @SuppressWarnings("ConstantConditions")
  private Map<String, Object> parseUserInfo(@NonNull UserInfo userInfo) {
    Map<String, Object> output = new HashMap<>();

    output.put(Constants.DISPLAY_NAME, userInfo.getDisplayName());
    output.put(Constants.EMAIL, userInfo.getEmail());
    output.put(Constants.PHONE_NUMBER, userInfo.getPhoneNumber());
    output.put(Constants.PHOTO_URL, parsePhotoUrl(userInfo.getPhotoUrl()));
    output.put(Constants.PROVIDER_ID, userInfo.getProviderId());
    output.put(Constants.UID, userInfo.getUid());

    return output;
  }

  private String parsePhotoUrl(Uri photoUri) {
    if (photoUri == null) {
      return null;
    }

    String photoUrl = photoUri.toString();

    // Return null if the URL is an empty string
    return "".equals(photoUrl) ? null : photoUrl;
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

  @SuppressWarnings("ConstantConditions")
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

  @SuppressWarnings("ConstantConditions")
  private Task<Void> registerChangeListeners(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          String appName = (String) Objects.requireNonNull(arguments.get(Constants.APP_NAME));
          FirebaseAuth firebaseAuth = getAuth(arguments);

          FirebaseAuth.AuthStateListener authStateListener = authListeners.get(appName);
          FirebaseAuth.IdTokenListener idTokenListener = idTokenListeners.get(appName);

          Map<String, Object> event = new HashMap<>();
          event.put(Constants.APP_NAME, appName);

          if (authStateListener == null) {
            FirebaseAuth.AuthStateListener newAuthStateListener =
                auth -> {
                  FirebaseUser user = auth.getCurrentUser();

                  if (user == null) {
                    event.put(Constants.USER, null);
                  } else {
                    event.put(Constants.USER, parseFirebaseUser(user));
                  }

                  if (initialAuthState) {
                    initialAuthState = false;
                  } else {
                    channel.invokeMethod(
                        "Auth#authStateChanges",
                        event,
                        getMethodChannelResultHandler("Auth#authStateChanges"));
                  }
                };

            firebaseAuth.addAuthStateListener(newAuthStateListener);
            authListeners.put(appName, newAuthStateListener);
          }

          if (idTokenListener == null) {
            FirebaseAuth.IdTokenListener newIdTokenChangeListener =
                auth -> {
                  FirebaseUser user = auth.getCurrentUser();

                  if (user == null) {
                    event.put(Constants.USER, null);
                  } else {
                    event.put(Constants.USER, parseFirebaseUser(user));
                  }

                  channel.invokeMethod(
                      "Auth#idTokenChanges",
                      event,
                      getMethodChannelResultHandler("Auth#idTokenChanges"));
                };

            firebaseAuth.addIdTokenListener(newIdTokenChangeListener);
            idTokenListeners.put(appName, newIdTokenChangeListener);
          }

          return null;
        });
  }

  private Task<Void> applyActionCode(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseAuth firebaseAuth = getAuth(arguments);
          String code = (String) Objects.requireNonNull(arguments.get(Constants.CODE));

          return Tasks.await(firebaseAuth.applyActionCode(code));
        });
  }

  private Task<Map<String, Object>> checkActionCode(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseAuth firebaseAuth = getAuth(arguments);
          String code = (String) Objects.requireNonNull(arguments.get(Constants.CODE));

          ActionCodeResult actionCodeResult = Tasks.await(firebaseAuth.checkActionCode(code));
          return parseActionCodeResult(actionCodeResult);
        });
  }

  private Task<Void> confirmPasswordReset(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseAuth firebaseAuth = getAuth(arguments);
          String code = (String) Objects.requireNonNull(arguments.get(Constants.CODE));
          String newPassword =
              (String) Objects.requireNonNull(arguments.get(Constants.NEW_PASSWORD));

          return Tasks.await(firebaseAuth.confirmPasswordReset(code, newPassword));
        });
  }

  private Task<Map<String, Object>> createUserWithEmailAndPassword(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseAuth firebaseAuth = getAuth(arguments);
          String email = (String) Objects.requireNonNull(arguments.get(Constants.EMAIL));
          String password = (String) Objects.requireNonNull(arguments.get(Constants.PASSWORD));

          AuthResult authResult =
              Tasks.await(firebaseAuth.createUserWithEmailAndPassword(email, password));

          return parseAuthResult(authResult);
        });
  }

  @SuppressWarnings("ConstantConditions")
  private Task<Map<String, Object>> fetchSignInMethodsForEmail(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseAuth firebaseAuth = getAuth(arguments);
          String email = (String) Objects.requireNonNull(arguments.get(Constants.EMAIL));

          SignInMethodQueryResult result =
              Tasks.await(firebaseAuth.fetchSignInMethodsForEmail(email));

          Map<String, Object> output = new HashMap<>();
          output.put(Constants.PROVIDERS, result.getSignInMethods());

          return output;
        });
  }

  private Task<Void> sendPasswordResetEmail(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseAuth firebaseAuth = getAuth(arguments);
          String email = (String) Objects.requireNonNull(arguments.get(Constants.EMAIL));
          Object rawActionCodeSettings = arguments.get(Constants.ACTION_CODE_SETTINGS);

          if (rawActionCodeSettings == null) {
            return Tasks.await(firebaseAuth.sendPasswordResetEmail(email));
          }

          @SuppressWarnings("unchecked")
          Map<String, Object> actionCodeSettings = (Map<String, Object>) rawActionCodeSettings;

          return Tasks.await(
              firebaseAuth.sendPasswordResetEmail(
                  email, getActionCodeSettings(actionCodeSettings)));
        });
  }

  private Task<Void> sendSignInLinkToEmail(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseAuth firebaseAuth = getAuth(arguments);
          String email = (String) Objects.requireNonNull(arguments.get(Constants.EMAIL));

          @SuppressWarnings("unchecked")
          Map<String, Object> actionCodeSettings =
              (Map<String, Object>)
                  Objects.requireNonNull(arguments.get(Constants.ACTION_CODE_SETTINGS));

          return Tasks.await(
              firebaseAuth.sendSignInLinkToEmail(email, getActionCodeSettings(actionCodeSettings)));
        });
  }

  private Task<Map<String, Object>> setLanguageCode(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseAuth firebaseAuth = getAuth(arguments);
          String languageCode = (String) arguments.get(Constants.LANGUAGE_CODE);

          if (languageCode == null) {
            firebaseAuth.useAppLanguage();
          } else {
            firebaseAuth.setLanguageCode(languageCode);
          }

          return new HashMap<String, Object>() {
            {
              put(Constants.LANGUAGE_CODE, firebaseAuth.getLanguageCode());
            }
          };
        });
  }

  // Settings are a no-op on Android
  private Task<Void> setSettings() {
    return Tasks.call(cachedThreadPool, () -> null);
  }

  private Task<Map<String, Object>> signInAnonymously(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseAuth firebaseAuth = getAuth(arguments);
          AuthResult authResult = Tasks.await(firebaseAuth.signInAnonymously());
          return parseAuthResult(authResult);
        });
  }

  private Task<Map<String, Object>> signInWithCredential(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseAuth firebaseAuth = getAuth(arguments);
          AuthCredential credential = getCredential(arguments);

          if (credential == null) {
            throw FlutterFirebaseAuthPluginException.invalidCredential();
          }
          AuthResult authResult = Tasks.await(firebaseAuth.signInWithCredential(credential));
          return parseAuthResult(authResult);
        });
  }

  private Task<Map<String, Object>> signInWithCustomToken(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseAuth firebaseAuth = getAuth(arguments);
          String token = (String) Objects.requireNonNull(arguments.get(Constants.TOKEN));

          AuthResult authResult = Tasks.await(firebaseAuth.signInWithCustomToken(token));
          return parseAuthResult(authResult);
        });
  }

  private Task<Map<String, Object>> signInWithEmailAndPassword(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseAuth firebaseAuth = getAuth(arguments);
          String email = (String) Objects.requireNonNull(arguments.get(Constants.EMAIL));
          String password = (String) Objects.requireNonNull(arguments.get(Constants.PASSWORD));

          AuthResult authResult =
              Tasks.await(firebaseAuth.signInWithEmailAndPassword(email, password));
          return parseAuthResult(authResult);
        });
  }

  private Task<Map<String, Object>> signInWithEmailLink(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseAuth firebaseAuth = getAuth(arguments);
          String email = (String) Objects.requireNonNull(arguments.get(Constants.EMAIL));
          String emailLink = (String) Objects.requireNonNull(arguments.get(Constants.EMAIL_LINK));

          AuthResult authResult = Tasks.await(firebaseAuth.signInWithEmailLink(email, emailLink));
          return parseAuthResult(authResult);
        });
  }

  private Task<Void> signOut(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseAuth firebaseAuth = getAuth(arguments);
          firebaseAuth.signOut();
          return null;
        });
  }

  private Task<Void> useEmulator(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseAuth firebaseAuth = getAuth(arguments);
          String host = (String) arguments.get(Constants.HOST);
          int port = (int) arguments.get(Constants.PORT);
          firebaseAuth.useEmulator(host, port);
          return null;
        });
  }

  private Task<Map<String, Object>> verifyPasswordResetCode(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseAuth firebaseAuth = getAuth(arguments);
          String code = (String) Objects.requireNonNull(arguments.get(Constants.CODE));

          Map<String, Object> output = new HashMap<>();
          output.put(Constants.EMAIL, Tasks.await(firebaseAuth.verifyPasswordResetCode(code)));
          return output;
        });
  }

  private Task<Void> verifyPhoneNumber(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseAuth firebaseAuth = getAuth(arguments);
          String phoneNumber =
              (String) Objects.requireNonNull(arguments.get(Constants.PHONE_NUMBER));
          int handle = (int) Objects.requireNonNull(arguments.get(Constants.HANDLE));
          int timeout = (int) Objects.requireNonNull(arguments.get(Constants.TIMEOUT));

          Map<String, Object> event = new HashMap<>();
          event.put(Constants.HANDLE, handle);

          PhoneAuthProvider.OnVerificationStateChangedCallbacks callbacks =
              new PhoneAuthProvider.OnVerificationStateChangedCallbacks() {
                @Override
                public void onVerificationCompleted(
                    @NonNull PhoneAuthCredential phoneAuthCredential) {
                  int phoneAuthCredentialHashCode = phoneAuthCredential.hashCode();
                  authCredentials.put(phoneAuthCredentialHashCode, phoneAuthCredential);
                  event.put(Constants.TOKEN, phoneAuthCredentialHashCode);

                  if (phoneAuthCredential.getSmsCode() != null) {
                    event.put(Constants.SMS_CODE, phoneAuthCredential.getSmsCode());
                  }

                  channel.invokeMethod(
                      "Auth#phoneVerificationCompleted",
                      event,
                      getMethodChannelResultHandler("Auth#phoneVerificationCompleted"));
                }

                @Override
                public void onVerificationFailed(@NonNull FirebaseException e) {
                  Map<String, Object> error = new HashMap<>();
                  error.put("message", e.getLocalizedMessage());
                  error.put("details", getExceptionDetails(e));
                  event.put("error", error);

                  channel.invokeMethod(
                      "Auth#phoneVerificationFailed",
                      event,
                      getMethodChannelResultHandler("Auth#phoneVerificationFailed"));
                }

                @Override
                public void onCodeSent(
                    @NonNull String verificationId,
                    @NonNull PhoneAuthProvider.ForceResendingToken token) {
                  int forceResendingTokenHashCode = token.hashCode();
                  forceResendingTokens.put(forceResendingTokenHashCode, token);
                  event.put(Constants.VERIFICATION_ID, verificationId);
                  event.put(Constants.FORCE_RESENDING_TOKEN, forceResendingTokenHashCode);

                  channel.invokeMethod(
                      "Auth#phoneCodeSent",
                      event,
                      getMethodChannelResultHandler("Auth#phoneCodeSent"));
                }

                @Override
                public void onCodeAutoRetrievalTimeOut(@NonNull String verificationId) {
                  event.put(Constants.VERIFICATION_ID, verificationId);

                  channel.invokeMethod(
                      "Auth#phoneCodeAutoRetrievalTimeout",
                      event,
                      getMethodChannelResultHandler("Auth#phoneCodeAutoRetrievalTimeout"));
                }
              };

          // Allows the auto-retrieval flow to be tested.
          // See https://firebase.google.com/docs/auth/android/phone-auth#integration-testing
          if (arguments.get(Constants.AUTO_RETRIEVED_SMS_CODE_FOR_TESTING) != null) {
            String autoRetrievedSmsCodeForTesting =
                (String)
                    Objects.requireNonNull(
                        arguments.get(Constants.AUTO_RETRIEVED_SMS_CODE_FOR_TESTING));

            firebaseAuth
                .getFirebaseAuthSettings()
                .setAutoRetrievedSmsCodeForPhoneNumber(phoneNumber, autoRetrievedSmsCodeForTesting);
          }

          PhoneAuthOptions.Builder phoneAuthOptionsBuilder =
              new PhoneAuthOptions.Builder(firebaseAuth);
          phoneAuthOptionsBuilder.setActivity(getActivity());
          phoneAuthOptionsBuilder.setPhoneNumber(phoneNumber);
          phoneAuthOptionsBuilder.setCallbacks(callbacks);
          phoneAuthOptionsBuilder.setTimeout((long) timeout, TimeUnit.MILLISECONDS);

          if (arguments.get(Constants.FORCE_RESENDING_TOKEN) != null) {
            int forceResendingTokenHashCode =
                (int) Objects.requireNonNull(arguments.get(Constants.FORCE_RESENDING_TOKEN));

            PhoneAuthProvider.ForceResendingToken forceResendingToken =
                forceResendingTokens.get(forceResendingTokenHashCode);

            if (forceResendingToken != null) {
              phoneAuthOptionsBuilder.setForceResendingToken(forceResendingToken);
            }
          }

          PhoneAuthProvider.verifyPhoneNumber(phoneAuthOptionsBuilder.build());
          return null;
        });
  }

  private Task<Void> deleteUser(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseUser firebaseUser = getCurrentUser(arguments);

          if (firebaseUser == null) {
            throw FlutterFirebaseAuthPluginException.noUser();
          }

          return Tasks.await(firebaseUser.delete());
        });
  }

  @SuppressWarnings("ConstantConditions")
  private Task<Map<String, Object>> getIdToken(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseUser firebaseUser = getCurrentUser(arguments);
          Boolean forceRefresh =
              (Boolean) Objects.requireNonNull(arguments.get(Constants.FORCE_REFRESH));
          Boolean tokenOnly = (Boolean) Objects.requireNonNull(arguments.get(Constants.TOKEN_ONLY));

          if (firebaseUser == null) {
            throw FlutterFirebaseAuthPluginException.noUser();
          }

          GetTokenResult tokenResult = Tasks.await(firebaseUser.getIdToken(forceRefresh));

          if (tokenOnly) {
            Map<String, Object> output = new HashMap<>();
            output.put("token", tokenResult.getToken());
            return output;
          } else {
            return parseTokenResult(tokenResult);
          }
        });
  }

  private Task<Map<String, Object>> linkUserWithCredential(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseUser firebaseUser = getCurrentUser(arguments);
          AuthCredential credential = getCredential(arguments);

          if (firebaseUser == null) {
            throw FlutterFirebaseAuthPluginException.noUser();
          }

          if (credential == null) {
            throw FlutterFirebaseAuthPluginException.invalidCredential();
          }

          AuthResult authResult = Tasks.await(firebaseUser.linkWithCredential(credential));
          return parseAuthResult(authResult);
        });
  }

  private Task<Map<String, Object>> reauthenticateUserWithCredential(
      Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseUser firebaseUser = getCurrentUser(arguments);
          AuthCredential credential = getCredential(arguments);

          if (firebaseUser == null) {
            throw FlutterFirebaseAuthPluginException.noUser();
          }

          if (credential == null) {
            throw FlutterFirebaseAuthPluginException.invalidCredential();
          }

          AuthResult authResult =
              Tasks.await(firebaseUser.reauthenticateAndRetrieveData(credential));
          return parseAuthResult(authResult);
        });
  }

  private Task<Map<String, Object>> reloadUser(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseUser firebaseUser = getCurrentUser(arguments);

          if (firebaseUser == null) {
            throw FlutterFirebaseAuthPluginException.noUser();
          }

          // Wait for the user to reload, and send back the updated user
          Tasks.await(firebaseUser.reload());

          return parseFirebaseUser(getCurrentUser(arguments));
        });
  }

  private Task<Void> sendEmailVerification(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseUser firebaseUser = getCurrentUser(arguments);

          if (firebaseUser == null) {
            throw FlutterFirebaseAuthPluginException.noUser();
          }

          Object rawActionCodeSettings = arguments.get(Constants.ACTION_CODE_SETTINGS);
          if (rawActionCodeSettings == null) {
            return Tasks.await(firebaseUser.sendEmailVerification());
          }

          @SuppressWarnings("unchecked")
          Map<String, Object> actionCodeSettings = (Map<String, Object>) rawActionCodeSettings;

          return Tasks.await(
              firebaseUser.sendEmailVerification(getActionCodeSettings(actionCodeSettings)));
        });
  }

  private Task<Map<String, Object>> unlinkUserProvider(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseUser firebaseUser = getCurrentUser(arguments);

          if (firebaseUser == null) {
            throw FlutterFirebaseAuthPluginException.noUser();
          }

          String providerId = (String) Objects.requireNonNull(arguments.get(Constants.PROVIDER_ID));

          try {
            AuthResult result = Tasks.await(firebaseUser.unlink(providerId));
            return parseAuthResult(result);
          } catch (ExecutionException e) {
            // If the provider ID was not found an ExecutionException is thrown.
            // On web, this is automatically handled, so we catch the specific exception here
            // to ensure consistency.
            throw FlutterFirebaseAuthPluginException.noSuchProvider();
          }
        });
  }

  private Task<Map<String, Object>> updateEmail(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseUser firebaseUser = getCurrentUser(arguments);

          if (firebaseUser == null) {
            throw FlutterFirebaseAuthPluginException.noUser();
          }

          String newEmail = (String) Objects.requireNonNull(arguments.get(Constants.NEW_EMAIL));
          Tasks.await(firebaseUser.updateEmail(newEmail));
          Tasks.await(firebaseUser.reload());
          return parseFirebaseUser(firebaseUser);
        });
  }

  private Task<Map<String, Object>> updatePassword(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseUser firebaseUser = getCurrentUser(arguments);

          if (firebaseUser == null) {
            throw FlutterFirebaseAuthPluginException.noUser();
          }

          String newPassword =
              (String) Objects.requireNonNull(arguments.get(Constants.NEW_PASSWORD));
          Tasks.await(firebaseUser.updatePassword(newPassword));
          Tasks.await(firebaseUser.reload());
          return parseFirebaseUser(firebaseUser);
        });
  }

  private Task<Map<String, Object>> updatePhoneNumber(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseUser firebaseUser = getCurrentUser(arguments);

          if (firebaseUser == null) {
            throw FlutterFirebaseAuthPluginException.noUser();
          }

          PhoneAuthCredential phoneAuthCredential = (PhoneAuthCredential) getCredential(arguments);

          if (phoneAuthCredential == null) {
            throw FlutterFirebaseAuthPluginException.invalidCredential();
          }

          Tasks.await(firebaseUser.updatePhoneNumber(phoneAuthCredential));
          Tasks.await(firebaseUser.reload());
          return parseFirebaseUser(firebaseUser);
        });
  }

  private Task<Map<String, Object>> updateProfile(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseUser firebaseUser = getCurrentUser(arguments);

          if (firebaseUser == null) {
            throw FlutterFirebaseAuthPluginException.noUser();
          }

          @SuppressWarnings("unchecked")
          Map<String, String> profile =
              (Map<String, String>) Objects.requireNonNull(arguments.get(Constants.PROFILE));
          UserProfileChangeRequest.Builder builder = new UserProfileChangeRequest.Builder();

          if (profile.get(Constants.DISPLAY_NAME) != null) {
            builder.setDisplayName(profile.get(Constants.DISPLAY_NAME));
          }

          if (profile.get(Constants.PHOTO_URL) != null) {
            builder.setPhotoUri(Uri.parse(profile.get(Constants.PHOTO_URL)));
          }

          Tasks.await(firebaseUser.updateProfile(builder.build()));
          Tasks.await(firebaseUser.reload());
          return parseFirebaseUser(firebaseUser);
        });
  }

  private Task<Void> verifyBeforeUpdateEmail(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseUser firebaseUser = getCurrentUser(arguments);

          if (firebaseUser == null) {
            throw FlutterFirebaseAuthPluginException.noUser();
          }

          String newEmail = (String) Objects.requireNonNull(arguments.get(Constants.NEW_EMAIL));
          Object rawActionCodeSettings = arguments.get(Constants.ACTION_CODE_SETTINGS);

          if (rawActionCodeSettings == null) {
            return Tasks.await(firebaseUser.verifyBeforeUpdateEmail(newEmail));
          }

          @SuppressWarnings("unchecked")
          Map<String, Object> actionCodeSettings = (Map<String, Object>) rawActionCodeSettings;

          return Tasks.await(
              firebaseUser.verifyBeforeUpdateEmail(
                  newEmail, getActionCodeSettings(actionCodeSettings)));
        });
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    Task<?> methodCallTask;

    switch (call.method) {
      case "Auth#registerChangeListeners":
        methodCallTask = registerChangeListeners(call.arguments());
        break;
      case "Auth#applyActionCode":
        methodCallTask = applyActionCode(call.arguments());
        break;
      case "Auth#checkActionCode":
        methodCallTask = checkActionCode(call.arguments());
        break;
      case "Auth#confirmPasswordReset":
        methodCallTask = confirmPasswordReset(call.arguments());
        break;
      case "Auth#createUserWithEmailAndPassword":
        methodCallTask = createUserWithEmailAndPassword(call.arguments());
        break;
      case "Auth#fetchSignInMethodsForEmail":
        methodCallTask = fetchSignInMethodsForEmail(call.arguments());
        break;
      case "Auth#sendPasswordResetEmail":
        methodCallTask = sendPasswordResetEmail(call.arguments());
        break;
      case "Auth#sendSignInLinkToEmail":
        methodCallTask = sendSignInLinkToEmail(call.arguments());
        break;
      case "Auth#signInWithCredential":
        methodCallTask = signInWithCredential(call.arguments());
        break;
      case "Auth#setLanguageCode":
        methodCallTask = setLanguageCode(call.arguments());
        break;
      case "Auth#setSettings":
        methodCallTask = setSettings();
        break;
      case "Auth#signInAnonymously":
        methodCallTask = signInAnonymously(call.arguments());
        break;
      case "Auth#signInWithCustomToken":
        methodCallTask = signInWithCustomToken(call.arguments());
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
      case "Auth#useEmulator":
        methodCallTask = useEmulator(call.arguments());
        break;
      case "Auth#verifyPasswordResetCode":
        methodCallTask = verifyPasswordResetCode(call.arguments());
        break;
      case "Auth#verifyPhoneNumber":
        methodCallTask = verifyPhoneNumber(call.arguments());
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

  @Override
  public Task<Map<String, Object>> getPluginConstantsForFirebaseApp(FirebaseApp firebaseApp) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          Map<String, Object> constants = new HashMap<>();
          FirebaseAuth firebaseAuth = FirebaseAuth.getInstance(firebaseApp);
          FirebaseUser firebaseUser = firebaseAuth.getCurrentUser();
          String languageCode = firebaseAuth.getLanguageCode();

          Map<String, Object> user = firebaseUser == null ? null : parseFirebaseUser(firebaseUser);

          if (languageCode != null) {
            constants.put("APP_LANGUAGE_CODE", languageCode);
          }

          if (user != null) {
            constants.put("APP_CURRENT_USER", user);
          }

          return constants;
        });
  }

  private Map<String, Object> getExceptionDetails(Exception exception) {
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
    return Tasks.call(
        cachedThreadPool,
        () -> {
          removeEventListeners();
          authCredentials.clear();
          forceResendingTokens.clear();
          return null;
        });
  }
}
