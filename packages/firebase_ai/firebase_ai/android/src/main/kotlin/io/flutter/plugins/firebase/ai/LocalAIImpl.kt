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
