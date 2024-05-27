/*
 * Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.auth;

import android.net.Uri;
import androidx.annotation.NonNull;
import com.google.firebase.auth.ActionCodeEmailInfo;
import com.google.firebase.auth.ActionCodeInfo;
import com.google.firebase.auth.ActionCodeResult;
import com.google.firebase.auth.ActionCodeSettings;
import com.google.firebase.auth.AdditionalUserInfo;
import com.google.firebase.auth.AuthCredential;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.EmailAuthProvider;
import com.google.firebase.auth.FacebookAuthProvider;
import com.google.firebase.auth.FirebaseAuthProvider;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.FirebaseUserMetadata;
import com.google.firebase.auth.GetTokenResult;
import com.google.firebase.auth.GithubAuthProvider;
import com.google.firebase.auth.GoogleAuthProvider;
import com.google.firebase.auth.MultiFactorInfo;
import com.google.firebase.auth.OAuthCredential;
import com.google.firebase.auth.OAuthProvider;
import com.google.firebase.auth.PhoneAuthProvider;
import com.google.firebase.auth.PhoneMultiFactorInfo;
import com.google.firebase.auth.PlayGamesAuthProvider;
import com.google.firebase.auth.TwitterAuthProvider;
import com.google.firebase.auth.UserInfo;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

public class PigeonParser {
  static List<Object> manuallyToList(
      GeneratedAndroidFirebaseAuth.PigeonUserDetails pigeonUserDetails) {
    List<Object> output = new ArrayList<>();
    output.add(pigeonUserDetails.getUserInfo().toList());
    output.add(pigeonUserDetails.getProviderData());
    return output;
  }

  static GeneratedAndroidFirebaseAuth.PigeonUserCredential parseAuthResult(
      @NonNull AuthResult authResult) {
    GeneratedAndroidFirebaseAuth.PigeonUserCredential.Builder builder =
        new GeneratedAndroidFirebaseAuth.PigeonUserCredential.Builder();

    builder.setAdditionalUserInfo(parseAdditionalUserInfo(authResult.getAdditionalUserInfo()));
    builder.setCredential(parseAuthCredential(authResult.getCredential()));
    builder.setUser(parseFirebaseUser(authResult.getUser()));

    return builder.build();
  }

  private static GeneratedAndroidFirebaseAuth.PigeonAdditionalUserInfo parseAdditionalUserInfo(
      AdditionalUserInfo additionalUserInfo) {
    if (additionalUserInfo == null) {
      return null;
    }

    GeneratedAndroidFirebaseAuth.PigeonAdditionalUserInfo.Builder builder =
        new GeneratedAndroidFirebaseAuth.PigeonAdditionalUserInfo.Builder();

    builder.setIsNewUser(additionalUserInfo.isNewUser());
    builder.setProfile(additionalUserInfo.getProfile());
    builder.setProviderId(additionalUserInfo.getProviderId());
    builder.setUsername(additionalUserInfo.getUsername());

    return builder.build();
  }

  static GeneratedAndroidFirebaseAuth.PigeonAuthCredential parseAuthCredential(
      AuthCredential authCredential) {
    if (authCredential == null) {
      return null;
    }

    int authCredentialHashCode = authCredential.hashCode();
    FlutterFirebaseAuthPlugin.authCredentials.put(authCredentialHashCode, authCredential);

    GeneratedAndroidFirebaseAuth.PigeonAuthCredential.Builder builder =
        new GeneratedAndroidFirebaseAuth.PigeonAuthCredential.Builder();

    builder.setProviderId(authCredential.getProvider());
    builder.setSignInMethod(authCredential.getSignInMethod());
    builder.setNativeId((long) authCredentialHashCode);
    if (authCredential instanceof OAuthCredential) {
      builder.setAccessToken(((OAuthCredential) authCredential).getAccessToken());
    }

    return builder.build();
  }

  static GeneratedAndroidFirebaseAuth.PigeonUserDetails parseFirebaseUser(
      FirebaseUser firebaseUser) {
    if (firebaseUser == null) {
      return null;
    }

    GeneratedAndroidFirebaseAuth.PigeonUserDetails.Builder builder =
        new GeneratedAndroidFirebaseAuth.PigeonUserDetails.Builder();

    GeneratedAndroidFirebaseAuth.PigeonUserInfo.Builder builderInfo =
        new GeneratedAndroidFirebaseAuth.PigeonUserInfo.Builder();

    builderInfo.setDisplayName(firebaseUser.getDisplayName());
    builderInfo.setEmail(firebaseUser.getEmail());
    builderInfo.setIsEmailVerified(firebaseUser.isEmailVerified());
    builderInfo.setIsAnonymous(firebaseUser.isAnonymous());

    final FirebaseUserMetadata userMetadata = firebaseUser.getMetadata();
    if (userMetadata != null) {
      builderInfo.setCreationTimestamp(firebaseUser.getMetadata().getCreationTimestamp());
      builderInfo.setLastSignInTimestamp(firebaseUser.getMetadata().getLastSignInTimestamp());
    }
    builderInfo.setPhoneNumber(firebaseUser.getPhoneNumber());
    builderInfo.setPhotoUrl(parsePhotoUrl(firebaseUser.getPhotoUrl()));
    builderInfo.setUid(firebaseUser.getUid());
    builderInfo.setTenantId(firebaseUser.getTenantId());

    builder.setUserInfo(builderInfo.build());
    builder.setProviderData(parseUserInfoList(firebaseUser.getProviderData()));

    return builder.build();
  }

  private static List<Map<Object, Object>> parseUserInfoList(
      List<? extends UserInfo> userInfoList) {
    List<Map<Object, Object>> output = new ArrayList<>();

    if (userInfoList == null) {
      return null;
    }

    for (UserInfo userInfo : new ArrayList<UserInfo>(userInfoList)) {
      if (userInfo == null) {
        continue;
      }
      if (!FirebaseAuthProvider.PROVIDER_ID.equals(userInfo.getProviderId())) {
        output.add(parseUserInfoToMap(userInfo));
      }
    }

    return output;
  }

  private static Map<Object, Object> parseUserInfoToMap(UserInfo userInfo) {
    Map<Object, Object> output = new HashMap<>();
    output.put("displayName", userInfo.getDisplayName());
    output.put("email", userInfo.getEmail());
    output.put("isEmailVerified", userInfo.isEmailVerified());
    output.put("phoneNumber", userInfo.getPhoneNumber());
    output.put("photoUrl", parsePhotoUrl(userInfo.getPhotoUrl()));
    // Can be null on Emulator
    output.put("uid", userInfo.getUid() == null ? "" : userInfo.getUid());
    output.put("providerId", userInfo.getProviderId());
    output.put("isAnonymous", false);
    return output;
  }

  private static String parsePhotoUrl(Uri photoUri) {
    if (photoUri == null) {
      return null;
    }

    String photoUrl = photoUri.toString();

    // Return null if the URL is an empty string
    return "".equals(photoUrl) ? null : photoUrl;
  }

  @SuppressWarnings("ConstantConditions")
  static AuthCredential getCredential(Map<String, Object> credentialMap) {
    // If the credential map contains a token, it means a native one has been stored
    if (credentialMap.get(Constants.TOKEN) != null) {
      int token = (int) credentialMap.get(Constants.TOKEN);
      AuthCredential credential = FlutterFirebaseAuthPlugin.authCredentials.get(token);

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
          if (accessToken != null) {
            builder.setAccessToken(accessToken);
          }
          if (rawNonce == null) {
            builder.setIdToken(Objects.requireNonNull(idToken));
          } else {
            builder.setIdTokenWithRawNonce(Objects.requireNonNull(idToken), rawNonce);
          }

          return builder.build();
        }
      case Constants.SIGN_IN_METHOD_PLAY_GAMES:
        {
          String serverAuthCode =
              (String) Objects.requireNonNull(credentialMap.get(Constants.SERVER_AUTH_CODE));
          return PlayGamesAuthProvider.getCredential(serverAuthCode);
        }
      default:
        return null;
    }
  }

  static ActionCodeSettings getActionCodeSettings(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonActionCodeSettings pigeonActionCodeSettings) {
    ActionCodeSettings.Builder builder = ActionCodeSettings.newBuilder();

    builder.setUrl(pigeonActionCodeSettings.getUrl());

    if (pigeonActionCodeSettings.getDynamicLinkDomain() != null) {
      builder.setDynamicLinkDomain(pigeonActionCodeSettings.getDynamicLinkDomain());
    }

    builder.setHandleCodeInApp(pigeonActionCodeSettings.getHandleCodeInApp());

    if (pigeonActionCodeSettings.getAndroidPackageName() != null) {
      builder.setAndroidPackageName(
          pigeonActionCodeSettings.getAndroidPackageName(),
          pigeonActionCodeSettings.getAndroidInstallApp(),
          pigeonActionCodeSettings.getAndroidMinimumVersion());
    }

    if (pigeonActionCodeSettings.getIOSBundleId() != null) {
      builder.setIOSBundleId(pigeonActionCodeSettings.getIOSBundleId());
    }

    return builder.build();
  }

  static List<GeneratedAndroidFirebaseAuth.PigeonMultiFactorInfo> multiFactorInfoToPigeon(
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

  static List<List<Object>> multiFactorInfoToMap(List<MultiFactorInfo> hints) {
    List<List<Object>> pigeonHints = new ArrayList<>();
    for (GeneratedAndroidFirebaseAuth.PigeonMultiFactorInfo info : multiFactorInfoToPigeon(hints)) {
      pigeonHints.add(info.toList());
    }
    return pigeonHints;
  }

  static GeneratedAndroidFirebaseAuth.PigeonActionCodeInfo parseActionCodeResult(
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

  static GeneratedAndroidFirebaseAuth.PigeonIdTokenResult parseTokenResult(
      @NonNull GetTokenResult tokenResult) {
    final GeneratedAndroidFirebaseAuth.PigeonIdTokenResult.Builder builder =
        new GeneratedAndroidFirebaseAuth.PigeonIdTokenResult.Builder();

    builder.setToken(tokenResult.getToken());
    builder.setSignInProvider(tokenResult.getSignInProvider());
    builder.setAuthTimestamp(tokenResult.getAuthTimestamp() * 1000);
    builder.setExpirationTimestamp(tokenResult.getExpirationTimestamp() * 1000);
    builder.setIssuedAtTimestamp(tokenResult.getIssuedAtTimestamp() * 1000);
    builder.setClaims(tokenResult.getClaims());
    builder.setSignInSecondFactor(tokenResult.getSignInSecondFactor());

    return builder.build();
  }
}
