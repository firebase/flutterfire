package io.flutter.plugins.firebaseadmob;

class AdSize {
  final com.google.android.gms.ads.AdSize adSize;

  AdSize(int width, int height) {
    this.adSize = new com.google.android.gms.ads.AdSize(width, height);
  }
}
