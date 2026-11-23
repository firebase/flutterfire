// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.core

import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.Tasks
import com.google.firebase.FirebaseException
import com.google.firebase.appcheck.AppCheckTokenResult
import com.google.firebase.appcheck.interop.AppCheckTokenListener
import com.google.firebase.appcheck.interop.InteropAppCheckTokenProvider
import com.google.firebase.auth.GetTokenResult
import com.google.firebase.auth.internal.IdTokenListener
import com.google.firebase.auth.internal.InternalAuthProvider
import com.google.firebase.iid.internal.FirebaseInstanceIdInternal
import com.google.firebase.internal.api.FirebaseNoSignedInUserException
import java.io.IOException
import java.util.concurrent.Executor
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.JUnit4

@RunWith(JUnit4::class)
class InteropTokenProviderTest {
  /** Stands in for an app's component container: whatever the test "links". */
  private val linked = mutableMapOf<Class<*>, Any>()

  /** Runs continuations inline so tasks complete synchronously under test. */
  private val directExecutor = Executor { it.run() }

  private val provider = InteropTokenProvider({ linked[it] }, directExecutor)

  // Auth

  @Test
  fun authIdToken_isNullWhenAuthIsNotLinked() {
    assertNull(provider.getAuthIdToken().completedResult())
  }

  @Test
  fun authIdToken_isNullWhenNobodyIsSignedIn() {
    linked[InternalAuthProvider::class.java] =
        FakeAuth(Tasks.forException(FirebaseNoSignedInUserException("no user")))

    assertNull(provider.getAuthIdToken().completedResult())
  }

  @Test
  fun authIdToken_isTheSdkTokenWhenSignedIn() {
    linked[InternalAuthProvider::class.java] =
        FakeAuth(Tasks.forResult(GetTokenResult("id-token", emptyMap())))

    assertEquals("id-token", provider.getAuthIdToken().completedResult())
  }

  @Test
  fun authIdToken_failsWithTheSdkExceptionOtherwise() {
    val failure = FirebaseException("A network error has occurred.")
    linked[InternalAuthProvider::class.java] = FakeAuth(Tasks.forException(failure))

    assertSame(failure, provider.getAuthIdToken().completedException())
  }

  @Test
  fun authIdToken_neverForcesARefresh() {
    val auth = FakeAuth(Tasks.forResult(GetTokenResult("id-token", emptyMap())))
    linked[InternalAuthProvider::class.java] = auth

    provider.getAuthIdToken().completedResult()

    assertEquals(listOf(false), auth.forceRefreshRequests)
  }

  // App Check

  @Test
  fun appCheckToken_isNullWhenAppCheckIsNotLinked() {
    assertNull(provider.getAppCheckToken(limitedUse = false).completedResult())
  }

  @Test
  fun appCheckToken_carriesTheRealTokenWithoutAnError() {
    linked[InteropAppCheckTokenProvider::class.java] =
        FakeAppCheck(regular = appCheckResult("app-check-token", error = null))

    val result = provider.getAppCheckToken(limitedUse = false).completedResult()

    assertEquals(CoreAppCheckInteropToken(token = "app-check-token", error = null), result)
  }

  @Test
  fun appCheckToken_carriesThePlaceholderAndTheErrorBeforeActivation() {
    linked[InteropAppCheckTokenProvider::class.java] =
        FakeAppCheck(
            regular =
                appCheckResult("placeholder", FirebaseException("No AppCheckProvider installed.")))

    val result = provider.getAppCheckToken(limitedUse = false).completedResult()

    assertEquals(
        CoreAppCheckInteropToken(token = "placeholder", error = "No AppCheckProvider installed."),
        result)
  }

  @Test
  fun appCheckToken_describesAnErrorWithoutAMessage() {
    linked[InteropAppCheckTokenProvider::class.java] =
        FakeAppCheck(regular = appCheckResult("placeholder", IllegalStateException()))

    val result = provider.getAppCheckToken(limitedUse = false).completedResult()

    assertEquals("java.lang.IllegalStateException", result?.error)
  }

  @Test
  fun appCheckToken_asksForALimitedUseTokenOnRequest() {
    val appCheck =
        FakeAppCheck(
            regular = appCheckResult("regular", error = null),
            limitedUse = appCheckResult("limited-use", error = null))
    linked[InteropAppCheckTokenProvider::class.java] = appCheck

    val result = provider.getAppCheckToken(limitedUse = true).completedResult()

    assertEquals("limited-use", result?.token)
    assertEquals(listOf("limitedUse"), appCheck.requests)
  }

