// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseauth;

import android.app.Activity;
import android.net.Uri;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseException;
import com.google.firebase.auth.ActionCodeEmailInfo;
import com.google.firebase.auth.ActionCodeInfo;
import com.google.firebase.auth.ActionCodeMultiFactorInfo;
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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.TimeUnit;

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

import static io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry.registerPlugin;

/** Flutter plugin for Firebase Auth. */
public class FirebaseAuthPlugin
    implements FlutterFirebasePlugin, MethodCallHandler, FlutterPlugin, ActivityAware {

  // Stores the instances of native AuthCredentials by their hashCode
  static final HashMap<Integer, AuthCredential> mAuthCredentials = new HashMap<>();

  private static final String TAG = "FirebaseAuthPlugin";
  private static final HashMap<String, FirebaseAuth.AuthStateListener> mAuthListeners =
      new HashMap<>();
  private static final HashMap<String, FirebaseAuth.IdTokenListener> mIdTokenListeners =
      new HashMap<>();
  private static final HashMap<Integer, PhoneAuthProvider.ForceResendingToken>
      mForceResendingTokens = new HashMap<>();
  private PluginRegistry.Registrar registrar;
  private MethodChannel channel;
  private Activity activity;

  @SuppressWarnings("unused")
  public static void registerWith(PluginRegistry.Registrar registrar) {
    FirebaseAuthPlugin instance = new FirebaseAuthPlugin();
    instance.registrar = registrar;
    instance.initInstance(registrar.messenger());
  }

  static Map<String, Object> parseAuthCredential(AuthCredential authCredential) {
    if (authCredential == null) {
      return null;
    }

    int authCredentialHashCode = authCredential.hashCode();
    mAuthCredentials.put(authCredentialHashCode, authCredential);

    Map<String, Object> output = new HashMap<>();

    output.put("providerId", authCredential.getProvider());
    output.put("signInMethod", authCredential.getSignInMethod());
    output.put("token", authCredentialHashCode);

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
    Iterator<?> authListenerIterator = mAuthListeners.entrySet().iterator();

    while (authListenerIterator.hasNext()) {
      Map.Entry<?, ?> pair = (Map.Entry<?, ?>) authListenerIterator.next();
      String appName = (String) pair.getKey();
      FirebaseApp firebaseApp = FirebaseApp.getInstance(appName);
      FirebaseAuth firebaseAuth = FirebaseAuth.getInstance(firebaseApp);
      FirebaseAuth.AuthStateListener mAuthListener =
          (FirebaseAuth.AuthStateListener) pair.getValue();
      firebaseAuth.removeAuthStateListener(mAuthListener);
      authListenerIterator.remove();
    }

    Iterator<?> idTokenListenerIterator = mIdTokenListeners.entrySet().iterator();

    while (idTokenListenerIterator.hasNext()) {
      Map.Entry<?, ?> pair = (Map.Entry<?, ?>) idTokenListenerIterator.next();
      String appName = (String) pair.getKey();
      FirebaseApp firebaseApp = FirebaseApp.getInstance(appName);
      FirebaseAuth firebaseAuth = FirebaseAuth.getInstance(firebaseApp);
      FirebaseAuth.IdTokenListener mAuthListener = (FirebaseAuth.IdTokenListener) pair.getValue();
      firebaseAuth.removeIdTokenListener(mAuthListener);
      idTokenListenerIterator.remove();
    }
  }

  // Only access activity with this method.
  private Activity getActivity() {
    return registrar != null ? registrar.activity() : activity;
  }

  private FirebaseAuth getAuth(Map<String, Object> arguments) {
    String appName = (String) arguments.get("appName");
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
        Log.e(TAG, method + " error (" + errorCode + "): " + errorMessage);
      }

      @Override
      public void notImplemented() {
        Log.e(TAG, method + " has not been implemented");
      }
    };
  }

  private FirebaseUser getCurrentUser(Map<String, Object> arguments) {
    String appName = (String) arguments.get("appName");
    FirebaseApp app = FirebaseApp.getInstance(appName);
    return FirebaseAuth.getInstance(app).getCurrentUser();
  }

  private AuthCredential getCredential(Map<String, Object> arguments)
      throws FirebaseAuthPluginException {
    //noinspection unchecked
    Map<String, Object> credentialMap = (Map<String, Object>) arguments.get("credential");

    // If the credential map contains a token, it means a native one has been stored
    if (credentialMap.get("token") != null) {
      int token = (int) credentialMap.get("token");
      AuthCredential credential = mAuthCredentials.get(token);

      if (credential == null) {
        throw FirebaseAuthPluginException.invalidCredential();
      }

      return credential;
    }

    String providerId = (String) credentialMap.get("providerId");
    String secret = (String) credentialMap.get("secret");
    String idToken = (String) credentialMap.get("idToken");
    String accessToken = (String) credentialMap.get("accessToken");
    String rawNonce = (String) credentialMap.get("rawNonce");

    switch (providerId) {
      case "password":
        return EmailAuthProvider.getCredential((String) credentialMap.get("email"), secret);
      case "emailLink":
        return EmailAuthProvider.getCredentialWithLink(
            (String) credentialMap.get("email"), (String) credentialMap.get("emailLink"));
      case "facebook.com":
        return FacebookAuthProvider.getCredential(accessToken);
      case "google.com":
        return GoogleAuthProvider.getCredential(idToken, accessToken);
      case "twitter.com":
        return TwitterAuthProvider.getCredential(accessToken, secret);
      case "github.com":
        return GithubAuthProvider.getCredential(accessToken);
      case "phone":
        {
          String verificationId =
              (String) Objects.requireNonNull(credentialMap.get("verificationId"));
          String smsCode = (String) Objects.requireNonNull(credentialMap.get("smsCode"));
          return PhoneAuthProvider.getCredential(verificationId, smsCode);
        }
      case "oauth":
        {
          OAuthProvider.CredentialBuilder builder = OAuthProvider.newCredentialBuilder(providerId);
          builder.setAccessToken(accessToken);

          if (rawNonce == null) {
            builder.setIdToken(idToken);
          } else {
            builder.setIdTokenWithRawNonce(idToken, rawNonce);
          }

          return builder.build();
        }
      default:
        return null;
    }
  }

  private Map<String, Object> parseActionCodeResult(@NonNull ActionCodeResult actionCodeResult) {
    Map<String, Object> output = new HashMap<>();
    Map<String, Object> data = new HashMap<>();

    int operation = actionCodeResult.getOperation();
    output.put("operation", operation);

    if (operation == ActionCodeResult.VERIFY_EMAIL
        || operation == ActionCodeResult.PASSWORD_RESET) {
      ActionCodeInfo actionCodeInfo = actionCodeResult.getInfo();
      data.put("email", actionCodeInfo.getEmail());
      data.put("previousEmail", null);
      //      data.put("multiFactorInfo", null);
    } else if (operation == ActionCodeResult.REVERT_SECOND_FACTOR_ADDITION) {
      ActionCodeMultiFactorInfo actionCodeMultiFactorInfo =
          (ActionCodeMultiFactorInfo) actionCodeResult.getInfo();
      data.put("email", null);
      data.put("previousEmail", null);
      //      data.put(
      //          "multiFactorInfo",
      // parseMultiFactorInfo(actionCodeMultiFactorInfo.getMultiFactorInfo()));
    } else if (operation == ActionCodeResult.RECOVER_EMAIL
        || operation == ActionCodeResult.VERIFY_BEFORE_CHANGE_EMAIL) {
      ActionCodeEmailInfo actionCodeEmailInfo = (ActionCodeEmailInfo) actionCodeResult.getInfo();
      data.put("email", actionCodeEmailInfo.getEmail());
      data.put("previousEmail", actionCodeEmailInfo.getPreviousEmail());
      //      data.put("multiFactorInfo", null);
    }

    output.put("data", data);
    return output;
  }

  //  private Map<String, Object> parseMultiFactorInfo(@NonNull MultiFactorInfo multiFactorInfo) {
  //    Map<String, Object> output = new HashMap<>();
  //
  //    output.put("displayName", multiFactorInfo.getDisplayName());
  //    output.put("enrollmentTimestamp", multiFactorInfo.getEnrollmentTimestamp() * 1000);
  //    output.put("factorId", multiFactorInfo.getFactorId());
  //    output.put("uid", multiFactorInfo.getUid());
  //
  //    return output;
  //  }

  private Map<String, Object> parseAuthResult(@NonNull AuthResult authResult) {
    Map<String, Object> output = new HashMap<>();

    output.put("additionalUserInfo", parseAdditionalUserInfo(authResult.getAdditionalUserInfo()));
    output.put("authCredential", parseAuthCredential(authResult.getCredential()));
    output.put("user", parseFirebaseUser(authResult.getUser()));

    return output;
  }

  private Map<String, Object> parseAdditionalUserInfo(AdditionalUserInfo additionalUserInfo) {
    if (additionalUserInfo == null) {
      return null;
    }

    Map<String, Object> output = new HashMap<>();

    output.put("isNewUser", additionalUserInfo.isNewUser());
    output.put("profile", additionalUserInfo.getProfile());
    output.put("providerId", additionalUserInfo.getProviderId());
    output.put("username", additionalUserInfo.getUsername());

    return output;
  }

  private Map<String, Object> parseFirebaseUser(FirebaseUser firebaseUser) {
    if (firebaseUser == null) {
      return null;
    }

    Map<String, Object> output = new HashMap<>();
    Map<String, Object> metadata = new HashMap<>();

    output.put("displayName", firebaseUser.getDisplayName());
    output.put("email", firebaseUser.getEmail());
    output.put("emailVerified", firebaseUser.isEmailVerified());
    output.put("isAnonymous", firebaseUser.isAnonymous());

    metadata.put("creationTime", firebaseUser.getMetadata().getCreationTimestamp());
    metadata.put("lastSignInTime", firebaseUser.getMetadata().getLastSignInTimestamp());
    output.put("metadata", metadata);
    output.put("phoneNumber", firebaseUser.getPhoneNumber());
    output.put("photoURL", parsePhotoUrl(firebaseUser.getPhotoUrl()));
    output.put("providerData", parseUserInfoList(firebaseUser.getProviderData()));
    output.put("refreshToken", ""); // native does not provide refresh tokens
    output.put("uid", firebaseUser.getUid());

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

  private Map<String, Object> parseUserInfo(@NonNull UserInfo userInfo) {
    Map<String, Object> output = new HashMap<>();

    output.put("displayName", userInfo.getDisplayName());
    output.put("email", userInfo.getEmail());
    output.put("phoneNumber", userInfo.getPhoneNumber());
    output.put("photoURL", parsePhotoUrl(userInfo.getPhotoUrl()));
    output.put("providerId", userInfo.getProviderId());
    output.put("uid", userInfo.getUid());

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

    builder.setUrl((String) actionCodeSettingsMap.get("url"));

    if (actionCodeSettingsMap.get("dynamicLinkDomain") != null) {
      builder.setDynamicLinkDomain((String) actionCodeSettingsMap.get("dynamicLinkDomain"));
    }

    if (actionCodeSettingsMap.get("handleCodeInApp") != null) {
      builder.setHandleCodeInApp((Boolean) actionCodeSettingsMap.get("handleCodeInApp"));
    }

    if (actionCodeSettingsMap.get("android") != null) {
      @SuppressWarnings("unchecked")
      Map<String, Object> android = (Map<String, Object>) actionCodeSettingsMap.get("android");
      Boolean installIfNotAvailable = false;
      if (android.get("installApp") != null) {
        installIfNotAvailable = (Boolean) android.get("installApp");
      }
      String minimumVersion = null;
      if (android.get("minimumVersion") != null) {
        minimumVersion = (String) android.get("minimumVersion");
      }

      builder.setAndroidPackageName(
          (String) android.get("packageName"), installIfNotAvailable, minimumVersion);
    }

    if (actionCodeSettingsMap.get("iOS") != null) {
      @SuppressWarnings("unchecked")
      Map<String, Object> iOS = (Map<String, Object>) actionCodeSettingsMap.get("iOS");
      builder.setIOSBundleId((String) iOS.get("bundleId"));
    }

    return builder.build();
  }

  private Map<String, Object> parseTokenResult(@NonNull GetTokenResult tokenResult) {
    Map<String, Object> output = new HashMap<>();

    output.put("authTimestamp", tokenResult.getAuthTimestamp() * 1000);
    output.put("claims", tokenResult.getClaims());
    output.put("expirationTimestamp", tokenResult.getExpirationTimestamp() * 1000);
    output.put("issuedAtTimestamp", tokenResult.getIssuedAtTimestamp() * 1000);
    output.put("signInProvider", tokenResult.getSignInProvider());
    output.put("signInSecondFactor", tokenResult.getSignInSecondFactor());
    output.put("token", tokenResult.getToken());

    return output;
  }

  private Task<Void> registerChangeListeners(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          String appName = (String) Objects.requireNonNull(arguments.get("appName"));
          FirebaseAuth firebaseAuth = getAuth(arguments);

          FirebaseAuth.AuthStateListener authStateListener = mAuthListeners.get(appName);
          FirebaseAuth.IdTokenListener idTokenListener = mIdTokenListeners.get(appName);

          Map<String, Object> event = new HashMap<>();
          event.put("appName", appName);

          if (authStateListener == null) {
            FirebaseAuth.AuthStateListener newAuthStateListener =
                auth -> {
                  FirebaseUser user = auth.getCurrentUser();

                  if (user == null) {
                    event.put("user", null);
                  } else {
                    event.put("user", parseFirebaseUser(user));
                  }

                  channel.invokeMethod(
                      "Auth#authStateChanges",
                      event,
                      getMethodChannelResultHandler("Auth#authStateChanges"));
                };

            firebaseAuth.addAuthStateListener(newAuthStateListener);
            mAuthListeners.put(appName, newAuthStateListener);
          }

          if (idTokenListener == null) {
            FirebaseAuth.IdTokenListener newIdTokenChangeListener =
                auth -> {
                  FirebaseUser user = auth.getCurrentUser();

                  if (user == null) {
                    event.put("user", null);
                  } else {
                    event.put("user", parseFirebaseUser(user));
                  }

                  channel.invokeMethod(
                      "Auth#idTokenChanges",
                      event,
                      getMethodChannelResultHandler("Auth#idTokenChanges"));
                };

            firebaseAuth.addIdTokenListener(newIdTokenChangeListener);
            mIdTokenListeners.put(appName, newIdTokenChangeListener);
          }

          return null;
        });
  }

  private Task<Void> applyActionCode(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseAuth firebaseAuth = getAuth(arguments);
          String code = (String) Objects.requireNonNull(arguments.get("code"));

          return Tasks.await(firebaseAuth.applyActionCode(code));
        });
  }

  private Task<Map<String, Object>> checkActionCode(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseAuth firebaseAuth = getAuth(arguments);
          String code = (String) Objects.requireNonNull(arguments.get("code"));

          ActionCodeResult actionCodeResult = Tasks.await(firebaseAuth.checkActionCode(code));
          return parseActionCodeResult(actionCodeResult);
        });
  }

  private Task<Void> confirmPasswordReset(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseAuth firebaseAuth = getAuth(arguments);
          String code = (String) Objects.requireNonNull(arguments.get("code"));
          String newPassword = (String) Objects.requireNonNull(arguments.get("newPassword"));

          return Tasks.await(firebaseAuth.confirmPasswordReset(code, newPassword));
        });
  }

  private Task<Map<String, Object>> createUserWithEmailAndPassword(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseAuth firebaseAuth = getAuth(arguments);
          String email = (String) Objects.requireNonNull(arguments.get("email"));
          String password = (String) Objects.requireNonNull(arguments.get("password"));

          AuthResult authResult =
              Tasks.await(firebaseAuth.createUserWithEmailAndPassword(email, password));

          return parseAuthResult(authResult);
        });
  }

  private Task<Map<String, Object>> fetchSignInMethodsForEmail(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseAuth firebaseAuth = getAuth(arguments);
          String email = (String) Objects.requireNonNull(arguments.get("email"));

          SignInMethodQueryResult result =
              Tasks.await(firebaseAuth.fetchSignInMethodsForEmail(email));

          Map<String, Object> output = new HashMap<>();
          output.put("providers", result.getSignInMethods());

          return output;
        });
  }

  private Task<Void> sendPasswordResetEmail(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseAuth firebaseAuth = getAuth(arguments);
          String email = (String) Objects.requireNonNull(arguments.get("email"));
          Object rawActionCodeSettings = arguments.get("actionCodeSettings");

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

  private Task<String> setLanguageCode(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseAuth firebaseAuth = getAuth(arguments);
          String languageCode = (String) arguments.get("languageCode");

          if (languageCode == null) {
            firebaseAuth.useAppLanguage();
          } else {
            firebaseAuth.setLanguageCode(languageCode);
          }

          return firebaseAuth.getLanguageCode();
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
            throw FirebaseAuthPluginException.invalidCredential();
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
          String token = (String) Objects.requireNonNull(arguments.get("token"));

          AuthResult authResult = Tasks.await(firebaseAuth.signInWithCustomToken(token));
          return parseAuthResult(authResult);
        });
  }

  private Task<Map<String, Object>> signInWithEmailAndPassword(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseAuth firebaseAuth = getAuth(arguments);
          String email = (String) Objects.requireNonNull(arguments.get("email"));
          String password = (String) Objects.requireNonNull(arguments.get("password"));

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
          String email = (String) Objects.requireNonNull(arguments.get("email"));
          String emailLink = (String) Objects.requireNonNull(arguments.get("emailLink"));

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

  private Task<Map<String, Object>> verifyPasswordResetCode(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseAuth firebaseAuth = getAuth(arguments);
          String code = (String) Objects.requireNonNull(arguments.get("code"));

          Map<String, Object> output = new HashMap<>();
          output.put("code", Tasks.await(firebaseAuth.verifyPasswordResetCode(code)));
          return output;
        });
  }

  private Task<Void> verifyPhoneNumber(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseAuth firebaseAuth = getAuth(arguments);
          String phoneNumber = (String) Objects.requireNonNull(arguments.get("phoneNumber"));
          int handle = (int) Objects.requireNonNull(arguments.get("handle"));
          int timeout = (int) Objects.requireNonNull(arguments.get("timeout"));
          boolean requireSmsValidation =
              (boolean) Objects.requireNonNull(arguments.get("requireSmsValidation"));

          Map<String, Object> event = new HashMap<>();
          event.put("handle", handle);

          PhoneAuthProvider.OnVerificationStateChangedCallbacks callbacks =
              new PhoneAuthProvider.OnVerificationStateChangedCallbacks() {
                @Override
                public void onVerificationCompleted(
                    @NonNull PhoneAuthCredential phoneAuthCredential) {
                  int phoneAuthCredentialHashCode = phoneAuthCredential.hashCode();
                  mAuthCredentials.put(phoneAuthCredentialHashCode, phoneAuthCredential);
                  event.put("token", phoneAuthCredentialHashCode);

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
                  mForceResendingTokens.put(forceResendingTokenHashCode, token);
                  event.put("verificationId", verificationId);
                  event.put("forceResendingToken", forceResendingTokenHashCode);

                  channel.invokeMethod(
                      "Auth#phoneCodeSent",
                      event,
                      getMethodChannelResultHandler("Auth#phoneCodeSent"));
                }

                @Override
                public void onCodeAutoRetrievalTimeOut(@NonNull String verificationId) {
                  event.put("verificationId", verificationId);

                  channel.invokeMethod(
                      "Auth#phoneCodeAutoRetrievalTimeout",
                      event,
                      getMethodChannelResultHandler("Auth#phoneCodeAutoRetrievalTimeout"));
                }
              };

          PhoneAuthOptions.Builder phoneAuthOptionsBuilder =
              new PhoneAuthOptions.Builder(firebaseAuth);
          phoneAuthOptionsBuilder.setActivity(getActivity());
          phoneAuthOptionsBuilder.setPhoneNumber(phoneNumber);
          phoneAuthOptionsBuilder.setCallbacks(callbacks);
          phoneAuthOptionsBuilder.setTimeout((long) timeout, TimeUnit.MILLISECONDS);
          phoneAuthOptionsBuilder.requireSmsValidation(requireSmsValidation);

          if (arguments.get("forceResendingToken") != null) {
            int forceResendingTokenHashCode =
                (int) Objects.requireNonNull(arguments.get("forceResendingToken"));

            PhoneAuthProvider.ForceResendingToken forceResendingToken =
                mForceResendingTokens.get(forceResendingTokenHashCode);

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
            throw FirebaseAuthPluginException.noUser();
          }

          return Tasks.await(firebaseUser.delete());
        });
  }

  private Task<Object> getIdToken(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseUser firebaseUser = getCurrentUser(arguments);
          Boolean forceRefresh = (Boolean) Objects.requireNonNull(arguments.get("forceRefresh"));
          Boolean tokenOnly = (Boolean) Objects.requireNonNull(arguments.get("tokenOnly"));

          if (firebaseUser == null) {
            throw FirebaseAuthPluginException.noUser();
          }

          GetTokenResult tokenResult = Tasks.await(firebaseUser.getIdToken(forceRefresh));

          if (tokenOnly) {
            return tokenResult.getToken();
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
            throw FirebaseAuthPluginException.noUser();
          }

          if (credential == null) {
            throw FirebaseAuthPluginException.invalidCredential();
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
            throw FirebaseAuthPluginException.noUser();
          }

          if (credential == null) {
            throw FirebaseAuthPluginException.invalidCredential();
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
            throw FirebaseAuthPluginException.noUser();
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
            throw FirebaseAuthPluginException.noUser();
          }

          Object rawActionCodeSettings = arguments.get("actionCodeSettings");
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
            throw FirebaseAuthPluginException.noUser();
          }

          String providerId = (String) Objects.requireNonNull(arguments.get("providerId"));
          AuthResult result = Tasks.await(firebaseUser.unlink(providerId));
          return parseAuthResult(result);
        });
  }

  private Task<Map<String, Object>> updateEmail(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseUser firebaseUser = getCurrentUser(arguments);

          if (firebaseUser == null) {
            throw FirebaseAuthPluginException.noUser();
          }

          String newEmail = (String) Objects.requireNonNull(arguments.get("newEmail"));
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
            throw FirebaseAuthPluginException.noUser();
          }

          String newPassword = (String) Objects.requireNonNull(arguments.get("newPassword"));
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
            throw FirebaseAuthPluginException.noUser();
          }

          PhoneAuthCredential phoneAuthCredential = (PhoneAuthCredential) getCredential(arguments);
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
            throw FirebaseAuthPluginException.noUser();
          }

          @SuppressWarnings("unchecked")
          Map<String, String> profile =
              (Map<String, String>) Objects.requireNonNull(arguments.get("profile"));
          UserProfileChangeRequest.Builder builder = new UserProfileChangeRequest.Builder();

          if (profile.get("displayName") != null) {
            builder.setDisplayName(profile.get("displayName"));
          }

          if (profile.get("photoURL") != null) {
            builder.setPhotoUri(Uri.parse(profile.get("photoURL")));
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
            throw FirebaseAuthPluginException.noUser();
          }

          String newEmail = (String) Objects.requireNonNull(arguments.get("newEmail"));
          Object rawActionCodeSettings = arguments.get("actionCodeSettings");

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

    FirebaseAuthPluginException authException = null;

    if (exception instanceof FirebaseAuthException) {
      authException =
          new FirebaseAuthPluginException((FirebaseAuthException) exception, exception.getCause());
    } else if (exception.getCause() != null
        && exception.getCause() instanceof FirebaseAuthException) {
      authException =
          new FirebaseAuthPluginException(
              (FirebaseAuthException) exception.getCause(),
              exception.getCause().getCause() != null
                  ? exception.getCause().getCause()
                  : exception.getCause());
    } else if (exception instanceof FirebaseAuthPluginException) {
      authException = (FirebaseAuthPluginException) exception;
    }

    if (authException != null) {
      details.put("code", authException.getCode());
      details.put("message", authException.getMessage());
      details.put("additionalData", authException.getAdditionalData());
    }

    return details;
  }
}
