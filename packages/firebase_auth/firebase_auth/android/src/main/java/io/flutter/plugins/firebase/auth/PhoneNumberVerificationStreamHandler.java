/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.auth;

import android.app.Activity;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.firebase.FirebaseException;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.MultiFactorSession;
import com.google.firebase.auth.PhoneAuthCredential;
import com.google.firebase.auth.PhoneAuthOptions;
import com.google.firebase.auth.PhoneAuthProvider;
import com.google.firebase.auth.PhoneAuthProvider.ForceResendingToken;
import com.google.firebase.auth.PhoneMultiFactorInfo;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;

public class PhoneNumberVerificationStreamHandler implements StreamHandler {

  interface OnCredentialsListener {
    void onCredentialsReceived(PhoneAuthCredential credential);
  }

  final AtomicReference<Activity> activityRef = new AtomicReference<>(null);
  final FirebaseAuth firebaseAuth;
  final String phoneNumber;
  final PhoneMultiFactorInfo multiFactorInfo;
  final int timeout;
  final OnCredentialsListener onCredentialsListener;

  final MultiFactorSession multiFactorSession;

  String autoRetrievedSmsCodeForTesting;
  Integer forceResendingToken;

  private static final HashMap<Integer, ForceResendingToken> forceResendingTokens = new HashMap<>();

  @Nullable private EventSink eventSink;

  public PhoneNumberVerificationStreamHandler(
      Activity activity,
      @NonNull GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseAuth.PigeonVerifyPhoneNumberRequest request,
      @Nullable MultiFactorSession multiFactorSession,
      @Nullable PhoneMultiFactorInfo multiFactorInfo,
      OnCredentialsListener onCredentialsListener) {
    this.activityRef.set(activity);

    this.multiFactorSession = multiFactorSession;
    this.multiFactorInfo = multiFactorInfo;
    firebaseAuth = FlutterFirebaseAuthPlugin.getAuthFromPigeon(app);
    phoneNumber = request.getPhoneNumber();
    timeout = Math.toIntExact(request.getTimeout());

    if (request.getAutoRetrievedSmsCodeForTesting() != null) {
      autoRetrievedSmsCodeForTesting = request.getAutoRetrievedSmsCodeForTesting();
    }

    if (request.getForceResendingToken() != null) {
      forceResendingToken = Math.toIntExact(request.getForceResendingToken());
    }

    this.onCredentialsListener = onCredentialsListener;
  }

  @Override
  public void onListen(Object arguments, EventSink events) {
    eventSink = events;

    PhoneAuthProvider.OnVerificationStateChangedCallbacks callbacks =
        new PhoneAuthProvider.OnVerificationStateChangedCallbacks() {
          @Override
          public void onVerificationCompleted(@NonNull PhoneAuthCredential phoneAuthCredential) {
            int phoneAuthCredentialHashCode = phoneAuthCredential.hashCode();
            onCredentialsListener.onCredentialsReceived(phoneAuthCredential);

            Map<String, Object> event = new HashMap<>();
            event.put(Constants.TOKEN, phoneAuthCredentialHashCode);

            if (phoneAuthCredential.getSmsCode() != null) {
              event.put(Constants.SMS_CODE, phoneAuthCredential.getSmsCode());
            }

            event.put(Constants.NAME, "Auth#phoneVerificationCompleted");

            if (eventSink != null) {
              eventSink.success(event);
            }
          }

          @Override
          public void onVerificationFailed(@NonNull FirebaseException e) {
            Map<String, Object> event = new HashMap<>();
            Map<String, Object> error = new HashMap<>();
            GeneratedAndroidFirebaseAuth.FlutterError flutterError =
                FlutterFirebaseAuthPluginException.parserExceptionToFlutter(e);
            error.put(
                "code",
                flutterError
                    .code
                    .replaceAll("ERROR_", "")
                    .toLowerCase(Locale.ROOT)
                    .replaceAll("_", "-"));
            error.put("message", flutterError.getMessage());
            error.put("details", flutterError.details);
            event.put("error", error);

            event.put(Constants.NAME, "Auth#phoneVerificationFailed");

            if (eventSink != null) {
              eventSink.success(event);
            }
          }

          @Override
          public void onCodeSent(
              @NonNull String verificationId,
              @NonNull PhoneAuthProvider.ForceResendingToken token) {
            int forceResendingTokenHashCode = token.hashCode();
            forceResendingTokens.put(forceResendingTokenHashCode, token);

            Map<String, Object> event = new HashMap<>();
            event.put(Constants.VERIFICATION_ID, verificationId);
            event.put(Constants.FORCE_RESENDING_TOKEN, forceResendingTokenHashCode);

            event.put(Constants.NAME, "Auth#phoneCodeSent");

            if (eventSink != null) {
              eventSink.success(event);
            }
          }

          @Override
          public void onCodeAutoRetrievalTimeOut(@NonNull String verificationId) {
            Map<String, Object> event = new HashMap<>();
            event.put(Constants.VERIFICATION_ID, verificationId);

            event.put(Constants.NAME, "Auth#phoneCodeAutoRetrievalTimeout");

            if (eventSink != null) {
              eventSink.success(event);
            }
          }
        };

    // Allows the auto-retrieval flow to be tested.
    // See https://firebase.google.com/docs/auth/android/phone-auth#integration-testing
    if (autoRetrievedSmsCodeForTesting != null) {
      firebaseAuth
          .getFirebaseAuthSettings()
          .setAutoRetrievedSmsCodeForPhoneNumber(phoneNumber, autoRetrievedSmsCodeForTesting);
    }

    PhoneAuthOptions.Builder phoneAuthOptionsBuilder = new PhoneAuthOptions.Builder(firebaseAuth);
    phoneAuthOptionsBuilder.setActivity(activityRef.get());
    phoneAuthOptionsBuilder.setCallbacks(callbacks);

    if (phoneNumber != null) {
      phoneAuthOptionsBuilder.setPhoneNumber(phoneNumber);
    }
    if (multiFactorSession != null) {
      phoneAuthOptionsBuilder.setMultiFactorSession(multiFactorSession);
    }
    if (multiFactorInfo != null) {
      phoneAuthOptionsBuilder.setMultiFactorHint(multiFactorInfo);
    }
    phoneAuthOptionsBuilder.setTimeout((long) timeout, TimeUnit.MILLISECONDS);

    if (forceResendingToken != null) {
      PhoneAuthProvider.ForceResendingToken forceResendingToken =
          forceResendingTokens.get(this.forceResendingToken);

      if (forceResendingToken != null) {
        phoneAuthOptionsBuilder.setForceResendingToken(forceResendingToken);
      }
    }

    PhoneAuthProvider.verifyPhoneNumber(phoneAuthOptionsBuilder.build());
  }

  @Override
  public void onCancel(Object arguments) {
    eventSink = null;

    activityRef.set(null);
  }
}
