/*
 * Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.auth;

import static io.flutter.plugins.firebase.core.FlutterFirebasePlugin.cachedThreadPool;

import android.app.Activity;
import android.net.Uri;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.auth.AuthCredential;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.GetTokenResult;
import com.google.firebase.auth.OAuthProvider;
import com.google.firebase.auth.PhoneAuthCredential;
import com.google.firebase.auth.UserProfileChangeRequest;
import java.util.Map;

public class FlutterFirebaseAuthUser
    implements GeneratedAndroidFirebaseAuth.FirebaseAuthUserHostApi {

  private Activity activity;

  public void setActivity(Activity activity) {
    this.activity = activity;
  }

  public static FirebaseUser getCurrentUserFromPigeon(
      @NonNull GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp pigeonApp) {
    FirebaseApp app = FirebaseApp.getInstance(pigeonApp.getAppName());
    FirebaseAuth auth = FirebaseAuth.getInstance(app);
    if (pigeonApp.getTenantId() != null) {
      auth.setTenantId(pigeonApp.getTenantId());
    }

    return auth.getCurrentUser();
  }

  @Override
  public void delete(
      @NonNull GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseAuth.VoidResult result) {
    FirebaseUser firebaseUser = getCurrentUserFromPigeon(app);

    if (firebaseUser == null) {
      result.error(FlutterFirebaseAuthPluginException.noUser());
      return;
    }

    firebaseUser
        .delete()
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                result.success();
              } else {
                result.error(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                        task.getException()));
              }
            });
  }

  @Override
  public void getIdToken(
      @NonNull GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp app,
      @NonNull Boolean forceRefresh,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonIdTokenResult>
              result) {
    cachedThreadPool.execute(
        () -> {
          FirebaseUser firebaseUser = getCurrentUserFromPigeon(app);

          if (firebaseUser == null) {
            result.error(FlutterFirebaseAuthPluginException.noUser());
            return;
          }
          try {
            GetTokenResult response = Tasks.await(firebaseUser.getIdToken(forceRefresh));
            result.success(PigeonParser.parseTokenResult(response));
          } catch (Exception exception) {
            result.error(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(exception));
          }
        });
  }

  @Override
  public void linkWithCredential(
      @NonNull GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp app,
      @NonNull Map<String, Object> input,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserCredential>
              result) {
    FirebaseUser firebaseUser = getCurrentUserFromPigeon(app);
    AuthCredential credential = PigeonParser.getCredential(input);

    if (firebaseUser == null) {
      result.error(FlutterFirebaseAuthPluginException.noUser());
      return;
    }

    if (credential == null) {
      result.error(FlutterFirebaseAuthPluginException.invalidCredential());
      return;
    }

    firebaseUser
        .linkWithCredential(credential)
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
  public void linkWithProvider(
      @NonNull GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseAuth.PigeonSignInProvider signInProvider,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserCredential>
              result) {
    FirebaseUser firebaseUser = getCurrentUserFromPigeon(app);

    OAuthProvider.Builder provider = OAuthProvider.newBuilder(signInProvider.getProviderId());
    if (signInProvider.getScopes() != null) {
      provider.setScopes(signInProvider.getScopes());
    }
    if (signInProvider.getCustomParameters() != null) {
      provider.addCustomParameters(signInProvider.getCustomParameters());
    }

    firebaseUser
        .startActivityForLinkWithProvider(activity, provider.build())
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
  public void reauthenticateWithCredential(
      @NonNull GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp app,
      @NonNull Map<String, Object> input,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserCredential>
              result) {
    FirebaseUser firebaseUser = getCurrentUserFromPigeon(app);
    AuthCredential credential = PigeonParser.getCredential(input);

    if (firebaseUser == null) {
      result.error(FlutterFirebaseAuthPluginException.noUser());
      return;
    }

    if (credential == null) {
      result.error(FlutterFirebaseAuthPluginException.invalidCredential());
      return;
    }

    firebaseUser
        .reauthenticateAndRetrieveData(credential)
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
  public void reauthenticateWithProvider(
      @NonNull GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseAuth.PigeonSignInProvider signInProvider,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserCredential>
              result) {
    FirebaseUser firebaseUser = getCurrentUserFromPigeon(app);

    OAuthProvider.Builder provider = OAuthProvider.newBuilder(signInProvider.getProviderId());
    if (signInProvider.getScopes() != null) {
      provider.setScopes(signInProvider.getScopes());
    }
    if (signInProvider.getCustomParameters() != null) {
      provider.addCustomParameters(signInProvider.getCustomParameters());
    }

    firebaseUser
        .startActivityForReauthenticateWithProvider(activity, provider.build())
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
  public void reload(
      @NonNull GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp app,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserDetails>
              result) {
    FirebaseUser firebaseUser = getCurrentUserFromPigeon(app);

    if (firebaseUser == null) {
      result.error(FlutterFirebaseAuthPluginException.noUser());
      return;
    }

    firebaseUser
        .reload()
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                result.success(PigeonParser.parseFirebaseUser(firebaseUser));
              } else {
                result.error(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                        task.getException()));
              }
            });
  }

  @Override
  public void sendEmailVerification(
      @NonNull GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp app,
      @Nullable GeneratedAndroidFirebaseAuth.PigeonActionCodeSettings actionCodeSettings,
      @NonNull GeneratedAndroidFirebaseAuth.VoidResult result) {
    FirebaseUser firebaseUser = getCurrentUserFromPigeon(app);

    if (firebaseUser == null) {
      result.error(FlutterFirebaseAuthPluginException.noUser());
      return;
    }

    if (actionCodeSettings == null) {
      firebaseUser
          .sendEmailVerification()
          .addOnCompleteListener(
              task -> {
                if (task.isSuccessful()) {
                  result.success();
                } else {
                  result.error(
                      FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                          task.getException()));
                }
              });
      return;
    }

    firebaseUser
        .sendEmailVerification(PigeonParser.getActionCodeSettings(actionCodeSettings))
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                result.success();
              } else {
                result.error(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                        task.getException()));
              }
            });
  }

  @Override
  public void unlink(
      @NonNull GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp app,
      @NonNull String providerId,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserCredential>
              result) {
    FirebaseUser firebaseUser = getCurrentUserFromPigeon(app);

    if (firebaseUser == null) {
      result.error(FlutterFirebaseAuthPluginException.noUser());
      return;
    }

    firebaseUser
        .unlink(providerId)
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                result.success(PigeonParser.parseAuthResult(task.getResult()));
              } else {
                Exception exception = task.getException();
                if (exception
                    .getMessage()
                    .contains("User was not linked to an account with the given provider.")) {
                  result.error(FlutterFirebaseAuthPluginException.noSuchProvider());
                } else {
                  result.error(
                      FlutterFirebaseAuthPluginException.parserExceptionToFlutter(exception));
                }
              }
            });
  }

  @Override
  public void updateEmail(
      @NonNull GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp app,
      @NonNull String newEmail,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserDetails>
              result) {
    FirebaseUser firebaseUser = getCurrentUserFromPigeon(app);

    if (firebaseUser == null) {
      result.error(FlutterFirebaseAuthPluginException.noUser());
      return;
    }

    firebaseUser
        .updateEmail(newEmail)
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                firebaseUser
                    .reload()
                    .addOnCompleteListener(
                        reloadTask -> {
                          if (reloadTask.isSuccessful()) {
                            result.success(PigeonParser.parseFirebaseUser(firebaseUser));
                          } else {
                            result.error(
                                FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                                    reloadTask.getException()));
                          }
                        });
              } else {
                result.error(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                        task.getException()));
              }
            });
  }

  @Override
  public void updatePassword(
      @NonNull GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp app,
      @NonNull String newPassword,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserDetails>
              result) {
    FirebaseUser firebaseUser = getCurrentUserFromPigeon(app);

    if (firebaseUser == null) {
      result.error(FlutterFirebaseAuthPluginException.noUser());
      return;
    }

    firebaseUser
        .updatePassword(newPassword)
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                firebaseUser
                    .reload()
                    .addOnCompleteListener(
                        reloadTask -> {
                          if (reloadTask.isSuccessful()) {
                            result.success(PigeonParser.parseFirebaseUser(firebaseUser));
                          } else {
                            result.error(
                                FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                                    reloadTask.getException()));
                          }
                        });
              } else {
                result.error(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                        task.getException()));
              }
            });
  }

  @Override
  public void updatePhoneNumber(
      @NonNull GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp app,
      @NonNull Map<String, Object> input,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserDetails>
              result) {
    FirebaseUser firebaseUser = getCurrentUserFromPigeon(app);

    if (firebaseUser == null) {
      result.error(FlutterFirebaseAuthPluginException.noUser());
      return;
    }

    PhoneAuthCredential phoneAuthCredential =
        (PhoneAuthCredential) PigeonParser.getCredential(input);

    if (phoneAuthCredential == null) {
      result.error(FlutterFirebaseAuthPluginException.invalidCredential());
      return;
    }

    firebaseUser
        .updatePhoneNumber(phoneAuthCredential)
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                firebaseUser
                    .reload()
                    .addOnCompleteListener(
                        reloadTask -> {
                          if (reloadTask.isSuccessful()) {
                            result.success(PigeonParser.parseFirebaseUser(firebaseUser));
                          } else {
                            result.error(
                                FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                                    reloadTask.getException()));
                          }
                        });
              } else {
                result.error(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                        task.getException()));
              }
            });
  }

  @Override
  public void updateProfile(
      @NonNull GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseAuth.PigeonUserProfile profile,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserDetails>
              result) {
    FirebaseUser firebaseUser = getCurrentUserFromPigeon(app);

    if (firebaseUser == null) {
      result.error(FlutterFirebaseAuthPluginException.noUser());
      return;
    }

    UserProfileChangeRequest.Builder builder = new UserProfileChangeRequest.Builder();

    if (profile.getDisplayNameChanged()) {
      builder.setDisplayName(profile.getDisplayName());
    }

    if (profile.getPhotoUrlChanged()) {
      if (profile.getPhotoUrl() != null) {
        builder.setPhotoUri(Uri.parse(profile.getPhotoUrl()));
      } else {
        builder.setPhotoUri(null);
      }
    }

    firebaseUser
        .updateProfile(builder.build())
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                firebaseUser
                    .reload()
                    .addOnCompleteListener(
                        reloadTask -> {
                          if (reloadTask.isSuccessful()) {
                            result.success(PigeonParser.parseFirebaseUser(firebaseUser));
                          } else {
                            result.error(
                                FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                                    reloadTask.getException()));
                          }
                        });
              } else {
                result.error(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                        task.getException()));
              }
            });
  }

  @Override
  public void verifyBeforeUpdateEmail(
      @NonNull GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp app,
      @NonNull String newEmail,
      @Nullable GeneratedAndroidFirebaseAuth.PigeonActionCodeSettings actionCodeSettings,
      @NonNull GeneratedAndroidFirebaseAuth.VoidResult result) {
    FirebaseUser firebaseUser = getCurrentUserFromPigeon(app);

    if (firebaseUser == null) {
      result.error(FlutterFirebaseAuthPluginException.noUser());
      return;
    }

    if (actionCodeSettings == null) {
      firebaseUser
          .verifyBeforeUpdateEmail(newEmail)
          .addOnCompleteListener(
              task -> {
                if (task.isSuccessful()) {
                  result.success();
                } else {
                  result.error(
                      FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                          task.getException()));
                }
              });
      return;
    }

    firebaseUser
        .verifyBeforeUpdateEmail(newEmail, PigeonParser.getActionCodeSettings(actionCodeSettings))
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                result.success();
              } else {
                result.error(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                        task.getException()));
              }
            });
  }
}
