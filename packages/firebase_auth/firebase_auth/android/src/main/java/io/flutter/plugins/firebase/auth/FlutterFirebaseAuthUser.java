package io.flutter.plugins.firebase.auth;

import androidx.annotation.NonNull;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.GetTokenResult;

public class FlutterFirebaseAuthUser
    implements GeneratedAndroidFirebaseAuth.FirebaseAuthUserHostApi {

  private FirebaseUser getCurrentUserFromPigeon(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp pigeonApp) {
    FirebaseApp app = FirebaseApp.getInstance(pigeonApp.getAppName());
    FirebaseAuth auth = FirebaseAuth.getInstance(app);
    if (pigeonApp.getTenantId() != null) {
      auth.setTenantId(pigeonApp.getTenantId());
    }

    return auth.getCurrentUser();
  }

  @Override
  public void delete(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseAuth.Result<Void> result) {
    try {
      FirebaseUser firebaseUser = getCurrentUserFromPigeon(app);

      if (firebaseUser == null) {
        result.error(FlutterFirebaseAuthPluginException.noUser());
        return;
      }

      Tasks.await(firebaseUser.delete());
      result.success(null);
    } catch (Exception e) {
      result.error(e);
    }
  }

  @Override
  public void getIdToken(
      @NonNull GeneratedAndroidFirebaseAuth.PigeonFirebaseApp app,
      @NonNull Boolean forceRefresh,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonIdTokenResult>
              result) {
    try {
      FirebaseUser firebaseUser = getCurrentUserFromPigeon(app);

      if (firebaseUser == null) {
        result.error(FlutterFirebaseAuthPluginException.noUser());
        return;
      }

      GetTokenResult tokenResult = Tasks.await(firebaseUser.getIdToken(forceRefresh));
      result.success(PigeonParser.parseTokenResult(tokenResult));
    } catch (Exception e) {
      result.error(e);
    }
  }
}
