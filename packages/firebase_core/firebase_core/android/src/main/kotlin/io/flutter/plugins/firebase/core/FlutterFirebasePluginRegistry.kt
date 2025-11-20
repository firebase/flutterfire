// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.core

import androidx.annotation.Keep
import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.TaskCompletionSource
import com.google.android.gms.tasks.Tasks
import com.google.firebase.FirebaseApp
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin.Companion.cachedThreadPool
import java.util.WeakHashMap

@Keep
object FlutterFirebasePluginRegistry {

    private val registeredPlugins: MutableMap<String, FlutterFirebasePlugin> = WeakHashMap()

    /**
     * Register a Flutter Firebase plugin with the Firebase plugin registry.
     *
     * @param channelName The MethodChannel name for the plugin to be registered, for example:
     *     `plugins.flutter.io/firebase_core`
     * @param flutterFirebasePlugin A FlutterPlugin that implements FlutterFirebasePlugin.
     */
    @JvmStatic
    fun registerPlugin(channelName: String, flutterFirebasePlugin: FlutterFirebasePlugin) {
        registeredPlugins[channelName] = flutterFirebasePlugin
    }

    /**
     * Each FlutterFire plugin implementing FlutterFirebasePlugin provides this method allowing it's
     * constants to be initialized during FirebaseCore.initializeApp in Dart. Here we call this method
     * on each of the registered plugins and gather their constants for use in Dart.
     *
     * @param firebaseApp The Firebase App that the plugin should return constants for.
     * @return A task returning the discovered constants for each plugin (using channelName as the Map
     *     key) for the provided Firebase App.
     */
    @JvmStatic
    internal fun getPluginConstantsForFirebaseApp(firebaseApp: FirebaseApp): Task<Map<String, Any>> {
        val taskCompletionSource = TaskCompletionSource<Map<String, Any>>()

        cachedThreadPool.execute {
            try {
                val pluginConstants = mutableMapOf<String, Any>()

                for ((channelName, plugin) in registeredPlugins) {
                    pluginConstants[channelName] = Tasks.await(plugin.getPluginConstantsForFirebaseApp(firebaseApp))
                }

                taskCompletionSource.setResult(pluginConstants)
            } catch (e: Exception) {
                taskCompletionSource.setException(e)
            }
        }

        return taskCompletionSource.task
    }

    /**
     * Each FlutterFire plugin implementing this method are notified that FirebaseCore#initializeCore
     * was called again.
     *
     * This is used by plugins to know if they need to cleanup previous resources between Hot
     * Restarts as `initializeCore` can only be called once in Dart.
     */
    @JvmStatic
    internal fun didReinitializeFirebaseCore(): Task<Void?> {
        val taskCompletionSource = TaskCompletionSource<Void?>()

        cachedThreadPool.execute {
            try {
                for ((_, plugin) in registeredPlugins) {
                    Tasks.await(plugin.didReinitializeFirebaseCore())
                }

                taskCompletionSource.setResult(null)
            } catch (e: Exception) {
                taskCompletionSource.setException(e)
            }
        }

        return taskCompletionSource.task
    }
}

