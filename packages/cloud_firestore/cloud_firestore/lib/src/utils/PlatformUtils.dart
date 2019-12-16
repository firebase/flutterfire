part of cloud_firestore;

class PlatformUtils {
  static platform.Source _toPlatformSource(Source platformSource) {
    switch(platformSource) {
      case Source.cache:
        return platform.Source.cache;
      case Source.server:
        return platform.Source.server;
      case Source.serverAndCache:
        return platform.Source.serverAndCache;
      default:
        throw ArgumentError("Invalid source value");

    }
  }
}