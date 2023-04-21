package io.flutter.plugins.firebase.auth;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuthMultiFactorException;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.MultiFactor;
import com.google.firebase.auth.MultiFactorAssertion;
import com.google.firebase.auth.MultiFactorInfo;
import com.google.firebase.auth.MultiFactorResolver;
import com.google.firebase.auth.MultiFactorSession;
import com.google.firebase.auth.PhoneAuthCredential;
import com.google.firebase.auth.PhoneAuthProvider;
import com.google.firebase.auth.PhoneMultiFactorGenerator;
import com.google.firebase.internal.api.FirebaseNoSignedInUserException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public class FlutterFirebaseMultiFactor
    implements GeneratedAndroidFirebaseAuth.MultiFactorUserHostApi,
        GeneratedAndroidFirebaseAuth.MultiFactoResolverHostApi {

  // Map an app id to a map of user id to a MultiFactorUser object.
  static final Map<String, Map<String, MultiFactor>> multiFactorUserMap =
      new HashMap<String, Map<String, MultiFactor>>();

  // Map an id to a MultiFactorSession object.
  static final Map<String, MultiFactorSession> multiFactorSessionMap =
      new HashMap<String, MultiFactorSession>();

  // Map an id to a MultiFactorSession object.
  static final Map<String, MultiFactorResolver> multiFactorResolverMap =
      new HashMap<String, MultiFactorResolver>();

  public FlutterFirebaseMultiFactor() {}

  static void handleMultiFactorException(
      GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserCredential> result,
      Exception e) {
    final FirebaseAuthMultiFactorException multiFactorException =
        (FirebaseAuthMultiFactorException) e.getCause();
    Map<String, Object> output = new HashMap<String, Object>();

    assert multiFactorException != null;
    MultiFactorResolver multiFactorResolver = multiFactorException.getResolver();
    final List<MultiFactorInfo> hints = multiFactorResolver.getHints();

    final MultiFactorSession session = multiFactorResolver.getSession();
    final String sessionId = UUID.randomUUID().toString();
    multiFactorSessionMap.put(sessionId, session);

    final String resolverId = UUID.randomUUID().toString();
    multiFactorResolverMap.put(resolverId, multiFactorResolver);

    final List<List<Object>> pigeonHints = PigeonParser.multiFactorInfoToMap(hints);

    output.put(
        Constants.APP_NAME, FlutterFirebaseAuthPlugin.getAuthFromPigeon(app).getApp().getName());

    output.put(Constants.MULTI_FACTOR_HINTS, pigeonHints);

    output.put(Constants.MULTI_FACTOR_SESSION_ID, sessionId);
    output.put(Constants.MULTI_FACTOR_RESOLVER_ID, resolverId);

    result.error(
        new FlutterFirebaseAuthPluginException(
            multiFactorException.getErrorCode(),
            multiFactorException.getLocalizedMessage(),
            output));
  }

  MultiFactor getAppMultiFactor(@NonNull String appName) throws FirebaseNoSignedInUserException {
    final FirebaseUser currentUser = flutterFirebaseAuthPlugin.getCurrentUser(appName);
    if (currentUser == null) {
      throw new FirebaseNoSignedInUserException("No user is signed in");
    }
    if (multiFactorUserMap.get(appName) == null) {
      multiFactorUserMap.put(appName, new HashMap<String, MultiFactor>());
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
