// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.firestore

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import java.nio.ByteBuffer
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
    val identifier =
        register.invoke(
            plugin,
            "plugins.flutter.io/firebase_firestore/query",
            "listener-1",
            object : EventChannel.StreamHandler {
              override fun onListen(arguments: Any?, events: EventChannel.EventSink) {}

              override fun onCancel(arguments: Any?) {}
            }) as String

    val channelName = "plugins.flutter.io/firebase_firestore/query/$identifier"
    assertTrue(messenger.handlers.containsKey(channelName))

    val handlers = mapField(plugin, "streamHandlers")
    val wrapping = handlers[identifier] as EventChannel.StreamHandler
    wrapping.onCancel("cancelled-by-dart")

    assertTrue(mapField(plugin, "eventChannels").isEmpty())
    assertTrue(mapField(plugin, "streamHandlers").isEmpty())
    assertFalse(messenger.handlers.containsKey(channelName))
    assertNull(messenger.handlers[channelName])
  }

  private fun mapField(plugin: FlutterFirebaseFirestorePlugin, name: String): Map<*, *> {
    val field = plugin.javaClass.getDeclaredField(name)
    field.isAccessible = true
    @Suppress("UNCHECKED_CAST")
    return field.get(plugin) as Map<*, *>
  }
}
