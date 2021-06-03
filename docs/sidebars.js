function toReferenceAPI(plugin) {
  return {
    type: "link",
    label: "Reference API",
    href: `https://pub.dev/documentation/${plugin}/latest/`,
  };
}

function toGithubExample(plugin) {
  return {
    type: "link",
    label: "Example",
    href: `https://github.com/FirebaseExtended/flutterfire/tree/master/packages/${plugin}/${plugin}/example`,
  };
}

module.exports = {
  main: {
    "Getting Started": [
      "overview",
      "installation/android",
      "installation/ios",
      "installation/macos",
      "installation/web",
      "migration",
      "null-safety",
    ],
    Analytics: [
      "analytics/overview",
      toReferenceAPI("firebase_analytics"),
      toGithubExample("firebase_analytics"),
    ],
    "App Check": [
      "app-check/overview",
      "app-check/usage",
      toReferenceAPI("firebase_app_check"),
      toGithubExample("firebase_app_check"),
    ],
    Authentication: [
      "auth/overview",
      "auth/usage",
      "auth/social",
      "auth/phone",
      "auth/error-handling",
      toReferenceAPI("firebase_auth"),
      toGithubExample("firebase_auth"),
    ],
    "Cloud Firestore": [
      "firestore/overview",
      "firestore/usage",
      "firestore/2.0.0_migration",
      toReferenceAPI("cloud_firestore"),
      toGithubExample("cloud_firestore"),
    ],
    "Cloud Functions": [
      "functions/overview",
      "functions/usage",
      toReferenceAPI("cloud_functions"),
      toGithubExample("cloud_functions"),
    ],
    "Cloud Messaging": [
      "messaging/overview",
      "messaging/usage",
      "messaging/apple-integration",
      "messaging/permissions",
      "messaging/notifications",
      "messaging/server-integration",
      toReferenceAPI("firebase_messaging"),
      toGithubExample("firebase_messaging"),
    ],
    "Cloud Storage": [
      "storage/overview",
      "storage/usage",
      toReferenceAPI("firebase_storage"),
      toGithubExample("firebase_storage"),
    ],
    Core: [
      "core/usage",
      toReferenceAPI("firebase_core"),
      toGithubExample("firebase_core"),
    ],
    Crashlytics: [
      "crashlytics/overview",
      "crashlytics/usage",
      "crashlytics/reports",
      toReferenceAPI("firebase_crashlytics"),
      toGithubExample("firebase_crashlytics"),
    ],
    "Realtime Database": [
      "database/overview",
      toReferenceAPI("firebase_database"),
      toGithubExample("firebase_database"),
    ],
    // "Dynamic Links": ["dynamic-links/usage", toReferenceAPI("firebase_dynamic_links")],
    // "Instance ID": ["iid/usage", toReferenceAPI("firebase_in_app_messaging")],
    // "In-App Messaging": ["in-app-messaging/usage", toReferenceAPI("firebase_in_app_messaging")],
    // "ML Kit Natural Language": ["ml-language/usage"],
    // "ML Kit Vision": ["ml-vision/usage", toReferenceAPI("firebase_ml_vision")],
    "Remote Config": [
      "remote-config/overview",
      "remote-config/usage",
      toReferenceAPI("firebase_remote_config"),
      toGithubExample("firebase_remote_config"),
    ],
    "Performance Monitoring": [
      "performance/overview",
      toReferenceAPI("firebase_performance"),
      toGithubExample("firebase_performance"),
    ],
    "Testing": ["testing/testing"],
  },
};
