function toReferenceAPI(plugin) {
  return {
    type: "link",
    label: "Reference API",
    href: `https://pub.dev/documentation/${plugin}/latest/`,
  };
}

module.exports = {
  main: {
    "Getting Started": [
      "overview",
      "installation/android",
      "installation/ios",
      "installation/web",
    ],
    AdMob: ["admob/usage", toReferenceAPI("firebase_admob")],
    Analytics: ["analytics/usage"],
    Authentication: ["auth/usage"],
    "Cloud Firestore": ["firestore/usage"],
    "Cloud Functions": ["functions/usage"],
    "Cloud Messaging": ["messaging/usage"],
    "Cloud Storage": ["storage/usage"],
    Core: ["core/usage"],
    Crashlytics: ["crashlytics/usage"],
    "Realtime Database": ["database/usage"],
    "Dynamic Links": ["dynamic-links/usage"],
    "Instance ID": ["iid/usage"],
    "In-AppMessaging": ["in-app-messaging/usage"],
    "ML Kit Natural Language": ["ml-language/usage"],
    "ML Kit Vision": ["ml-vision/usage"],
    "Remote Config": ["remote-config/usage"],
    "Performance Monitoring": ["performance/usage"],
  },
};
