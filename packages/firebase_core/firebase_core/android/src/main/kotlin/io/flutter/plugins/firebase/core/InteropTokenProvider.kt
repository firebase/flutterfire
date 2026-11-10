// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.core

import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.TaskCompletionSource
import com.google.android.gms.tasks.Tasks
import com.google.firebase.FirebaseApp
import com.google.firebase.appcheck.interop.InteropAppCheckTokenProvider
import com.google.firebase.auth.internal.InternalAuthProvider
import com.google.firebase.iid.internal.FirebaseInstanceIdInternal
import com.google.firebase.internal.api.FirebaseNoSignedInUserException
import java.util.concurrent.Executor

/**
 * Fetches the Auth, App Check and FCM tokens from whichever SDKs the app links, the way the
 * Firebase Functions SDK's `FirebaseContextProvider` does.
 *
 * Each SDK registers an interop component in its app's component container when it is linked.
 * [getComponent] looks a component up by interface and returns null when no linked SDK registered
 * it, so a null token means "not linked" or "nothing to give", never failure.
 */
class InteropTokenProvider(
    private val getComponent: (Class<*>) -> Any?,
    private val executor: Executor,
) {
  companion object {
    /** Looks tokens up in the component container of the app named [appName]. */
    fun forApp(appName: String, executor: Executor): InteropTokenProvider {
      val app = FirebaseApp.getInstance(appName)
      return InteropTokenProvider({ app.get(it) }, executor)
    }
  }

  private inline fun <reified T> get(): T? = getComponent(T::class.java) as? T

  /**
   * The signed-in user's ID token, or null when the Auth SDK isn't linked or nobody is signed in.
   * Fails with the Auth SDK's exception when it can't produce a token.
   */
  fun getAuthIdToken(): Task<String?> {
    val auth = get<InternalAuthProvider>() ?: return Tasks.forResult(null)
    return auth.getAccessToken(false).continueWith(executor) { task ->
      if (task.isSuccessful) {
        task.result.token
      } else {
        when (val exception = task.exception) {
          // Signed out is an answer, not a failure.
          is FirebaseNoSignedInUserException -> null
          else -> throw exception ?: IllegalStateException("getAccessToken failed")
        }
      }
    }
  }

  /**
   * The App Check SDK's answer, or null when App Check isn't linked. When the SDK can't produce a
   * token, for example before it is activated, the answer carries its placeholder token and the
   * reason, as the SDK reports it.
   */
  fun getAppCheckToken(limitedUse: Boolean): Task<CoreAppCheckInteropToken?> {
    val appCheck = get<InteropAppCheckTokenProvider>() ?: return Tasks.forResult(null)
    val tokenTask = if (limitedUse) appCheck.limitedUseToken else appCheck.getToken(false)
    return tokenTask.onSuccessTask(executor) { result ->
      Tasks.forResult(
          CoreAppCheckInteropToken(
              token = result.token,
              error = result.error?.let { it.message ?: it.toString() },
          ))
    }
  }

  /**
   * The FCM registration token, or null when nothing provides `FirebaseInstanceIdInternal`.
   *
   * Only the Instance ID library provides it, so this answers whenever that library is linked.
   * `getToken()` blocks on the network when no token is cached yet, hence the executor.
   */
  fun getMessagingToken(): Task<String?> {
    val instanceId = get<FirebaseInstanceIdInternal>() ?: return Tasks.forResult(null)
    val taskCompletionSource = TaskCompletionSource<String?>()
    executor.execute {
      try {
        taskCompletionSource.setResult(instanceId.token)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }
    return taskCompletionSource.task
  }
}
