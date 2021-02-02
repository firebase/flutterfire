export default {
  // Plugin versions are sourced from the public pub.dev API
  // See website/plugins/source-versions.js for more information on how these are sourced & injected via Webpack
  plugins: {
    firebase_admob: PUB_FIREBASE_ADMOB,
    firebase_admob_ns: PUB_NS_FIREBASE_ADMOB,
    firebase_analytics: PUB_FIREBASE_ANALYTICS,
    firebase_analytics_ns: PUB_NS_FIREBASE_ANALYTICS,
    firebase_auth: PUB_FIREBASE_AUTH,
    firebase_auth_ns: PUB_NS_FIREBASE_AUTH,
    cloud_firestore: PUB_CLOUD_FIRESTORE,
    cloud_firestore_ns: PUB_NS_CLOUD_FIRESTORE,
    cloud_functions: PUB_CLOUD_FUNCTIONS,
    cloud_functions_ns: PUB_NS_CLOUD_FUNCTIONS,
    firebase_messaging: PUB_FIREBASE_MESSAGING,
    firebase_messaging_ns: PUB_NS_FIREBASE_MESSAGING,
    firebase_storage: PUB_FIREBASE_STORAGE,
    firebase_storage_ns: PUB_NS_FIREBASE_STORAGE,
    firebase_core: PUB_FIREBASE_CORE,
    firebase_core_ns: PUB_NS_FIREBASE_CORE,
    firebase_crashlytics: PUB_FIREBASE_CRASHLYTICS,
    firebase_crashlytics_ns: PUB_NS_FIREBASE_CRASHLYTICS,
    firebase_database: PUB_FIREBASE_DATABASE,
    firebase_database_ns: PUB_NS_FIREBASE_DATABASE,
    firebase_dynamic_links: PUB_FIREBASE_DYNAMIC_LINKS,
    firebase_dynamic_links_ns: PUB_NS_FIREBASE_DYNAMIC_LINKS,
    // firebase_iid: PUB_FIREBASE_IID,
    firebase_in_app_messaging: PUB_FIREBASE_IN_APP_MESSAGING,
    firebase_in_app_messaging_ns: PUB_NS_FIREBASE_IN_APP_MESSAGING,
    // firebase_mlkit_language: PUB_FIREBASE_ML_LANGUAGE,
    firebase_ml_vision: PUB_FIREBASE_ML_VISION,
    firebase_performance: PUB_FIREBASE_PERFORMANCE,
    firebase_performance_ns: PUB_NS_FIREBASE_PERFORMANCE,
    firebase_remote_config: PUB_FIREBASE_REMOTE_CONFIG,
    firebase_remote_config_ns: PUB_NS_FIREBASE_REMOTE_CONFIG,
    google_sign_in: "^4.4.4",
  },
  android: {
    google_services: "4.3.3", // com.google.gms:google-services
  },
  web: {
    firebase_cdn: "7.20.0", // https://firebase.google.com/docs/web/setup#expandable-8-label
  },
  external: {
    google_sign_in: "^4.5.1",
    flutter_facebook_auth: "^1.0.0"
  }
};
