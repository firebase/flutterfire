const fs = require('fs');
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
    // Query the pub api to generate references to all exposed
    // plugin API declarations
    async loadContent() {
      const reference = {};
      const promises = [];

      for (let i = 0; i < plugins.length; i++) {
        const { pub } = plugins[i];
        promises.push(fetchPluginApiReference(pub));
        promises.push(fetchPluginApiReference(`${pub}_platform_interface`));
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

    // Store the string locally
    async contentLoaded({ content, actions }) {
      await actions.createData('reference.txt', content);
    },

    // Expose the stored string via webpack so it's available on both
    // server and client environments
    configureWebpack() {
      const reference = fs.readFileSync(
        `${__dirname}/../.docusaurus/@flutterfire/source-api-reference/reference.txt`,
        'utf8',
      );

      return {
        plugins: [
          new webpack.DefinePlugin({
            REFERENCE_API: reference,
          }),
        ],
      };
    },
  };
};
