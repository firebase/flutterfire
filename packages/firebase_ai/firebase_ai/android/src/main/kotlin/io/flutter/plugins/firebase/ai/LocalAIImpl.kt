// Copyright 2026 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package io.flutter.plugins.firebase.ai

import com.google.mlkit.genai.prompt.Generation
import com.google.mlkit.genai.prompt.GenerateContentRequest
import com.google.mlkit.genai.prompt.TextPart
import com.google.mlkit.genai.common.FeatureStatus
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.flow.catch

class LocalAIImpl : LocalAIApi {
  private val coroutineScope = CoroutineScope(Dispatchers.Main)
  private val mlkitModel by lazy { Generation.getClient() }

  override fun isAvailable(callback: (Result<Boolean>) -> Unit) {
    coroutineScope.launch {
      try {
        val status = mlkitModel.checkStatus()
        callback(Result.success(status == FeatureStatus.AVAILABLE))
      } catch (e: Exception) {
        callback(Result.success(false))
      }
    }
  }

  override fun generateContent(prompt: String, callback: (Result<String>) -> Unit) {
    coroutineScope.launch {
      try {
        val request = GenerateContentRequest.builder(TextPart(prompt)).build()
        val response = mlkitModel.generateContent(request)
        val text = response.candidates.firstOrNull()?.text ?: ""
        callback(Result.success(text))
      } catch (e: Exception) {
        callback(Result.failure(e))
      }
    }
  }

  override fun warmup(callback: (Result<Unit>) -> Unit) {
    coroutineScope.launch {
      try {
        mlkitModel.warmup()
        callback(Result.success(Unit))
      } catch (e: Exception) {
        callback(Result.failure(e))
      }
    }
  }

  override fun startStreaming(prompt: String, callback: (Result<Unit>) -> Unit) {
    coroutineScope.launch {
      try {
        val request = GenerateContentRequest.builder(TextPart(prompt)).build()
        mlkitModel.generateContentStream(request)
          .catch { e ->
            callback(Result.failure(e))
          }
          .collect { chunk ->
            val text = chunk.candidates.firstOrNull()?.text ?: ""
            if (text.isNotEmpty()) {
              LocalAIStreamHandler.shared.sendEvent(text)
            }
          }
        LocalAIStreamHandler.shared.closeStream()
        callback(Result.success(Unit))
      } catch (e: Exception) {
        callback(Result.failure(e))
      }
    }
  }
}
