const fs = require('fs');
const webpack = require('webpack');
const plugins = require('../plugins');
const { fetchPluginVersions, fetchPluginApiReference } = require('../api');

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
        const platformName = `${pub}_platform_interface`;

        const versions = {
          [pub]: await fetchPluginVersions(pub)[0],
          [platformName]: await fetchPluginVersions(`${pub}_platform_interface`)[0],
        };

        promises.push(fetchPluginApiReference(pub, versions[pub]));
        promises.push(fetchPluginApiReference(platformName, versions[platformName]));
      }

      const responses = await Promise.allSettled(promises);

      for (let j = 0; j < responses.length; j++) {
        const response = responses[j];
        const data = response.value;

        if (response.status === 'fulfilled' && Array.isArray(data)) {
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
        `${__dirname}/../.docusaurus/@flutterfire/source-api-reference/default/reference.txt`,
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
