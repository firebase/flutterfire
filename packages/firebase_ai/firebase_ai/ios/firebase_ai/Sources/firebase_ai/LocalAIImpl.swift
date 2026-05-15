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
    completion(.success(()))
  }
  
  func startStreaming(prompt: String, completion: @escaping (Result<Void, Error>) -> Void) {
    #if canImport(FoundationModels)
    if #available(iOS 26.0, macOS 26.0, *) {
      Task {
        do {
          // Simulate streaming by sending chunks to the shared stream handler.
          LocalAIStreamHandler.shared.sendEvent("Local chunk 1 for: \(prompt)")
          LocalAIStreamHandler.shared.sendEvent("Local chunk 2 for: \(prompt)")
          LocalAIStreamHandler.shared.closeStream()
          completion(.success(()))
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
}
