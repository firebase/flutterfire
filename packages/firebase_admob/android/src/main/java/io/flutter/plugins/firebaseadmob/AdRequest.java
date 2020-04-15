package io.flutter.plugins.firebaseadmob;

class AdRequest {
  final com.google.android.gms.ads.AdRequest request;

  AdRequest() {
    this.request = new com.google.android.gms.ads.AdRequest.Builder().build();
  }
}
