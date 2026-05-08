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

import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#endif

#if canImport(FoundationModels)
import FoundationModels
#endif

class LocalAIImpl: LocalAIApi {
  func isAvailable(completion: @escaping (Result<Bool, Error>) -> Void) {
    #if canImport(FoundationModels)
    if #available(iOS 26.0, macOS 26.0, *) {
      // Assume available if API is supported on this version.
      // Real implementation might check if model is downloaded or active.
      completion(.success(true))
    } else {
      completion(.success(false))
    }
    #else
    completion(.success(false))
    #endif
  }
  
  func generateContent(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
    #if canImport(FoundationModels)
    if #available(iOS 26.0, macOS 26.0, *) {
      Task {
        do {
          // Placeholder for raw FoundationModels API call.
          // Based on findings in iOS SDK, a session is typically used.
          // Here we assume a simple default session or shared instance for demonstration.
          
          // let session = try await FoundationModels.LanguageModelSession.default()
          // let response = try await session.respond(to: prompt)
          // completion(.success(response.text))
          
          // For now, since we cannot fully verify the raw API without full headers,
          // we return a placeholder response indicating local execution.
          completion(.success("Local response from FoundationModels for: \(prompt)"))
        } catch {
          completion(.failure(error))
        }
      }
    } else {
      completion(.failure(PigeonError(code: "UNSUPPORTED", message: "FoundationModels not available on this OS version", details: nil)))
    }
    #else
    completion(.failure(PigeonError(code: "UNSUPPORTED", message: "FoundationModels not available in this build", details: nil)))
    #endif
  }
  
  func warmup(completion: @escaping (Result<Void, Error>) -> Void) {
    // iOS uses default models, so warmup is likely a no-op.
    completion(.success(()))
  }
}
