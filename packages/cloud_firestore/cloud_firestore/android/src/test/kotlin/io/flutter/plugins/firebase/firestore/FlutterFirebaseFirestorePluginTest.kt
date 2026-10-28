// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.firestore

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import java.nio.ByteBuffer
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class FlutterFirebaseFirestorePluginTest {
  private class RecordingMessenger : BinaryMessenger {
    val handlers = HashMap<String, BinaryMessenger.BinaryMessageHandler?>()

    override fun send(channel: String, message: ByteBuffer?) {}

    override fun send(
        channel: String,
        message: ByteBuffer?,
        callback: BinaryMessenger.BinaryReply?
    ) {}

    override fun setMessageHandler(
        channel: String,
        handler: BinaryMessenger.BinaryMessageHandler?
    ) {
      if (handler == null) {
        handlers.remove(channel)
      } else {
        handlers[channel] = handler
      }
    }
  }

  @Test
  fun cancelClearsEventChannelAndHandler() {
    val prefixes =
        listOf(
            "plugins.flutter.io/firebase_firestore/query",
            "plugins.flutter.io/firebase_firestore/document",
            "plugins.flutter.io/firebase_firestore/loadBundle",
            "plugins.flutter.io/firebase_firestore/snapshotsInSync")
    for (prefix in prefixes) {
      assertCancelClearsChannel(prefix, "cancelled-by-dart")
      assertCancelClearsChannel(prefix, null)
    }
  }

  private fun assertCancelClearsChannel(prefix: String, cancelArguments: Any?) {
    val messenger = RecordingMessenger()
    val plugin = FlutterFirebaseFirestorePlugin()
    val initInstance =
        plugin.javaClass.getDeclaredMethod("initInstance", BinaryMessenger::class.java)
    initInstance.isAccessible = true
    initInstance.invoke(plugin, messenger)

    val register =
        plugin.javaClass.getDeclaredMethod(
            "registerEventChannel",
            String::class.java,
            String::class.java,
            EventChannel.StreamHandler::class.java)
    register.isAccessible = true
    var cancelledWith: Any? = Any()
    var innerCancelCount = 0
    val identifier =
        register.invoke(
            plugin,
            prefix,
            "listener-1",
            object : EventChannel.StreamHandler {
              override fun onListen(arguments: Any?, events: EventChannel.EventSink) {}

              override fun onCancel(arguments: Any?) {
                innerCancelCount += 1
                cancelledWith = arguments
              }
            }) as String

    val channelName = "$prefix/$identifier"
    assertTrue(messenger.handlers.containsKey(channelName))

    val handlers = mapField(plugin, "streamHandlers")
    val wrapping = handlers[identifier] as EventChannel.StreamHandler
    wrapping.onCancel(cancelArguments)

    assertEquals(1, innerCancelCount)
    assertEquals(cancelArguments, cancelledWith)
    assertTrue(mapField(plugin, "eventChannels").isEmpty())
    assertTrue(mapField(plugin, "streamHandlers").isEmpty())
    assertFalse(messenger.handlers.containsKey(channelName))
    assertNull(messenger.handlers[channelName])
  }

  private fun mapField(plugin: FlutterFirebaseFirestorePlugin, name: String): Map<*, *> {
    val field = plugin.javaClass.getDeclaredField(name)
    field.isAccessible = true
    @Suppress("UNCHECKED_CAST") return field.get(plugin) as Map<*, *>
  }
}
