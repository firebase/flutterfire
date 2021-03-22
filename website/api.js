const axios = require('axios');
const compare = require('compare-versions');

const BASE_NS_VERSIONS = {
  cloud_firestore: '1.0.0',
  cloud_firestore_platform_interface: '4.0.0',
  cloud_firestore_web: '1.0.0',
  cloud_functions: '1.0.0',
  cloud_functions_platform_interface: '5.0.0',
  cloud_functions_web: '4.0.0',
  firebase_analytics: '7.1.0',
  firebase_analytics_platform_interface: '1.1.0',
  firebase_analytics_web: '0.2.0',
  firebase_auth: '1.0.0',
  firebase_auth_platform_interface: '4.0.0',
  firebase_auth_web: '1.0.0',
  firebase_core: '1.0.0',
  firebase_core_platform_interface: '4.0.0',
  firebase_core_web: '1.0.0',
  firebase_crashlytics: '1.0.0',
  firebase_crashlytics_platform_interface: '2.0.0',
  firebase_database: '6.1.0',
  firebase_dynamic_links: '0.8.0',
  firebase_in_app_messaging: '0.4.0',
  firebase_messaging: '9.0.0',
  firebase_messaging_platform_interface: '2.0.0',
  firebase_messaging_web: '1.0.0',
  firebase_ml_custom: '0.2.0',
  firebase_ml_vision: '0.11.0',
  firebase_performance: '0.6.0',
  firebase_remote_config: '0.9.0-dev.0',
  firebase_remote_config_platform_interface: '0.2.0-dev.0',
  firebase_storage: '8.0.0',
  firebase_storage_platform_interface: '2.0.0',
  firebase_storage_web: '1.0.0',
};

// Fetch the plugins latest version from the pub API
async function fetchPluginVersions(plugin) {
  try {
    const response = await axios.get(`https://pub.dev/packages/${plugin}.json`);
    const versions = response.data.versions;

    if (!Array.isArray(versions)) {
      return ['', ''];
    }

    // Sort the versions and skip any with "nullsafety".
    const sorted = versions.filter(v => !v.includes('nullsafety')).sort(compare);
    const nsIndex = sorted.indexOf(BASE_NS_VERSIONS[plugin]);

    // If no NS version is found..
    if (nsIndex === -1) {
      return [sorted[sorted.length - 1], ''];
    }

    const nsVersions = sorted.slice(nsIndex);

    // If no NNS version is found..
    if (nsIndex === 0) {
      return ['', nsVersions[0]];
    }
    
    return [sorted[nsIndex - 1], nsVersions[nsVersions.length - 1]];
  } catch (e) {
    console.log(`Failed to load version for plugin "${plugin}".`);
    return ['', ''];
  }
}

// Fetch the plugins latest version documentation reference from the API
function fetchPluginApiReference(plugin, version = 'latest') {
  return axios
    .get(`https://pub.dev/documentation/${plugin}/${version}/index.json`, {
      maxRedirects: 0,
    })
    .then(response => {
      if (response.headers['content-type'] === 'application/json') {
        return response.data.map(entity => ({
          ...entity,
          version,
          plugin,
        }));
      }

      return null;
    })
    .catch(() => {
      return null;
    });
}

module.exports = {
  fetchPluginVersions,
  fetchPluginApiReference,
};
