// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.inappmessaging

import android.app.Activity
import com.google.firebase.inappmessaging.FirebaseInAppMessaging
import com.google.firebase.inappmessaging.FirebaseInAppMessagingClickListener
import com.google.firebase.inappmessaging.FirebaseInAppMessagingDismissListener
import com.google.firebase.inappmessaging.FirebaseInAppMessagingDisplay
import com.google.firebase.inappmessaging.FirebaseInAppMessagingDisplayErrorListener
import com.google.firebase.inappmessaging.FirebaseInAppMessagingImpressionListener
import com.google.firebase.inappmessaging.display.FirebaseInAppMessagingDisplay as FirebaseInAppMessagingDefaultDisplay
import java.util.concurrent.Executor

/**
 * The calls the plugin makes to the Firebase SDKs around activity lifecycle events, faked in tests.
 */
internal interface InAppMessagingSdk {
  fun addListeners(
      click: FirebaseInAppMessagingClickListener,
      impression: FirebaseInAppMessagingImpressionListener,
      dismiss: FirebaseInAppMessagingDismissListener,
      displayError: FirebaseInAppMessagingDisplayErrorListener,
      executor: Executor,
  )

  fun removeListeners(
      click: FirebaseInAppMessagingClickListener,
      impression: FirebaseInAppMessagingImpressionListener,
      dismiss: FirebaseInAppMessagingDismissListener,
      displayError: FirebaseInAppMessagingDisplayErrorListener,
  )

  fun setMessageDisplayComponent(display: FirebaseInAppMessagingDisplay)

  /**
   * Makes `firebase-inappmessaging-display` the display component again, by running its activity
   * pause and resume. The pause removes every listener.
   */
  fun rebindDefaultDisplay(activity: Activity)
}

internal object FirebaseInAppMessagingSdk : InAppMessagingSdk {
  override fun addListeners(
      click: FirebaseInAppMessagingClickListener,
      impression: FirebaseInAppMessagingImpressionListener,
      dismiss: FirebaseInAppMessagingDismissListener,
      displayError: FirebaseInAppMessagingDisplayErrorListener,
      executor: Executor,
  ) {
    FirebaseInAppMessaging.getInstance().apply {
      addClickListener(click, executor)
      addImpressionListener(impression, executor)
      addDismissListener(dismiss, executor)
      addDisplayErrorListener(displayError, executor)
    }
  }

  override fun removeListeners(
      click: FirebaseInAppMessagingClickListener,
      impression: FirebaseInAppMessagingImpressionListener,
      dismiss: FirebaseInAppMessagingDismissListener,
      displayError: FirebaseInAppMessagingDisplayErrorListener,
  ) {
    FirebaseInAppMessaging.getInstance().apply {
      removeClickListener(click)
      removeImpressionListener(impression)
      removeDismissListener(dismiss)
      removeDisplayErrorListener(displayError)
    }
  }

  override fun setMessageDisplayComponent(display: FirebaseInAppMessagingDisplay) {
    FirebaseInAppMessaging.getInstance().setMessageDisplayComponent(display)
  }

  override fun rebindDefaultDisplay(activity: Activity) {
    val defaultDisplay = FirebaseInAppMessagingDefaultDisplay.getInstance()
    defaultDisplay.onActivityPaused(activity)
    defaultDisplay.onActivityResumed(activity)
  }
}
