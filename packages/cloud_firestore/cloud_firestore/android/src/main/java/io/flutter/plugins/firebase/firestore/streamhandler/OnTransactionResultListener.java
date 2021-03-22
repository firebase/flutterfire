package io.flutter.plugins.firebase.firestore.streamhandler;

import java.util.Map;

/** callback when a transaction result has been computed. */
public interface OnTransactionResultListener {
  void receiveTransactionResponse(Map<String, Object> result);
}
