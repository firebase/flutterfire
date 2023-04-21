package io.flutter.plugins.firebase.auth;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.tasks.Tasks;
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

  MultiFactor getAppMultiFactor(@NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app)
      throws FirebaseNoSignedInUserException {
    final FirebaseUser currentUser = FlutterFirebaseAuthUser.getCurrentUserFromPigeon(app);
    if (currentUser == null) {
      throw new FirebaseNoSignedInUserException("No user is signed in");
    }
    if (multiFactorUserMap.get(app.getAppName()) == null) {
      multiFactorUserMap.put(app.getAppName(), new HashMap<>());
    }

    final Map<String, MultiFactor> appMultiFactorUser = multiFactorUserMap.get(app.getAppName());
    if (appMultiFactorUser.get(currentUser.getUid()) == null) {
      appMultiFactorUser.put(currentUser.getUid(), currentUser.getMultiFactor());
    }

    final MultiFactor multiFactor = appMultiFactorUser.get(currentUser.getUid());
    return multiFactor;
  }

  @Override
  public void enrollPhone(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseAuth.PigeonPhoneMultiFactorAssertion assertion,
      @Nullable String displayName,
      @NonNull GeneratedAndroidFirebaseAuth.Result<Void> result) {
    final MultiFactor multiFactor;
    try {
      multiFactor = getAppMultiFactor(app);
    } catch (FirebaseNoSignedInUserException e) {
      result.error(e);
      return;
    }

    PhoneAuthCredential credential =
        PhoneAuthProvider.getCredential(
            assertion.getVerificationId(), assertion.getVerificationCode());

    MultiFactorAssertion multiFactorAssertion = PhoneMultiFactorGenerator.getAssertion(credential);

    try {
      Tasks.await(multiFactor.enroll(multiFactorAssertion, displayName));
      result.success(null);
    } catch (Exception e) {
      result.error(e);
    }
  }

  @Override
  public void getSession(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonMultiFactorSession>
              result) {
    final MultiFactor multiFactor;
    try {
      multiFactor = getAppMultiFactor(app);
    } catch (FirebaseNoSignedInUserException e) {
      result.error(e);
      return;
    }

    try {
      final MultiFactorSession sessionResult = Tasks.await(multiFactor.getSession());
      final String id = UUID.randomUUID().toString();
      multiFactorSessionMap.put(id, sessionResult);
      result.success(
          new GeneratedAndroidFirebaseAuth.PigeonMultiFactorSession.Builder().setId(id).build());
    } catch (Exception e) {
      result.error(e);
    }
  }

  @Override
  public void unenroll(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull String factorUid,
      @NonNull GeneratedAndroidFirebaseAuth.Result<Void> result) {
    final MultiFactor multiFactor;
    try {
      multiFactor = getAppMultiFactor(app);
    } catch (FirebaseNoSignedInUserException e) {
      result.error(e);
      return;
    }

    try {
      Tasks.await(multiFactor.unenroll(factorUid));
      result.success(null);
    } catch (Exception e) {
      result.error(e);
    }
  }

  @Override
  public void getEnrolledFactors(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<
                  List<GeneratedAndroidFirebaseAuth.PigeonMultiFactorInfo>>
              result) {
    final MultiFactor multiFactor;
    try {
      multiFactor = getAppMultiFactor(app);
    } catch (FirebaseNoSignedInUserException e) {
      result.error(e);
      return;
    }

    final List<MultiFactorInfo> factors = multiFactor.getEnrolledFactors();

    final List<GeneratedAndroidFirebaseAuth.PigeonMultiFactorInfo> resultFactors =
        PigeonParser.multiFactorInfoToPigeon(factors);

    result.success(resultFactors);
  }

  @Override
  public void resolveSignIn(
      @NonNull String resolverId,
      @NonNull GeneratedAndroidFirebaseAuth.PigeonPhoneMultiFactorAssertion assertion,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserCredential>
              result) {
    final MultiFactorResolver resolver = multiFactorResolverMap.get(resolverId);

    PhoneAuthCredential credential =
        PhoneAuthProvider.getCredential(
            assertion.getVerificationId(), assertion.getVerificationCode());

    MultiFactorAssertion multiFactorAssertion = PhoneMultiFactorGenerator.getAssertion(credential);

    try {
      final AuthResult authResult = Tasks.await(resolver.resolveSignIn(multiFactorAssertion));
      result.success(PigeonParser.parseAuthResult(authResult));
    } catch (Exception e) {
      result.error(e);
    }
  }
}
