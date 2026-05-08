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

class LocalAIImpl : LocalAIApi {
  override fun isAvailable(callback: (Result<Boolean>) -> Unit) {
    // Placeholder for AICore availability check.
    // Assumes Gemini Nano is available on supported devices.
    callback(Result.success(true))
  }

  override fun generateContent(prompt: String, callback: (Result<String>) -> Unit) {
    // Placeholder for raw AICore API call.
    // In a real implementation, this would interact with the system's AI service.
    callback(Result.success("Local response from AICore for: $prompt"))
  }

  override fun warmup(callback: (Result<Unit>) -> Unit) {
    // Android uses default models (Gemini Nano), so warmup is likely a no-op.
    callback(Result.success(Unit))
  }
}
