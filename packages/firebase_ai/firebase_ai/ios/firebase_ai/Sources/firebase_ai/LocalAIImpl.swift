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
  private static var _isModelReady: Bool?

  func isAvailable(completion: @escaping (Result<Bool, Error>) -> Void) {
    #if canImport(FoundationModels)
    if #available(iOS 26.0, macOS 26.0, *) {
      if let ready = LocalAIImpl._isModelReady {
        completion(.success(ready))
        return
      }

      let model = FoundationModels.SystemLanguageModel.default
      guard model.isAvailable else {
        LocalAIImpl._isModelReady = false
        completion(.success(false))
        return
      }

      // Perform a lightweight check to verify the model is actually loadable and functional
      Task {
        do {
          let session = FoundationModels.LanguageModelSession(model: model)
          _ = try await session.respond(to: Prompt("Hello"))
          LocalAIImpl._isModelReady = true
          completion(.success(true))
        } catch {
          LocalAIImpl._isModelReady = false
          completion(.success(false))
        }
      }
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
          let model = FoundationModels.SystemLanguageModel.default
          guard model.isAvailable else {
            completion(.failure(PigeonError(code: "UNAVAILABLE", message: "SystemLanguageModel is not available on this device", details: nil)))
            return
          }
          let session = FoundationModels.LanguageModelSession(model: model)
          let response = try await session.respond(to: Prompt(prompt))
          let content = response.rawContent
          
          let responseText: String
          if case let .string(text) = content.kind {
            responseText = text
          } else {
            responseText = content.jsonString
          }
          completion(.success(responseText))
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
          let model = FoundationModels.SystemLanguageModel.default
          guard model.isAvailable else {
            completion(.failure(PigeonError(code: "UNAVAILABLE", message: "SystemLanguageModel is not available on this device", details: nil)))
            return
          }
          let session = FoundationModels.LanguageModelSession(model: model)
          let stream = session.streamResponse(to: Prompt(prompt))
          
          for try await snapshot in stream {
            let content = snapshot.rawContent
            let chunkText: String
            if case let .string(text) = content.kind {
              chunkText = text
            } else {
              chunkText = content.jsonString
            }
            LocalAIStreamHandler.shared.sendEvent(chunkText)
          }
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
