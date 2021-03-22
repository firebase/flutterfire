module.exports = function generateFaviconTags() {
  return {
    name: '@flutterfire/favicon-tags',
    injectHtmlTags() {
      return {
        headTags: [
          {
            tagName: 'link',
            attributes: {
              rel: 'apple-touch-icon',
              sizes: '180x180',
              href: '/favicon/apple-touch-icon.png',
            },
          },
          {
            tagName: 'link',
            attributes: {
              rel: 'icon',
              type: 'image/png',
              sizes: '32x32',
              href: '/favicon/favicon-32x32.png',
            },
          },
          {
            tagName: 'link',
            attributes: {
              rel: 'icon',
              type: 'image/png',
              sizes: '16x16',
              href: '/favicon/favicon-16x16.png',
            },
          },
          {
            tagName: 'link',
            attributes: {
              rel: 'manifest',
              href: '/favicon/site.webmanifest',
            },
          },
          {
            tagName: 'link',
            attributes: {
              rel: 'mask-icon',
              href: '/favicon/safari-pinned-tab.svg',
              color: '#5bbad5',
            },
          },
          {
            tagName: 'meta',
            attributes: {
              name: 'msapplication-TileColor',
              content: '#da532c',
            },
          },
          {
            tagName: 'meta',
            attributes: {
              name: 'theme-color',
              content: '#0175c2',
            },
          },
        ],
      };
    },
  };
};
