const axios = require('axios');
const webpack = require('webpack');
const plugins = require('../plugins');

// Fetch the plugins latest version documentation reference from the API
function fetchPluginApiReference(plugin) {
  return axios
    .get(`https://pub.dartlang.org/documentation/${plugin}/latest/index.json`)
    .then(response => {
      if (response.headers['content-type'] === 'application/json') {
        return response.data.map(entity => ({
          ...entity,
          plugin,
        }));
      }

      return null;
    });
}

module.exports = function sourceApiReference() {
  return {
    name: '@flutterfire/source-api-reference',
    async loadContent() {
      const reference = {};
      const promises = [];

      for (let i = 0; i < plugins.length; i++) {
        const { pub } = plugins[i];
        promises.push(fetchPluginApiReference(pub));
        promises.push(fetchPluginApiReference(`${pub}_platform_interface`));
        promises.push(fetchPluginApiReference(`${pub}_web`));
      }

      const responses = await Promise.allSettled(promises);

      for (let j = 0; j < responses.length; j++) {
        const response = responses[j];
        const data = response.value;

        if (response.status === 'fulfilled' && data) {
          data.forEach(entity => {
            reference[entity.qualifiedName] = entity;
          });
        }
      }

      return JSON.stringify(reference);
    },

    async contentLoaded({ content }) {
      process.env['REFERENCE_API'] = content;
    },
    // Using webpack, create a global variable for each plugin, using the created environment variable.
    // This ensures we can access the data on both the server and client.
    // See https://webpack.js.org/plugins/define-plugin/ for more information.
    configureWebpack() {
      return {
        plugins: [
          new webpack.DefinePlugin({
            REFERENCE_API: process.env['REFERENCE_API'],
          }),
        ],
      };
    },
  };
};
