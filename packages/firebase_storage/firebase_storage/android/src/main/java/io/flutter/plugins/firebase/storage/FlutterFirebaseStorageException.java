package io.flutter.plugins.firebase.storage;

import androidx.annotation.NonNull;
import com.google.firebase.storage.StorageException;

class FlutterFirebaseStorageException extends Exception {
  private int code;

  FlutterFirebaseStorageException(@NonNull Exception nativeException, Throwable cause) {
    super(nativeException.getMessage(), cause);

    if (nativeException instanceof StorageException) {
      code = ((StorageException) nativeException).getErrorCode();
    }
  }

  public String getCode() {
    switch (code) {
      case StorageException.ERROR_OBJECT_NOT_FOUND:
        return "object-not-found";
      case StorageException.ERROR_BUCKET_NOT_FOUND:
        return "bucket-not-found";
      case StorageException.ERROR_PROJECT_NOT_FOUND:
        return "project-not-found";
      case StorageException.ERROR_QUOTA_EXCEEDED:
        return "quota-exceeded";
      case StorageException.ERROR_NOT_AUTHENTICATED:
        return "unauthenticated";
      case StorageException.ERROR_NOT_AUTHORIZED:
        return "unauthorized";
      case StorageException.ERROR_RETRY_LIMIT_EXCEEDED:
        return "retry-limit-exceeded";
      case StorageException.ERROR_INVALID_CHECKSUM:
        return "invalid-checksum";
      case StorageException.ERROR_CANCELED:
        return "canceled";
      case StorageException.ERROR_UNKNOWN:
      default:
        {
          return "unknown";
        }
    }
  }

  @Override
  public String getMessage() {
    switch (code) {
      case StorageException.ERROR_OBJECT_NOT_FOUND:
        return "No object exists at the desired reference.";
      case StorageException.ERROR_BUCKET_NOT_FOUND:
        return "No bucket is configured for Firebase Storage.";
      case StorageException.ERROR_PROJECT_NOT_FOUND:
        return "No project is configured for Firebase Storage.";
      case StorageException.ERROR_QUOTA_EXCEEDED:
        return "Quota on your Firebase Storage bucket has been exceeded.";
      case StorageException.ERROR_NOT_AUTHENTICATED:
        return "User is unauthenticated. Authenticate and try again.";
      case StorageException.ERROR_NOT_AUTHORIZED:
        return "User is not authorized to perform the desired action.";
      case StorageException.ERROR_RETRY_LIMIT_EXCEEDED:
        return "The maximum time limit on an operation (upload, download, delete, etc.) has been exceeded.";
      case StorageException.ERROR_INVALID_CHECKSUM:
        return "File on the client does not match the checksum of the file received by the server.";
      case StorageException.ERROR_CANCELED:
        return "User cancelled the operation.";
      case StorageException.ERROR_UNKNOWN:
      default:
        {
          return "An unknown error occurred";
        }
    }
  }
}
