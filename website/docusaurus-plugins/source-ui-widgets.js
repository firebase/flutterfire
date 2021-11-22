const { default: axios } = require('axios');

module.exports = function sourceUiWidgets() {
  return {
    name: '@flutterfire/source-ui-widgets',
    async loadContent() {
      const url = 'https://pub.dev/documentation/firebase_ui/latest/categories.json';

      try {
        const res = await axios.get(url);
        return res.data;
      } catch (e) {
        console.log(`Failed to load categories.json for firebase_ui: `, e.message);
        return [];
      }
    },
    async contentLoaded({ content, actions }) {
      actions.setGlobalData(content);
    },
  };
};
