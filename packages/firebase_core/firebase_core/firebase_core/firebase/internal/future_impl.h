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

#ifndef FIREBASE_APP_SRC_INCLUDE_FIREBASE_INTERNAL_FUTURE_IMPL_H_
#define FIREBASE_APP_SRC_INCLUDE_FIREBASE_INTERNAL_FUTURE_IMPL_H_

/// @cond FIREBASE_APP_INTERNAL

// You shouldn't include future_impl.h directly, since its just the inline
// implementation of the functions in future.h. Include future.h instead.
#include "firebase/future.h"

#if defined(FIREBASE_USE_MOVE_OPERATORS)
#include <utility>
#endif  // defined(FIREBASE_USE_MOVE_OPERATORS)

namespace firebase {

class ReferenceCountedFutureImpl;

namespace detail {

class CompletionCallbackHandle;

/// Pure-virtual interface that APIs must implement to use Futures.
class FutureApiInterface {
 public:
  // typedef void FutureCallbackFn(const FutureBase* future);
  virtual ~FutureApiInterface();

  /// Increment the reference count on handle's asynchronous call.
  /// Called when the Future is copied.
  virtual void ReferenceFuture(const FutureHandle& handle) = 0;

  /// Decrement the reference count on handle's asynchronous call.
  /// Called when the Future is destroyed or moved.
  /// If the reference count drops to zero, the asynchronous call can be
  /// forgotten.
  virtual void ReleaseFuture(const FutureHandle& handle) = 0;

  /// Return the status of the asynchronous call.
  virtual FutureStatus GetFutureStatus(const FutureHandle& handle) const = 0;

  /// Return the API-specific error.
  /// Valid when GetFutureStatus() is kFutureStatusComplete, and undefined
  /// otherwise.
  virtual int GetFutureError(const FutureHandle& handle) const = 0;

  /// Return the API-specific error, in human-readable form, or "" if no message
  /// has been provided.
  /// Valid when GetFutureStatus() is kFutureStatusComplete, and undefined
  /// otherwise.
  virtual const char* GetFutureErrorMessage(
      const FutureHandle& handle) const = 0;

  /// Return a pointer to the completed asynchronous result, or NULL if
  /// result is still pending.
  /// After an asynchronous call is marked complete, the API should not
  /// modify the result (especially on a callback thread), since the threads
  /// owning the Future can reference the result memory via this function.
  virtual const void* GetFutureResult(const FutureHandle& handle) const = 0;

  /// Register a callback that will be called when this future's status is set
  /// to Complete. If clear_existing_callbacks is true, then the new callback
  /// will replace any existing callbacks, otherwise it will be added to the
  /// list of callbacks.
  ///
  /// The future's result data will be passed back when the callback is
  /// called, along with the user_data supplied here.
  ///
  /// After the callback has been called, if `user_data_delete_fn_ptr` is
  /// non-null, then `(*user_data_delete_fn_ptr)(user_data)` will be called.
  virtual CompletionCallbackHandle AddCompletionCallback(
      const FutureHandle& handle, FutureBase::CompletionCallback callback,
      void* user_data, void (*user_data_delete_fn)(void*),
      bool clear_existing_callbacks) = 0;

  /// Unregister a callback that was previously registered with
  /// `AddCompletionCallback`.
  virtual void RemoveCompletionCallback(
      const FutureHandle& handle, CompletionCallbackHandle callback_handle) = 0;

#if defined(FIREBASE_USE_STD_FUNCTION)
  /// Register a callback that will be called when this future's status is set
  /// to Complete.
  ///
  /// If `clear_existing_callbacks` is true, then the new callback
  /// will replace any existing callbacks, otherwise it will be added to the
  /// list of callbacks.
  ///
  /// The future's result data will be passed back when the callback is
  /// called.
  ///
  /// @return A handle that can be passed to `FutureBase::RemoveCompletion`.
  virtual CompletionCallbackHandle AddCompletionCallbackLambda(
      const FutureHandle& handle,
      std::function<void(const FutureBase&)> callback,
      bool clear_existing_callbacks) = 0;
#endif  // defined(FIREBASE_USE_STD_FUNCTION)

  /// Register this Future instance to be cleaned up.
  virtual void RegisterFutureForCleanup(FutureBase* future) = 0;

