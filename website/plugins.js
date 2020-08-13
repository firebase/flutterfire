module.exports = [
  {
    name: 'AdMob',
    pub: 'firebase_admob',
    firebase: 'admob',
    support: {
      web: false,
      mobile: true,
      macos: false,
    },
  },
  {
    name: 'Analytics',
    pub: 'firebase_analytics',
    firebase: 'analytics',
    support: {
      web: true,
      mobile: true,
      macos: false,
    },
  },
  {
    name: 'Authentication',
    pub: 'firebase_auth',
    firebase: 'auth',
    support: {
      web: true,
      mobile: true,
      macos: true,
    },
  },
  {
    name: 'Cloud Firestore',
    pub: 'cloud_firestore',
    firebase: 'firestore',
    support: {
      web: true,
      mobile: true,
      macos: true,
    },
  },
  {
    name: 'Cloud Functions',
    pub: 'cloud_functions',
    firebase: 'functions',
    support: {
      web: true,
      mobile: true,
      macos: true,
    },
  },
  {
    name: 'Cloud Messaging',
    pub: 'firebase_messaging',
    firebase: 'cloud-messaging',
    support: {
      web: false,
      mobile: true,
      macos: false,
    },
  },
  {
    name: 'Cloud Storage',
    pub: 'firebase_storage',
    firebase: 'storage',
    support: {
      web: false,
      mobile: true,
      macos: true,
    },
  },
  {
    name: 'Core',
    pub: 'firebase_core',
    firebase: '',
    support: {
      web: true,
      mobile: true,
      macos: true,
    },
  },
  {
    name: 'Crashlytics',
    pub: 'firebase_crashlytics',
    firebase: 'crashlytics',
    support: {
      web: false,
      mobile: true,
      macos: true,
    },
  },
  {
    name: 'Realtime Database',
    pub: 'firebase_database',
    firebase: 'database',
    support: {
      web: false,
      mobile: true,
      macos: true,
    },
  },
  {
    name: 'Dynamic Links',
    pub: 'firebase_dynamic_links',
    firebase: 'dynamic-links',
    support: {
      web: false,
      mobile: true,
      macos: false,
    },
  },
  // {
  //   name: 'Instance ID',
  //   pub: 'firebase_iid',
  //   firebase: '',
  //   support: {
  //     web: false,
  //     mobile: false,
  //     macos: false,
  //   },
  // },
  {
    name: 'In-App Messaging',
    pub: 'firebase_in_app_messaging',
    firebase: 'in-app-messaging',
    support: {
      web: false,
      mobile: true,
      macos: false,
    },
  },
  // {
  //   name: 'ML Kit Natural Language',
  //   pub: 'firebase_ml_language',
  //   firebase: 'ml-kit',
  //   support: {
  //     web: false,
  //     mobile: false,
  //     macos: false,
  //   },
  // },
  {
    name: 'ML Kit Vision',
    pub: 'firebase_ml_vision',
    firebase: 'ml-kit',
    support: {
      web: false,
      mobile: true,
      macos: false,
    },
  },
  {
    name: 'Performance Monitoring',
    pub: 'firebase_performance',
    firebase: 'performance',
    support: {
      web: false,
      mobile: true,
      macos: false,
    },
  },
  {
    name: 'Remote Config',
    pub: 'firebase_remote_config',
    firebase: 'remote-config',
    support: {
      web: false,
      mobile: true,
      macos: true,
    },
  },
];
