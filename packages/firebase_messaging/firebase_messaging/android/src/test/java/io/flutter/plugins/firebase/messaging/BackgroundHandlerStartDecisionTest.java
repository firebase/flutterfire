// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package io.flutter.plugins.firebase.messaging;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;

import org.junit.Test;

public class BackgroundHandlerStartDecisionTest {
  @Test
  public void noHandleAndFlagAbsentSkipsWithoutClearing() {
    assertEquals(
        BackgroundHandlerStartDecision.Action.SKIP,
        BackgroundHandlerStartDecision.decide(0L, null));
  }

  @Test
  public void storedHandleAndFlagAbsentStarts() {
    assertEquals(
        BackgroundHandlerStartDecision.Action.START,
        BackgroundHandlerStartDecision.decide(42L, null));
  }

  @Test
  public void storedHandleAndFlagFalseSkipsAndClears() {
    assertEquals(
        BackgroundHandlerStartDecision.Action.SKIP_AND_CLEAR,
        BackgroundHandlerStartDecision.decide(42L, false));
  }

  @Test
  public void storedHandleAndFlagTrueStarts() {
    assertEquals(
        BackgroundHandlerStartDecision.Action.START,
        BackgroundHandlerStartDecision.decide(42L, true));
  }

  @Test
  public void noHandleAndFlagFalseSkipsAndClears() {
    assertEquals(
        BackgroundHandlerStartDecision.Action.SKIP_AND_CLEAR,
        BackgroundHandlerStartDecision.decide(0L, false));
  }

  @Test
  public void manifestStringFalseDisables() {
    assertEquals(Boolean.FALSE, BackgroundHandlerStartDecision.manifestValue("false"));
    assertEquals(Boolean.FALSE, BackgroundHandlerStartDecision.manifestValue("FALSE"));
  }

  @Test
  public void manifestStringTrueStaysEnabled() {
    assertEquals(Boolean.TRUE, BackgroundHandlerStartDecision.manifestValue("true"));
  }

  @Test
  public void manifestBooleanIsKept() {
    assertEquals(Boolean.FALSE, BackgroundHandlerStartDecision.manifestValue(Boolean.FALSE));
  }

  @Test
  public void unknownManifestValueIsAbsent() {
    assertNull(BackgroundHandlerStartDecision.manifestValue("no"));
    assertNull(BackgroundHandlerStartDecision.manifestValue(0));
    assertNull(BackgroundHandlerStartDecision.manifestValue(null));
  }
}