  @Test
  fun appCheckToken_asksForACachedTokenByDefault() {
    val appCheck = FakeAppCheck(regular = appCheckResult("regular", error = null))
    linked[InteropAppCheckTokenProvider::class.java] = appCheck

    provider.getAppCheckToken(limitedUse = false).completedResult()

    assertEquals(listOf("getToken(forceRefresh=false)"), appCheck.requests)
  }

  // Messaging

  @Test
  fun messagingToken_isNullWhenNothingProvidesInstanceId() {
    assertNull(provider.getMessagingToken().completedResult())
  }

  @Test
  fun messagingToken_isNullWhenThereIsNoTokenYet() {
    linked[FirebaseInstanceIdInternal::class.java] = FakeInstanceId(token = null)

    assertNull(provider.getMessagingToken().completedResult())
  }

  @Test
  fun messagingToken_isTheRegistrationToken() {
    linked[FirebaseInstanceIdInternal::class.java] = FakeInstanceId(token = "fcm-token")

    assertEquals("fcm-token", provider.getMessagingToken().completedResult())
  }

  @Test
  fun messagingToken_failsWithTheSdkExceptionOtherwise() {
    val failure = IOException("SERVICE_NOT_AVAILABLE")
    linked[FirebaseInstanceIdInternal::class.java] = FakeInstanceId(failure = failure)

    assertSame(failure, provider.getMessagingToken().completedException())
  }

  @Test
  fun lookupsIgnoreAComponentOfTheWrongType() {
    linked[InternalAuthProvider::class.java] = "not an auth provider"

    assertNull(provider.getAuthIdToken().completedResult())
  }

  // Helpers

  private fun <T> Task<T>.completedResult(): T? {
    assertTrue("task should complete synchronously under test", isComplete)
    assertTrue("task failed: $exception", isSuccessful)
    return result
  }

  private fun <T> Task<T>.completedException(): Exception? {
    assertTrue("task should complete synchronously under test", isComplete)
    // Don't read `result` here: on a failed task it rethrows the failure.
    assertFalse("task unexpectedly succeeded", isSuccessful)
    return exception
  }

  private fun appCheckResult(token: String, error: Exception?): Task<AppCheckTokenResult> =
      Tasks.forResult(
          object : AppCheckTokenResult() {
            override fun getToken() = token

            override fun getError() = error
          })

  private class FakeAuth(private val accessToken: Task<GetTokenResult>) : InternalAuthProvider {
    val forceRefreshRequests = mutableListOf<Boolean>()

    override fun getAccessToken(forceRefresh: Boolean): Task<GetTokenResult> {
      forceRefreshRequests.add(forceRefresh)
      return accessToken
    }

    override fun getUid(): String? = null

    override fun addIdTokenListener(listener: IdTokenListener) = Unit

    override fun removeIdTokenListener(listener: IdTokenListener) = Unit
  }

  private class FakeAppCheck(
      private val regular: Task<AppCheckTokenResult>,
      private val limitedUse: Task<AppCheckTokenResult> = regular,
  ) : InteropAppCheckTokenProvider {
    val requests = mutableListOf<String>()

    override fun getToken(forceRefresh: Boolean): Task<AppCheckTokenResult> {
      requests.add("getToken(forceRefresh=$forceRefresh)")
      return regular
    }

    override fun getLimitedUseToken(): Task<AppCheckTokenResult> {
      requests.add("limitedUse")
      return limitedUse
    }

    override fun addAppCheckTokenListener(listener: AppCheckTokenListener) = Unit

    override fun removeAppCheckTokenListener(listener: AppCheckTokenListener) = Unit
  }

  private class FakeInstanceId(
      private val token: String? = null,
      private val failure: Exception? = null,
  ) : FirebaseInstanceIdInternal {
    override fun getId(): String = "instance-id"

    override fun getToken(): String? {
      failure?.let { throw it }
      return token
    }

    override fun getTokenTask(): Task<String> = Tasks.forResult(token)

    override fun deleteToken(senderId: String, scope: String) = Unit

    override fun addNewTokenListener(listener: FirebaseInstanceIdInternal.NewTokenListener) = Unit
  }
}
