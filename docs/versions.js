export default {
  // TODO(ehesp): Update versions to latest pre-releases
  plugins: {
    firebase_admob: '0.9.3+2',
    firebase_analytics: '5.0.11',
    firebase_auth: '0.16.0',
    cloud_firestore: '0.13.5',
    cloud_functions: ' 0.4.2+3',
    firebase_messaging: '6.0.13',
    firebase_storage: '3.1.5',
    firebase_core: '1.0.0-1.0.pre',
    firebase_crashlytics: '0.1.3+3',
    firebase_database: '3.1.5',
    firebase_dynamic_links: '0.5.0+11',
    firebase_iid: 'n/a',
    firebase_in_app_messaging: '0.1.1+3',
    firebase_mlkit_language: '1.1.2',
    firebase_ml_vision: '0.9.3+8',
    firebase_performance: '0.3.1+8',
    firebase_remote_config: '0.3.0+3',
    google_sign_in: '^4.4.4'
  },
  android: {
    google_services: '4.3.3', // com.google.gms:google-services
  },
  web: {
    firebase_cdn: '7.14.3', // https://firebase.google.com/docs/web/setup#expandable-8-label
  }
}
