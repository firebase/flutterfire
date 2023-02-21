/*
 * Copyright 2016 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef FIREBASE_APP_SRC_INCLUDE_FIREBASE_FUTURE_H_
#define FIREBASE_APP_SRC_INCLUDE_FIREBASE_FUTURE_H_

#include <stddef.h>
#include <stdint.h>

#include <utility>

#include "firebase/internal/common.h"
#include "firebase/internal/mutex.h"

#ifdef FIREBASE_USE_STD_FUNCTION
#include <functional>
#endif

namespace firebase {

// Predeclarations.
/// @cond FIREBASE_APP_INTERNAL
namespace detail {
class FutureApiInterface;
class CompletionCallbackHandle;
}  // namespace detail
/// @endcond

/// Asynchronous call status.
enum FutureStatus {
  /// Results are ready.
  kFutureStatusComplete,

  /// Result is still being processed.
  kFutureStatusPending,

  /// No result is pending.
  /// FutureBase::Release() or move operator was called.
  kFutureStatusInvalid
};

/// Handle that the API uses to identify an asynchronous call.
/// The exact interpretation of the handle is up to the API.
typedef uintptr_t FutureHandleId;

/// Class that provides more context to FutureHandleId, which allows the
/// underlying API to track handles, perform reference counting, etc.
class FutureHandle {
 public:
  /// @cond FIREBASE_APP_INTERNAL
  FutureHandle();
  explicit FutureHandle(FutureHandleId id) : FutureHandle(id, nullptr) {}
  FutureHandle(FutureHandleId id, detail::FutureApiInterface* api);
  ~FutureHandle();

  // Copy constructor and assignment operator.
  FutureHandle(const FutureHandle& rhs);
  FutureHandle& operator=(const FutureHandle& rhs);

#if defined(FIREBASE_USE_MOVE_OPERATORS)
  // Move constructor and assignment operator.
  FutureHandle(FutureHandle&& rhs) noexcept;
  FutureHandle& operator=(FutureHandle&& rhs) noexcept;
#endif  // defined(FIREBASE_USE_MOVE_OPERATORS)

  // Comparison operators.
  bool operator!=(const FutureHandle& rhs) const { return !(*this == rhs); }
  bool operator==(const FutureHandle& rhs) const {
    // Only compare IDs, since the API is irrelevant (comparison will only occur
    // within the context of a single API anyway).
    return id() == rhs.id();
  }

  FutureHandleId id() const { return id_; }
  detail::FutureApiInterface* api() const { return api_; }

  // Detach from the FutureApi. This handle will no longer increment the
  // Future's reference count. This is mainly used for testing, so that you can
  // still look up the Future based on its handle's ID without affecting the
  // reference count yourself.
  void Detach();

  // Called by CleanupNotifier when the API is being deleted. At this point we
  // can ignore all of the reference counts since all Future data is about to be
  // deleted anyway.
  void Cleanup() { api_ = nullptr; }

 private:
  FutureHandleId id_;
  detail::FutureApiInterface* api_;
  /// @endcond
};

/// @brief Type-independent return type of asynchronous calls.
///
/// @see Future for code samples.
///
/// @cond FIREBASE_APP_INTERNAL
/// Notes:
///   - Futures have pointers back to the API, but the API does not maintain
///     pointers to its Futures. Therefore, all Futures must be destroyed
///     *before* the API is destroyed.
///   - Futures can be moved or copied. Call results are reference counted,
///     and are destroyed when they are no longer referenced by any Futures.
///   - The actual `Status`, `Error`, and `Result` values are kept inside the
///     API. This makes synchronization and data management easier.
///
/// WARNING: This class should remain POD (plain old data). It should not have
///          virtual methods. Nor should the derived Future<T> class add any
///          data. Internally, we static_cast FutureBase to Future<T>,
///          so the underlying data should remain the same.
/// @endcond
class FutureBase {
 public:
  /// Function pointer for a completion callback. When we call this, we will
  /// send the completed future, along with the user data that you specified
  /// when you set up the callback.
  typedef void (*CompletionCallback)(const FutureBase& result_data,
                                     void* user_data);

#if defined(INTERNAL_EXPERIMENTAL)
  /// Handle, representing a completion callback, that can be passed to
  /// RemoveOnCompletion.
  using CompletionCallbackHandle = detail::CompletionCallbackHandle;
#endif

  /// Construct an untyped future.
  FutureBase();

  /// @cond FIREBASE_APP_INTERNAL

  /// Construct an untyped future using the specified API and handle.
  ///
  /// @param api API class used to provide the future implementation.
  /// @param handle Handle to the future.
  FutureBase(detail::FutureApiInterface* api, const FutureHandle& handle);

  /// @endcond

  ~FutureBase();

  /// Copy constructor and operator.
  /// Increment the reference count when creating a copy of the future.
  FutureBase(const FutureBase& rhs);

  /// Copy an untyped future.
  FutureBase& operator=(const FutureBase& rhs);

#if defined(FIREBASE_USE_MOVE_OPERATORS)
  /// Move constructor and operator.
  /// Move is more efficient than copy and delete because we don't touch the
  /// reference counting in the API.
  FutureBase(FutureBase&& rhs) noexcept;

  /// Copy an untyped future.
  FutureBase& operator=(FutureBase&& rhs) noexcept;
#endif  // defined(FIREBASE_USE_MOVE_OPERATORS)

  /// Explicitly release the internal resources for a future.
  /// Future will become invalid.
  void Release();

  /// Completion status of the asynchronous call.
  FutureStatus status() const;

  /// When status() is firebase::kFutureStatusComplete, returns the API-defined
  /// error code. Otherwise, return value is undefined.
  int error() const;

  /// When status() is firebase::kFutureStatusComplete, returns the API-defined
  /// error message, as human-readable text, or an empty string if the API does
  /// not provide a human readable description of the error.
  ///
  /// @note The returned pointer is only valid for the lifetime of the Future
  ///       or its copies.
  const char* error_message() const;

  /// Result of the asynchronous call, or nullptr if the result is still
  /// pending. Cast is required since GetFutureResult() returns void*.
  const void* result_void() const;

#if defined(INTERNAL_EXPERIMENTAL)
  /// Special timeout value indicating an infinite timeout.
  ///
  /// Passing this value to FutureBase::Wait() or Future<T>::Await() will cause
  /// those methods to wait until the future is complete.
  ///
  /// @Warning It is inadvisable to use this from code that could be called
  /// from an event loop.
  static const int kWaitTimeoutInfinite;

  /// Block (i.e. suspend the current thread) until either the future is
  /// completed or the specified timeout period (in milliseconds) has elapsed.
  /// If `timeout_milliseconds` is `kWaitTimeoutInfinite`, then the timeout
  /// period is treated as being infinite, i.e. this will block until the
  /// future is completed.
  ///
  /// @return True if the future completed, or
  ///         false if the timeout period elapsed before the future completed.
  bool Wait(int timeout_milliseconds) const;
#endif  // defined(INTERNAL_EXPERIMENTAL)

  /// Register a single callback that will be called at most once, when the
  /// future is completed.
  ///
  /// If you call any OnCompletion() method more than once on the same future,
  /// only the most recent callback you registered with OnCompletion() will be
  /// called.
#if defined(INTERNAL_EXPERIMENTAL)
  /// However completions registered with AddCompletion() will still be
  /// called even if there is a subsequent call to OnCompletion().
  ///
  /// When the future completes, first the most recent callback registered with
  /// OnCompletion(), if any, will be called; then all callbacks registered with
  /// AddCompletion() will be called, in the order that they were registered.
#endif
  ///
  /// When your callback is called, the user_data that you supplied here will be
  /// passed back as the second parameter.
  ///
  /// @param[in] callback Function pointer to your callback.
  /// @param[in] user_data Optional user data. We will pass this back to your
  /// callback.
  void OnCompletion(CompletionCallback callback, void* user_data) const;

#if defined(FIREBASE_USE_STD_FUNCTION) || defined(DOXYGEN)
  /// Register a single callback that will be called at most once, when the
  /// future is completed.
  ///
  /// If you call any OnCompletion() method more than once on the same future,
  /// only the most recent callback you registered with OnCompletion() will be
  /// called.
#if defined(INTERNAL_EXPERIMENTAL)
  /// However completions registered with AddCompletion() will still be
  /// called even if there is a subsequent call to OnCompletion().
  ///
  /// When the future completes, first the most recent callback registered with
  /// OnCompletion(), if any, will be called; then all callbacks registered with
  /// AddCompletion() will be called, in the order that they were registered.
#endif
  ///
  /// @param[in] callback Function or lambda to call.
  ///
  /// @note This method is not available when using STLPort on Android, as
  /// `std::function` is not supported on STLPort.
  void OnCompletion(std::function<void(const FutureBase&)> callback) const;
#endif  // defined(FIREBASE_USE_STD_FUNCTION) || defined(DOXYGEN)

#if defined(INTERNAL_EXPERIMENTAL)
  /// Like OnCompletion, but allows adding multiple callbacks.
  ///
  /// If you call AddCompletion() more than once, all of the completions that
  /// you register will be called, when the future is completed.  However, any
  /// callbacks which were subsequently removed by calling RemoveOnCompletion
  /// will not be called.
  ///
  /// When the future completes, first the most recent callback registered with
  /// OnCompletion(), if any, will be called; then all callbacks registered with
  /// AddCompletion() will be called, in the order that they were registered.
  ///
  /// @param[in] callback Function pointer to your callback.
  /// @param[in] user_data Optional user data. We will pass this back to your
  /// callback.
  /// @return A handle that can be passed to RemoveOnCompletion.
  CompletionCallbackHandle AddOnCompletion(CompletionCallback callback,
                                           void* user_data) const;

#if defined(FIREBASE_USE_STD_FUNCTION) || defined(DOXYGEN)
  /// Like OnCompletion, but allows adding multiple callbacks.
  ///
  /// If you call AddCompletion() more than once, all of the completions that
  /// you register will be called, when the future is completed.  However, any
  /// callbacks which were subsequently removed by calling RemoveOnCompletion
  /// will not be called.
  ///
  /// When the future completes, first the most recent callback registered with
  /// OnCompletion(), if any, will be called; then all callbacks registered with
  /// AddCompletion() will be called, in the order that they were registered.
  ///
  /// @param[in] callback Function or lambda to call.
  /// @return A handle that can be passed to RemoveOnCompletion.
  ///
  /// @note This method is not available when using STLPort on Android, as
  /// `std::function` is not supported on STLPort.
  CompletionCallbackHandle AddOnCompletion(
      std::function<void(const FutureBase&)> callback) const;

#endif  // defined(FIREBASE_USE_STD_FUNCTION) || defined(DOXYGEN)

  /// Unregisters a callback that was previously registered with
  /// AddOnCompletion.
  ///
  /// @param[in] completion_handle The return value of a previous call to
  ///                              AddOnCompletion.
  void RemoveOnCompletion(CompletionCallbackHandle completion_handle) const;
#endif  // defined(INTERNAL_EXPERIMENTAL)

  /// Returns true if the two Futures reference the same result.
  bool operator==(const FutureBase& rhs) const {
    MutexLock lock(mutex_);
    return api_ == rhs.api_ && handle_ == rhs.handle_;
  }

  /// Returns true if the two Futures reference different results.
  bool operator!=(const FutureBase& rhs) const { return !operator==(rhs); }

#if defined(INTERNAL_EXPERIMENTAL)
  /// Returns the API-specific handle. Should only be called by the API.
  FutureHandle GetHandle() const {
    MutexLock lock(mutex_);
    return handle_;
  }
#endif  // defined(INTERNAL_EXPERIMENTAL)

 protected:
  /// @cond FIREBASE_APP_INTERNAL

  mutable Mutex mutex_;

  /// Backpointer to the issuing API class.
  /// Set to nullptr when Future is invalidated.
  detail::FutureApiInterface* api_;

  /// API-specified handle type.
  FutureHandle handle_;

  /// @endcond
};

/// @brief Type-specific version of FutureBase.
///
/// The Firebase C++ SDK uses this class to return results from asynchronous
/// operations. All Firebase C++ functions and method calls that operate
/// asynchronously return a Future, and provide a "LastResult" function to
/// retrieve the most recent Future result.
///
/// @code
/// // You can retrieve the Future from the function call directly, like this:
/// Future< SampleResultType > future = firebase::SampleAsyncOperation();
///
/// // Or you can retrieve it later, like this:
/// firebase::SampleAsyncOperation();
/// // [...]
/// Future< SampleResultType > future =
///     firebase::SampleAsyncOperationLastResult();
/// @endcode
///
/// When you have a Future from an asynchronous operation, it will eventually
/// complete. Once it is complete, you can check for errors (a nonzero error()
/// means an error occurred) and get the result data if no error occurred by
/// calling result().
///
/// There are two ways to find out that a Future has completed. You can poll
/// its status(), or set an OnCompletion() callback:
///
/// @code
/// // Check whether the status is kFutureStatusComplete.
/// if (future.status() == firebase::kFutureStatusComplete) {
///   if (future.error() == 0) {
///     DoSomethingWithResultData(future.result());
///   }
///   else {
///     LogMessage("Error %d: %s", future.error(), future.error_message());
///   }
/// }
///
/// // Or, set an OnCompletion callback, which accepts a C++11 lambda or
/// // function pointer. You can pass your own user data to the callback. In
/// // most cases, the callback will be running in a different thread, so take
/// // care to make sure your code is thread-safe.
/// future.OnCompletion([](const Future< SampleResultType >& completed_future,
///                        void* user_data) {
///   // We are probably in a different thread right now.
///   if (completed_future.error() == 0) {
///     DoSomethingWithResultData(completed_future.result());
///   }
///   else {
///     LogMessage("Error %d: %s",
///                completed_future.error(),
///                completed_future.error_message());
///   }
/// }, user_data);
/// @endcode
///
/// @tparam ResultType The type of this Future's result.
//
// WARNING: This class should not have virtual methods or data members.
//          See the warning in FutureBase for further details.
template <typename ResultType>
class Future : public FutureBase {
 public:
  /// Function pointer for a completion callback. When we call this, we will
  /// send the completed future, along with the user data that you specified
  /// when you set up the callback.
  typedef void (*TypedCompletionCallback)(const Future<ResultType>& result_data,
                                          void* user_data);

  /// Construct a future.
  Future() {}

  /// @cond FIREBASE_APP_INTERNAL

  /// Construct a future using the specified API and handle.
  ///
  /// @param api API class used to provide the future implementation.
  /// @param handle Handle to the future.
  Future(detail::FutureApiInterface* api, const FutureHandle& handle)
      : FutureBase(api, handle) {}

  /// @endcond

  /// Result of the asynchronous call, or nullptr if the result is still
  /// pending. Allows the API to provide a type-specific interface.
  ///
  const ResultType* result() const {
    return static_cast<const ResultType*>(result_void());
  }

#if defined(INTERNAL_EXPERIMENTAL)
  /// Waits (blocks) until either the future is completed, or the specified
  /// timeout period (in milliseconds) has elapsed, then returns the result of
  /// the asynchronous call.
  ///
  /// This is a convenience method that calls Wait() and then returns result().
  ///
  /// If `timeout_milliseconds` is `kWaitTimeoutInfinite`, then the timeout
  /// period is treated as being infinite, i.e. this will block until the
  /// future is completed.
  const ResultType* Await(int timeout_milliseconds) const {
    Wait(timeout_milliseconds);
    return result();
  }
#endif  // defined(INTERNAL_EXPERIMENTAL)

  /// Register a single callback that will be called at most once, when the
  /// future is completed.
  ///
  /// If you call any OnCompletion() method more than once on the same future,
  /// only the most recent callback you registered will be called.
  ///
  /// When your callback is called, the user_data that you supplied here will be
  /// passed back as the second parameter.
  ///
  /// @param[in] callback Function pointer to your callback.
  /// @param[in] user_data Optional user data. We will pass this back to your
  /// callback.
  ///
  /// @note This is the same callback as FutureBase::OnCompletion(), so you
  /// can't expect to set both and have both run; again, only the most recently
  /// registered one will run.
  inline void OnCompletion(TypedCompletionCallback callback,
                           void* user_data) const;

#if defined(FIREBASE_USE_STD_FUNCTION) || defined(DOXYGEN)
  /// Register a single callback that will be called at most once, when the
  /// future is completed.
  ///
  /// If you call any OnCompletion() method more than once on the same future,
  /// only the most recent callback you registered will be called.
  ///
  /// @param[in] callback Function or lambda to call.
  ///
  /// @note This method is not available when using STLPort on Android, as
  /// `std::function` is not supported on STLPort.
  ///
  /// @note This is the same callback as FutureBase::OnCompletion(), so you
  /// can't expect to set both and have both run; again, only the most recently
  /// registered one will run.
  inline void OnCompletion(
      std::function<void(const Future<ResultType>&)> callback) const;
#endif  // defined(FIREBASE_USE_STD_FUNCTION) || defined(DOXYGEN)

#if defined(INTERNAL_EXPERIMENTAL)
  /// Like OnCompletion, but allows adding multiple callbacks.
  ///
  /// If you call AddCompletion() more than once, all of the completions that
  /// you register will be called, when the future is completed.  However, any
  /// callbacks which were subsequently removed by calling RemoveOnCompletion
  /// will not be called.
  ///
  /// When the future completes, first the most recent callback registered with
  /// OnCompletion(), if any, will be called; then all callbacks registered with
  /// AddCompletion() will be called, in the order that they were registered.
  ///
  /// @param[in] callback Function pointer to your callback.
  /// @param[in] user_data Optional user data. We will pass this back to your
  /// callback.
  /// @return A handle that can be passed to RemoveOnCompletion.
  inline CompletionCallbackHandle AddOnCompletion(
      TypedCompletionCallback callback, void* user_data) const;

#if defined(FIREBASE_USE_STD_FUNCTION) || defined(DOXYGEN)
  /// Like OnCompletion, but allows adding multiple callbacks.
  ///
  /// If you call AddCompletion() more than once, all of the completions that
  /// you register will be called, when the future is completed.  However, any
  /// callbacks which were subsequently removed by calling RemoveOnCompletion
  /// will not be called.
  ///
  /// When the future completes, first the most recent callback registered with
  /// OnCompletion(), if any, will be called; then all callbacks registered with
  /// AddCompletion() will be called, in the order that they were registered.
  ///
  /// @param[in] callback Function or lambda to call.
  /// @return A handle that can be passed to RemoveOnCompletion.
  ///
  /// @note This method is not available when using STLPort on Android, as
  /// `std::function` is not supported on STLPort.
  inline CompletionCallbackHandle AddOnCompletion(
      std::function<void(const Future<ResultType>&)> callback) const;
#endif  // defined(FIREBASE_USE_STD_FUNCTION) || defined(DOXYGEN)
#endif  // defined(INTERNAL_EXPERIMENTAL)
};

}  // namespace firebase

// Include the inline implementation.
#include "firebase/internal/future_impl.h"

#endif  // FIREBASE_APP_SRC_INCLUDE_FIREBASE_FUTURE_H_
