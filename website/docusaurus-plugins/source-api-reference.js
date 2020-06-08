const axios = require('axios');
const chunk = require('fast-chunk-string');
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

    async contentLoaded({ content, actions }) {
      // Windows Hack
      const chunks = chunk(content, {size: 30000});
      let str = `REFERENCE_API_CHUNKS=${chunks.length}\n`;
      chunks.forEach((chunk, index) => {
        str += `REFERENCE_API_CHUNK_${index}='${chunk}'`;
        if (index < chunks.length - 1) str += '\n';
      });

      require('dotenv').config({
        path: await actions.createData('reference.env', str),
        debug: process.env.NODE_ENV !== 'production',
      });
    },
    // Using webpack, create a global variable for each plugin, using the created environment variable.
    // This ensures we can access the data on both the server and client.
    // See https://webpack.js.org/plugins/define-plugin/ for more information.
    configureWebpack() {
      const chunks = process.env[`REFERENCE_API_CHUNKS`];
      let str = ``;

      for (let i = 0; i < chunks; i++) {
        str += process.env[`REFERENCE_API_CHUNK_${i}`];
      }

      return {
        plugins: [
          new webpack.DefinePlugin({
            REFERENCE_API: str,
          }),
        ],
      };
    },
  };
};
