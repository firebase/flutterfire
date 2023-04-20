package io.flutter.plugins.firebase.auth;

import android.net.Uri;
import androidx.annotation.NonNull;
import com.google.firebase.auth.AdditionalUserInfo;
import com.google.firebase.auth.AuthCredential;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuthProvider;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.FirebaseUserMetadata;
import com.google.firebase.auth.OAuthCredential;
import com.google.firebase.auth.UserInfo;
import java.util.ArrayList;
import java.util.List;

public class PigeonParser {
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

  private static List<GeneratedAndroidFirebaseAuth.PigeonUserInfo> parseUserInfoList(
      List<? extends UserInfo> userInfoList) {
    List<GeneratedAndroidFirebaseAuth.PigeonUserInfo> output = new ArrayList<>();

    if (userInfoList == null) {
      return null;
    }

    for (UserInfo userInfo : new ArrayList<UserInfo>(userInfoList)) {
      if (userInfo == null) {
        continue;
      }
      if (!FirebaseAuthProvider.PROVIDER_ID.equals(userInfo.getProviderId())) {
        output.add(parseUserInfo(userInfo));
      }
    }

    return output;
  }

  private static GeneratedAndroidFirebaseAuth.PigeonUserInfo parseUserInfo(
      @NonNull UserInfo userInfo) {
    GeneratedAndroidFirebaseAuth.PigeonUserInfo.Builder builderInfo =
        new GeneratedAndroidFirebaseAuth.PigeonUserInfo.Builder();

    builderInfo.setDisplayName(userInfo.getDisplayName());
    builderInfo.setEmail(userInfo.getEmail());
    builderInfo.setIsEmailVerified(userInfo.isEmailVerified());
    builderInfo.setPhoneNumber(userInfo.getPhoneNumber());
    builderInfo.setPhotoUrl(parsePhotoUrl(userInfo.getPhotoUrl()));
    builderInfo.setUid(userInfo.getUid());
    builderInfo.setProviderId(userInfo.getProviderId());

    return builderInfo.build();
  }

  private static String parsePhotoUrl(Uri photoUri) {
    if (photoUri == null) {
      return null;
    }

    String photoUrl = photoUri.toString();

    // Return null if the URL is an empty string
    return "".equals(photoUrl) ? null : photoUrl;
  }
}
