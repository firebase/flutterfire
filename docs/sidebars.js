function toReferenceAPI(plugin) {
  return {
    type: 'link',
    label: 'Reference API',
    href: `https://pub.dev/documentation/${plugin}/latest/`,
  };
}

function toGithubExample(plugin) {
  return {
    type: 'link',
    label: 'Example',
    href: `https://github.com/FirebaseExtended/flutterfire/tree/master/packages/${plugin}/${plugin}/example`,
  };
}

function toFirebase(title, path) {
  return {
    type: 'link',
    label: title,
    href: `https://firebase.google.com${path}`,
  };
}

module.exports = {
  main: {
    'Getting Started': [
      'overview',
      'cli',
      {
        type: 'category',
        label: 'Manual Installation',
        items: [
          'manual-installation',
          'manual-installation/android',
          'manual-installation/ios',
          'manual-installation/macos',
          'manual-installation/web',
        ],
      },
      'migration',
    ],
    Analytics: [
      'analytics/overview',
      'analytics/get-started',
      'analytics/events',
      'analytics/user-properties',
      toFirebase(
        "Debug Events",
        "/docs/analytics/debugview"
      ),
      'analytics/screenviews',
      'analytics/userid',
      'analytics/measure-ecommerce',
      toFirebase(
        "Measure Ad Revenue",
        "/docs/analytics/measure-ad-revenue"
      ),
      toFirebase(
        "Use in a WebView",
        "/docs/analytics/webview"
      ),
      toFirebase(
        "Extend with Cloud Functions",
        "/docs/analytics/extend-with-functions"
      ),
      toFirebase(
        "Configure Data Collection and Usage",
        "/docs/analytics/configure-data-collection"
      ),
      toFirebase(
        "Error Codes",
        "/docs/analytics/errors"
      ),
      toReferenceAPI('firebase_analytics'),
      toGithubExample('firebase_analytics'),
    ],
    'App Check': [
      'app-check/overview',
      'app-check/usage',
      toReferenceAPI('firebase_app_check'),
      toGithubExample('firebase_app_check'),
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
      "firestore/example",
    ],
    "Cloud Firestore ODM": [
      "firestore-odm/overview",
      "firestore-odm/defining-models",
      "firestore-odm/code-generation",
      "firestore-odm/references",
      "firestore-odm/subcollections",
      toReferenceAPI("cloud_firestore_odm"),
      toGithubExample("cloud_firestore_odm"),
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
      'core/usage',
      toReferenceAPI('firebase_core'),
      toGithubExample('firebase_core'),
    ],
    Crashlytics: [
      'crashlytics/overview',
      'crashlytics/usage',
      'crashlytics/reports',
      toReferenceAPI('firebase_crashlytics'),
      toGithubExample('firebase_crashlytics'),
    ],
    'Dynamic Links': [
      "dynamic-links/overview",
      "dynamic-links/android-integration",
      "dynamic-links/apple-integration",
      "dynamic-links/usage",
      toReferenceAPI("firebase_dynamic_links"),
      toGithubExample("firebase_dynamic_links"),
    ],
    "Realtime Database": [
      "database/overview",
      "database/start",
      "database/structure-data",
      "database/read-and-write",
      "database/lists-of-data",
      "database/offline-capabilities",
      toReferenceAPI("firebase_database"),
      toGithubExample("firebase_database"),
    ],
    'FlutterFire UI': [
      'ui/overview',
      'ui/widgets',
      {
        type: 'category',
        label: 'Authentication',
        items: [
          'ui/auth',
          'ui/auth/integrating-your-first-screen',
          'ui/auth/configuring-providers',
          'ui/auth/building-a-custom-ui',
          'ui/auth/localization',
          'ui/auth/theming',
          'ui/auth/navigation',
        ],
      },
      'ui/firestore',
      'ui/database',
      {
        type: 'link',
        label: 'Story Book',
        href: 'https://flutterfire-ui.web.app',
      },
    ],
    'In-App Messaging': [
      'in-app-messaging/overview',
      'in-app-messaging/usage',
      toReferenceAPI('firebase_in_app_messaging'),
      toGithubExample('firebase_in_app_messaging'),
    ],
    Installations: [
      "installations/overview",
      "installations/usage",
      toReferenceAPI("firebase_app_installations"),
      toGithubExample("firebase_app_installations"),
    ],
    "ML Model Downloader": [
      "ml-model-downloader/overview",
      "ml-model-downloader/usage",
      toReferenceAPI("firebase_in_app_messaging"),
      toGithubExample("firebase_in_app_messaging"),
    ],
    "Remote Config": [
      "remote-config/overview",
      "remote-config/usage",
      toReferenceAPI("firebase_remote_config"),
      toGithubExample("firebase_remote_config"),
    ],
    "Performance Monitoring": [
      "performance/overview",
      "performance/usage",
      toReferenceAPI("firebase_performance"),
      toGithubExample("firebase_performance"),
    ],
    "Testing": ["testing/testing"],
  },
};
