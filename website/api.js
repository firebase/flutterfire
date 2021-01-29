const axios = require('axios');

// Fetch the plugins latest version from the pub API
async function fetchPluginVersions(plugin) {
  try {
    const response = await axios.get(`https://pub.dev/packages/${plugin}.json`);
    const versions = response.data.versions;

    if (!Array.isArray(versions)) {
      return '';
    }

    const nnsList = versions.filter(v => !v.includes('nullsafety'));
    const nsList = versions.filter(v => v.includes('nullsafety'));

    return [nnsList[nnsList.length - 1], nsList[nsList.length - 1]];
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