  /// Unregister this Future instance from the cleanup list.
  virtual void UnregisterFutureForCleanup(FutureBase* future) = 0;
};

inline void RegisterForCleanup(FutureApiInterface* api, FutureBase* future) {
  if (api != NULL) {  // NOLINT
    api->RegisterFutureForCleanup(future);
  }
}

inline void UnregisterForCleanup(FutureApiInterface* api, FutureBase* future) {
  if (api != NULL) {  // NOLINT
    api->UnregisterFutureForCleanup(future);
  }
}

class CompletionCallbackHandle {
 public:
  // Construct a null CompletionCallbackHandle.
  CompletionCallbackHandle()
      : callback_(nullptr),
        user_data_(nullptr),
        user_data_delete_fn_(nullptr) {}

 private:
  friend class ::firebase::FutureBase;
  friend class ::firebase::ReferenceCountedFutureImpl;
  CompletionCallbackHandle(FutureBase::CompletionCallback callback,
                           void* user_data, void (*user_data_delete_fn)(void*))
      : callback_(callback),
        user_data_(user_data),
        user_data_delete_fn_(user_data_delete_fn) {}

  FutureBase::CompletionCallback callback_;
  void* user_data_;
  void (*user_data_delete_fn_)(void*);
};

}  // namespace detail

template <class T>
void Future<T>::OnCompletion(TypedCompletionCallback callback,
                             void* user_data) const {
  FutureBase::OnCompletion(reinterpret_cast<CompletionCallback>(callback),
                           user_data);
}

#if defined(FIREBASE_USE_STD_FUNCTION)
template <class ResultType>
inline void Future<ResultType>::OnCompletion(
    std::function<void(const Future<ResultType>&)> callback) const {
  FutureBase::OnCompletion(
      *reinterpret_cast<std::function<void(const FutureBase&)>*>(&callback));
}
#endif  // defined(FIREBASE_USE_STD_FUNCTION)

#if defined(INTERNAL_EXPERIMENTAL)
template <class T>
FutureBase::CompletionCallbackHandle Future<T>::AddOnCompletion(
    TypedCompletionCallback callback, void* user_data) const {
  return FutureBase::AddOnCompletion(
      reinterpret_cast<CompletionCallback>(callback), user_data);
}

#if defined(FIREBASE_USE_STD_FUNCTION)
template <class ResultType>
inline FutureBase::CompletionCallbackHandle Future<ResultType>::AddOnCompletion(
    std::function<void(const Future<ResultType>&)> callback) const {
  return FutureBase::AddOnCompletion(
      *reinterpret_cast<std::function<void(const FutureBase&)>*>(&callback));
}
#endif  // defined(FIREBASE_USE_STD_FUNCTION)

#endif  // defined(INTERNAL_EXPERIMENTAL)

inline FutureBase::FutureBase()
    : mutex_(Mutex::Mode::kModeNonRecursive),
      api_(NULL),
      handle_(0) {}  // NOLINT

inline FutureBase::FutureBase(detail::FutureApiInterface* api,
                              const FutureHandle& handle)
    : mutex_(Mutex::Mode::kModeNonRecursive), api_(api), handle_(handle) {
  api_->ReferenceFuture(handle_);
  // Once the FutureBase has reference, we don't need extra handle reference.
  handle_.Detach();
  detail::RegisterForCleanup(api_, this);
}

inline FutureBase::~FutureBase() { Release(); }

inline FutureBase::FutureBase(const FutureBase& rhs)
    : mutex_(Mutex::Mode::kModeNonRecursive),
      api_(NULL)  // NOLINT
{                 // NOLINT
  *this = rhs;
}

inline FutureBase& FutureBase::operator=(const FutureBase& rhs) {
  Release();

  detail::FutureApiInterface* new_api;
  FutureHandle new_handle;
  {
    MutexLock lock(rhs.mutex_);
    new_api = rhs.api_;
    new_handle = rhs.handle_;
  }

  {
    MutexLock lock(mutex_);
    api_ = new_api;
    handle_ = new_handle;

    if (api_ != NULL) {  // NOLINT
      api_->ReferenceFuture(handle_);
    }
    detail::RegisterForCleanup(api_, this);
  }

  return *this;
}

#if defined(FIREBASE_USE_MOVE_OPERATORS)
inline FutureBase::FutureBase(FutureBase&& rhs) noexcept
    : mutex_(Mutex::Mode::kModeNonRecursive),
      api_(NULL)  // NOLINT
{
  *this = std::move(rhs);
}

inline FutureBase& FutureBase::operator=(FutureBase&& rhs) noexcept {
  Release();

  detail::FutureApiInterface* new_api;
  FutureHandle new_handle;
  {
    MutexLock lock(rhs.mutex_);
    detail::UnregisterForCleanup(rhs.api_, &rhs);
    new_api = rhs.api_;
    new_handle = rhs.handle_;
    rhs.api_ = NULL;  // NOLINT
  }

  MutexLock lock(mutex_);
  api_ = new_api;
  handle_ = new_handle;
  detail::RegisterForCleanup(api_, this);
  return *this;
}
#endif  // defined(FIREBASE_USE_MOVE_OPERATORS)

inline void FutureBase::Release() {
  MutexLock lock(mutex_);
  if (api_ != NULL) {  // NOLINT
    detail::UnregisterForCleanup(api_, this);
    api_->ReleaseFuture(handle_);
    api_ = NULL;  // NOLINT
  }
}

inline FutureStatus FutureBase::status() const {
  MutexLock lock(mutex_);
  return api_ == NULL ?  // NOLINT
             kFutureStatusInvalid
                      : api_->GetFutureStatus(handle_);
}

inline int FutureBase::error() const {
  MutexLock lock(mutex_);
  return api_ == NULL ? -1 : api_->GetFutureError(handle_);  // NOLINT
}

inline const char* FutureBase::error_message() const {
  MutexLock lock(mutex_);
  return api_ == NULL ? NULL : api_->GetFutureErrorMessage(handle_);  // NOLINT
}

inline const void* FutureBase::result_void() const {
  MutexLock lock(mutex_);
  return api_ == NULL ? NULL : api_->GetFutureResult(handle_);  // NOLINT
}

inline void FutureBase::OnCompletion(CompletionCallback callback,
                                     void* user_data) const {
  MutexLock lock(mutex_);
  if (api_ != NULL) {  // NOLINT
    api_->AddCompletionCallback(handle_, callback, user_data, nullptr,
                                /*clear_existing_callbacks=*/true);
  }
}

#if defined(INTERNAL_EXPERIMENTAL)
inline FutureBase::CompletionCallbackHandle FutureBase::AddOnCompletion(
    CompletionCallback callback, void* user_data) const {
  MutexLock lock(mutex_);
  if (api_ != NULL) {  // NOLINT
    return api_->AddCompletionCallback(handle_, callback, user_data, nullptr,
                                       /*clear_existing_callbacks=*/false);
  }
  return CompletionCallbackHandle();
}

inline void FutureBase::RemoveOnCompletion(
    CompletionCallbackHandle completion_handle) const {
  MutexLock lock(mutex_);
  if (api_ != NULL) {  // NOLINT
    api_->RemoveCompletionCallback(handle_, completion_handle);
  }
}
#endif  // defined(INTERNAL_EXPERIMENTAL)

#if defined(FIREBASE_USE_STD_FUNCTION)
inline void FutureBase::OnCompletion(
    std::function<void(const FutureBase&)> callback) const {
  MutexLock lock(mutex_);
  if (api_ != NULL) {  // NOLINT
    api_->AddCompletionCallbackLambda(handle_, callback,
                                      /*clear_existing_callbacks=*/true);
  }
}

#if defined(INTERNAL_EXPERIMENTAL)
inline FutureBase::CompletionCallbackHandle FutureBase::AddOnCompletion(
    std::function<void(const FutureBase&)> callback) const {
  MutexLock lock(mutex_);
  if (api_ != NULL) {  // NOLINT
    return api_->AddCompletionCallbackLambda(
        handle_, callback,
        /*clear_existing_callbacks=*/false);
  }
  return CompletionCallbackHandle();
}
#endif  // defined(INTERNAL__EXPERIMENTAL)

#endif  // defined(FIREBASE_USE_STD_FUNCTION)

// NOLINTNEXTLINE - allow namespace overridden
}  // namespace firebase

/// @endcond

#endif  // FIREBASE_APP_SRC_INCLUDE_FIREBASE_INTERNAL_FUTURE_IMPL_H_
