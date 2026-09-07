// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.functions

import java.util.Locale
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.JUnit4

@RunWith(JUnit4::class)
class FlutterFirebaseFunctionsPluginTest {
  private lateinit var originalLocale: Locale

  @Before
  fun setUp() {
    originalLocale = Locale.getDefault()
  }

  @After
  fun tearDown() {
    Locale.setDefault(originalLocale)
  }

  @Test
  fun mapFunctionsErrorCode_usesRootLocaleUnderTurkishDefault() {
    Locale.setDefault(Locale("tr", "TR"))

    // Canary: the JVM's Turkish locale really does map 'I' to 'ı'.
    assertEquals(
        "faıled-precondıtıon",
        "FAILED_PRECONDITION".replace("_", "-").lowercase(Locale.getDefault()))

    assertMappedCodes()
  }

  @Test
  fun mapFunctionsErrorCode_usesRootLocaleUnderAzerbaijaniDefault() {
    Locale.setDefault(Locale("az", "AZ"))

    assertEquals(
        "faıled-precondıtıon",
        "FAILED_PRECONDITION".replace("_", "-").lowercase(Locale.getDefault()))

    assertMappedCodes()
  }

  private fun assertMappedCodes() {
    val expected =
        mapOf(
            "FAILED_PRECONDITION" to "failed-precondition",
            "INVALID_ARGUMENT" to "invalid-argument",
            "PERMISSION_DENIED" to "permission-denied",
            "UNAUTHENTICATED" to "unauthenticated",
            "INTERNAL" to "internal",
            "UNAVAILABLE" to "unavailable",
            "DEADLINE_EXCEEDED" to "deadline-exceeded",
            "ALREADY_EXISTS" to "already-exists",
            "UNIMPLEMENTED" to "unimplemented",
            "UNKNOWN" to "unknown",
            "NOT_FOUND" to "not-found",
            "ABORTED" to "aborted",
        )

    for ((enumName, canonical) in expected) {
      assertEquals(
          canonical, FlutterFirebaseFunctionsPlugin.mapFunctionsErrorCode(enumName))
    }
  }
}
