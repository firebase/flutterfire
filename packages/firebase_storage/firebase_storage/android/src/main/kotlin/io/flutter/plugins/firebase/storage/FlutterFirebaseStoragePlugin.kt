/*
 * Copyright 2025, the Chromium project authors.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */
package io.flutter.plugins.firebase.storage

import android.net.Uri
import android.util.Base64
import androidx.annotation.NonNull
import androidx.annotation.Nullable
import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.TaskCompletionSource
import com.google.firebase.FirebaseApp
import com.google.firebase.storage.FirebaseStorage
import com.google.firebase.storage.ListResult
import com.google.firebase.storage.StorageMetadata
import com.google.firebase.storage.StorageReference
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin.cachedThreadPool
import io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry
import java.io.File
import java.util.Locale
import java.util.UUID

class FlutterFirebaseStoragePlugin : FlutterFirebasePlugin, FlutterPlugin, FirebaseStorageHostApi {
  private var channel: MethodChannel? = null
  private var messenger: BinaryMessenger? = null

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    initInstance(binding.binaryMessenger)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    FlutterFirebaseStorageTask.cancelInProgressTasks()
    channel?.setMethodCallHandler(null)
    checkNotNull(messenger)
    FirebaseStorageHostApi.setUp(messenger!!, null)
    channel = null
    messenger = null
    removeEventListeners()
  }

  private fun initInstance(messenger: BinaryMessenger) {
    FlutterFirebasePluginRegistry.registerPlugin(STORAGE_METHOD_CHANNEL_NAME, this)
    channel = MethodChannel(messenger, STORAGE_METHOD_CHANNEL_NAME)
    FirebaseStorageHostApi.setUp(messenger, this)
    this.messenger = messenger
  }

  private fun registerEventChannel(prefix: String, identifier: String, handler: StreamHandler): String {
    val channelName = "$prefix/$identifier"
    val channel = EventChannel(messenger, channelName)
    channel.setStreamHandler(handler)
    eventChannels[identifier] = channel
    streamHandlers[identifier] = handler
    return identifier
  }

  @Synchronized
  private fun removeEventListeners() {
    val eventChannelKeys: List<String> = ArrayList(eventChannels.keys)
    for (identifier in eventChannelKeys) {
      val eventChannel = eventChannels[identifier]
      eventChannel?.setStreamHandler(null)
      eventChannels.remove(identifier)
    }

    val streamHandlerKeys: List<String> = ArrayList(streamHandlers.keys)
    for (identifier in streamHandlerKeys) {
      val streamHandler = streamHandlers[identifier]
      if (streamHandler is TaskStateChannelStreamHandler) {
        streamHandler.onCancel(null)
      }
      streamHandlers.remove(identifier)
    }
  }

  private fun getStorageFromPigeon(app: PigeonStorageFirebaseApp): FirebaseStorage {
    val androidApp = FirebaseApp.getInstance(app.appName)
    return FirebaseStorage.getInstance(androidApp, "gs://${app.bucket}")
  }

  private fun getReferenceFromPigeon(
    app: PigeonStorageFirebaseApp,
    reference: PigeonStorageReference
  ): StorageReference {
    val androidStorage = getStorageFromPigeon(app)
    return androidStorage.getReference(reference.fullPath)
  }

  private fun convertToPigeonReference(reference: StorageReference): PigeonStorageReference {
    return PigeonStorageReference(
      bucket = reference.bucket,
      fullPath = reference.path,
      name = reference.name
    )
  }

  private fun convertToPigeonMetaData(storageMetadata: StorageMetadata?): PigeonFullMetaData {
    return PigeonFullMetaData(metadata = parseMetadataToMap(storageMetadata))
  }

  private fun convertToPigeonListResult(listResult: ListResult): PigeonListResult {
    val items = listResult.items.map { convertToPigeonReference(it) }
    val prefixes = listResult.prefixes.map { convertToPigeonReference(it) }
    return PigeonListResult(items = items, pageToken = listResult.pageToken, prefixs = prefixes)
  }

  private fun getMetaDataFromPigeon(pigeonSettableMetatdata: PigeonSettableMetadata): StorageMetadata {
    val builder = StorageMetadata.Builder()
    pigeonSettableMetatdata.contentType?.let { builder.setContentType(it) }
    pigeonSettableMetatdata.cacheControl?.let { builder.setCacheControl(it) }
    pigeonSettableMetatdata.contentDisposition?.let { builder.setContentDisposition(it) }
    pigeonSettableMetatdata.contentEncoding?.let { builder.setContentEncoding(it) }
    pigeonSettableMetatdata.contentLanguage?.let { builder.setContentLanguage(it) }
    pigeonSettableMetatdata.customMetadata?.forEach { (k, v) -> if (k != null && v != null) builder.setCustomMetadata(k, v) }
    return builder.build()
  }

  private fun stringToByteData(data: String, format: Int): ByteArray? {
    return when (format) {
      1 -> Base64.decode(data, Base64.DEFAULT) // base64
      2 -> Base64.decode(data, Base64.URL_SAFE) // base64Url
      else -> null
    }
  }

  override fun getReferencebyPath(
    app: PigeonStorageFirebaseApp,
    path: String,
    bucket: String?,
    callback: (Result<PigeonStorageReference>) -> Unit
  ) {
    val androidReference = getStorageFromPigeon(app).getReference(path)
    callback(Result.success(convertToPigeonReference(androidReference)))
  }

  override fun useStorageEmulator(
    app: PigeonStorageFirebaseApp,
    host: String,
    port: Long,
    callback: (Result<Unit>) -> Unit
  ) {
    try {
      val storage = getStorageFromPigeon(app)
      storage.useEmulator(host, port.toInt())
      callback(Result.success(Unit))
    } catch (e: Exception) {
      callback(Result.failure(FlutterFirebaseStorageException.parserExceptionToFlutter(e)))
    }
  }

  override fun referenceDelete(
    app: PigeonStorageFirebaseApp,
    reference: PigeonStorageReference,
    callback: (Result<Unit>) -> Unit
  ) {
    val androidReference = getStorageFromPigeon(app).getReference(reference.fullPath)
    androidReference.delete().addOnCompleteListener { task ->
      if (task.isSuccessful) callback(Result.success(Unit))
      else callback(Result.failure(FlutterFirebaseStorageException.parserExceptionToFlutter(task.exception)))
    }
  }

  override fun referenceGetDownloadURL(
    app: PigeonStorageFirebaseApp,
    reference: PigeonStorageReference,
    callback: (Result<String>) -> Unit
  ) {
    val androidReference = getStorageFromPigeon(app).getReference(reference.fullPath)
    androidReference.downloadUrl.addOnCompleteListener { task ->
      if (task.isSuccessful) callback(Result.success(task.result.toString()))
      else callback(Result.failure(FlutterFirebaseStorageException.parserExceptionToFlutter(task.exception)))
    }
  }

  override fun referenceGetData(
    app: PigeonStorageFirebaseApp,
    reference: PigeonStorageReference,
    maxSize: Long,
    callback: (Result<ByteArray?>) -> Unit
  ) {
    val androidReference = getStorageFromPigeon(app).getReference(reference.fullPath)
    androidReference.getBytes(maxSize).addOnCompleteListener { task ->
      if (task.isSuccessful) callback(Result.success(task.result))
      else callback(Result.failure(FlutterFirebaseStorageException.parserExceptionToFlutter(task.exception)))
    }
  }

  override fun referenceGetMetaData(
    app: PigeonStorageFirebaseApp,
    reference: PigeonStorageReference,
    callback: (Result<PigeonFullMetaData>) -> Unit
  ) {
    val androidReference = getStorageFromPigeon(app).getReference(reference.fullPath)
    androidReference.metadata.addOnCompleteListener { task ->
      if (task.isSuccessful) callback(Result.success(convertToPigeonMetaData(task.result)))
      else callback(Result.failure(FlutterFirebaseStorageException.parserExceptionToFlutter(task.exception)))
    }
  }

  override fun referenceList(
    app: PigeonStorageFirebaseApp,
    reference: PigeonStorageReference,
    options: PigeonListOptions,
    callback: (Result<PigeonListResult>) -> Unit
  ) {
    val androidReference = getStorageFromPigeon(app).getReference(reference.fullPath)
    val task = if (options.pageToken != null) {
      androidReference.list(options.maxResults.toInt(), options.pageToken)
    } else {
      androidReference.list(options.maxResults.toInt())
    }
    task.addOnCompleteListener { t ->
      if (t.isSuccessful) callback(Result.success(convertToPigeonListResult(t.result)))
      else callback(Result.failure(FlutterFirebaseStorageException.parserExceptionToFlutter(t.exception)))
    }
  }

  override fun referenceListAll(
    app: PigeonStorageFirebaseApp,
    reference: PigeonStorageReference,
    callback: (Result<PigeonListResult>) -> Unit
  ) {
    val androidReference = getStorageFromPigeon(app).getReference(reference.fullPath)
    androidReference.listAll().addOnCompleteListener { task ->
      if (task.isSuccessful) callback(Result.success(convertToPigeonListResult(task.result)))
      else callback(Result.failure(FlutterFirebaseStorageException.parserExceptionToFlutter(task.exception)))
    }
  }

  override fun referenceUpdateMetadata(
    app: PigeonStorageFirebaseApp,
    reference: PigeonStorageReference,
    metadata: PigeonSettableMetadata,
    callback: (Result<PigeonFullMetaData>) -> Unit
  ) {
    val androidReference = getStorageFromPigeon(app).getReference(reference.fullPath)
    androidReference.updateMetadata(getMetaDataFromPigeon(metadata)).addOnCompleteListener { task ->
      if (task.isSuccessful) callback(Result.success(convertToPigeonMetaData(task.result)))
      else callback(Result.failure(FlutterFirebaseStorageException.parserExceptionToFlutter(task.exception)))
    }
  }

  override fun referencePutData(
    app: PigeonStorageFirebaseApp,
    reference: PigeonStorageReference,
    data: ByteArray,
    settableMetaData: PigeonSettableMetadata,
    handle: Long,
    callback: (Result<String>) -> Unit
  ) {
    val androidReference = getReferenceFromPigeon(app, reference)
    val androidMetaData = getMetaDataFromPigeon(settableMetaData)
    val storageTask = FlutterFirebaseStorageTask.uploadBytes(handle.toInt(), androidReference, data, androidMetaData)
    try {
      val identifier = UUID.randomUUID().toString().lowercase(Locale.US)
      val handler = storageTask.startTaskWithMethodChannel(channel!!, identifier)
      callback(Result.success(registerEventChannel("$STORAGE_METHOD_CHANNEL_NAME/$STORAGE_TASK_EVENT_NAME", identifier, handler)))
    } catch (e: Exception) {
      callback(Result.failure(FlutterFirebaseStorageException.parserExceptionToFlutter(e)))
    }
  }

  override fun referencePutString(
    app: PigeonStorageFirebaseApp,
    reference: PigeonStorageReference,
    data: String,
    format: Long,
    settableMetaData: PigeonSettableMetadata,
    handle: Long,
    callback: (Result<String>) -> Unit
  ) {
    val androidReference = getReferenceFromPigeon(app, reference)
    val androidMetaData = getMetaDataFromPigeon(settableMetaData)
    val bytes = stringToByteData(data, format.toInt())
    val storageTask = FlutterFirebaseStorageTask.uploadBytes(handle.toInt(), androidReference, bytes!!, androidMetaData)
    try {
      val identifier = UUID.randomUUID().toString().lowercase(Locale.US)
      val handler = storageTask.startTaskWithMethodChannel(channel!!, identifier)
      callback(Result.success(registerEventChannel("$STORAGE_METHOD_CHANNEL_NAME/$STORAGE_TASK_EVENT_NAME", identifier, handler)))
    } catch (e: Exception) {
      callback(Result.failure(FlutterFirebaseStorageException.parserExceptionToFlutter(e)))
    }
  }

  override fun referencePutFile(
    app: PigeonStorageFirebaseApp,
    reference: PigeonStorageReference,
    filePath: String,
    settableMetaData: PigeonSettableMetadata?,
    handle: Long,
    callback: (Result<String>) -> Unit
  ) {
    val androidReference = getReferenceFromPigeon(app, reference)
    val storageTask = FlutterFirebaseStorageTask.uploadFile(
      handle.toInt(),
      androidReference,
      Uri.fromFile(File(filePath)),
      settableMetaData?.let { getMetaDataFromPigeon(it) }
    )
    try {
      val identifier = UUID.randomUUID().toString().lowercase(Locale.US)
      val handler = storageTask.startTaskWithMethodChannel(channel!!, identifier)
      callback(Result.success(registerEventChannel("$STORAGE_METHOD_CHANNEL_NAME/$STORAGE_TASK_EVENT_NAME", identifier, handler)))
    } catch (e: Exception) {
      callback(Result.failure(FlutterFirebaseStorageException.parserExceptionToFlutter(e)))
    }
  }

  override fun referenceDownloadFile(
    app: PigeonStorageFirebaseApp,
    reference: PigeonStorageReference,
    filePath: String,
    handle: Long,
    callback: (Result<String>) -> Unit
  ) {
    val androidReference = getReferenceFromPigeon(app, reference)
    val storageTask = FlutterFirebaseStorageTask.downloadFile(handle.toInt(), androidReference, File(filePath))
    try {
      val identifier = UUID.randomUUID().toString().lowercase(Locale.US)
      val handler = storageTask.startTaskWithMethodChannel(channel!!, identifier)
      callback(Result.success(registerEventChannel("$STORAGE_METHOD_CHANNEL_NAME/$STORAGE_TASK_EVENT_NAME", identifier, handler)))
    } catch (e: Exception) {
      callback(Result.failure(FlutterFirebaseStorageException.parserExceptionToFlutter(e)))
    }
  }

  override fun taskPause(
    app: PigeonStorageFirebaseApp,
    handle: Long,
    callback: (Result<Map<String, Any>>) -> Unit
  ) {
    val storageTask = FlutterFirebaseStorageTask.getInProgressTaskForHandle(handle.toInt())
    if (storageTask == null) {
      val statusMap = HashMap<String, Any>()
      statusMap["status"] = false
      callback(Result.success(statusMap))
      return
    }
    try {
      var paused = false
      if (!storageTask.isPaused()) {
        paused = storageTask.pause()
      }
      val statusMap = HashMap<String, Any>()
      statusMap["status"] = paused
      if (paused) {
        statusMap["snapshot"] = FlutterFirebaseStorageTask.parseTaskSnapshot(storageTask.getSnapshot())
      }
      callback(Result.success(statusMap))
    } catch (e: Exception) {
      callback(Result.failure(FlutterFirebaseStorageException.parserExceptionToFlutter(e)))
    }
  }

  override fun taskResume(
    app: PigeonStorageFirebaseApp,
    handle: Long,
    callback: (Result<Map<String, Any>>) -> Unit
  ) {
    val storageTask = FlutterFirebaseStorageTask.getInProgressTaskForHandle(handle.toInt())
    if (storageTask == null) {
      val statusMap = HashMap<String, Any>()
      statusMap["status"] = false
      callback(Result.success(statusMap))
      return
    }
    try {
      var resumed = false
      if (storageTask.isPaused()) {
        resumed = storageTask.resume()
      }
      val statusMap = HashMap<String, Any>()
      statusMap["status"] = resumed
      if (resumed) {
        statusMap["snapshot"] = FlutterFirebaseStorageTask.parseTaskSnapshot(storageTask.getSnapshot())
      }
      callback(Result.success(statusMap))
    } catch (e: Exception) {
      callback(Result.failure(FlutterFirebaseStorageException.parserExceptionToFlutter(e)))
    }
  }

  override fun taskCancel(
    app: PigeonStorageFirebaseApp,
    handle: Long,
    callback: (Result<Map<String, Any>>) -> Unit
  ) {
    val storageTask = FlutterFirebaseStorageTask.getInProgressTaskForHandle(handle.toInt())
    if (storageTask == null) {
      val statusMap = HashMap<String, Any>()
      statusMap["status"] = false
      callback(Result.success(statusMap))
      return
    }
    try {
      val canceled = storageTask.cancel()
      val statusMap = HashMap<String, Any>()
      statusMap["status"] = canceled
      if (canceled) {
        statusMap["snapshot"] = FlutterFirebaseStorageTask.parseTaskSnapshot(storageTask.getSnapshot())
      }
      callback(Result.success(statusMap))
    } catch (e: Exception) {
      callback(Result.failure(FlutterFirebaseStorageException.parserExceptionToFlutter(e)))
    }
  }

  override fun setMaxOperationRetryTime(
    app: PigeonStorageFirebaseApp,
    time: Long,
    callback: (Result<Unit>) -> Unit
  ) {
    val storage = getStorageFromPigeon(app)
    storage.maxOperationRetryTimeMillis = time
    callback(Result.success(Unit))
  }

  override fun setMaxUploadRetryTime(
    app: PigeonStorageFirebaseApp,
    time: Long,
    callback: (Result<Unit>) -> Unit
  ) {
    val storage = getStorageFromPigeon(app)
    storage.maxUploadRetryTimeMillis = time
    callback(Result.success(Unit))
  }

  override fun setMaxDownloadRetryTime(
    app: PigeonStorageFirebaseApp,
    time: Long,
    callback: (Result<Unit>) -> Unit
  ) {
    val storage = getStorageFromPigeon(app)
    storage.maxDownloadRetryTimeMillis = time
    callback(Result.success(Unit))
  }

  override fun getPluginConstantsForFirebaseApp(firebaseApp: FirebaseApp?): Task<MutableMap<String, Any>> {
    val taskCompletionSource = TaskCompletionSource<MutableMap<String, Any>>()
    cachedThreadPool.execute {
      val obj = HashMap<String, Any>()
      taskCompletionSource.setResult(obj)
    }
    return taskCompletionSource.task
  }

  override fun didReinitializeFirebaseCore(): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()
    cachedThreadPool.execute {
      FlutterFirebaseStorageTask.cancelInProgressTasks()
      taskCompletionSource.setResult(null)
      removeEventListeners()
    }
    return taskCompletionSource.task
  }

  companion object {
    const val STORAGE_METHOD_CHANNEL_NAME = "plugins.flutter.io/firebase_storage"
    const val STORAGE_TASK_EVENT_NAME = "taskEvent"
    const val DEFAULT_ERROR_CODE = "firebase_storage"

    val eventChannels: MutableMap<String, EventChannel> = HashMap()
    val streamHandlers: MutableMap<String, StreamHandler> = HashMap()

    fun getExceptionDetails(exception: Exception): Map<String, String> {
      val storageException = FlutterFirebaseStorageException.parserExceptionToFlutter(exception)
      val details: MutableMap<String, String> = HashMap()
      details["code"] = storageException.code
      details["message"] = storageException.message ?: ""
      return details
    }

    fun parseMetadataToMap(storageMetadata: StorageMetadata?): Map<String?, Any?>? {
      if (storageMetadata == null) return null
      val out: MutableMap<String?, Any?> = HashMap()
      storageMetadata.name?.let { out["name"] = it }
      storageMetadata.bucket?.let { out["bucket"] = it }
      storageMetadata.generation?.let { out["generation"] = it }
      storageMetadata.metadataGeneration?.let { out["metadataGeneration"] = it }
      out["fullPath"] = storageMetadata.path
      out["size"] = storageMetadata.sizeBytes
      out["creationTimeMillis"] = storageMetadata.creationTimeMillis
      out["updatedTimeMillis"] = storageMetadata.updatedTimeMillis
      storageMetadata.md5Hash?.let { out["md5Hash"] = it }
      storageMetadata.cacheControl?.let { out["cacheControl"] = it }
      storageMetadata.contentDisposition?.let { out["contentDisposition"] = it }
      storageMetadata.contentEncoding?.let { out["contentEncoding"] = it }
      storageMetadata.contentLanguage?.let { out["contentLanguage"] = it }
      storageMetadata.contentType?.let { out["contentType"] = it }
      val customMetadata: MutableMap<String?, String?> = HashMap()
      for (key in storageMetadata.customMetadataKeys) {
        customMetadata[key] = storageMetadata.getCustomMetadata(key) ?: ""
      }
      out["customMetadata"] = customMetadata
      return out
    }
  }
}


