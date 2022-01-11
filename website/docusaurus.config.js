const path = require('path');

module.exports = {
  title: 'FlutterFire',
  tagline: 'The official Firebase plugins for Flutter',
  url: 'https://firebase.flutter.dev',
  baseUrl: '/',
  favicon: '/favicon/favicon.ico',
  organizationName: 'FirebaseExtended',
  projectName: 'flutterfire',
  themeConfig: {
    algolia: {
      apiKey: '61eba190d4380f3db4e11d21b70e7608',
      indexName: 'flutterfire',
    },
    prism: {
      additionalLanguages: [
        'dart',
        'bash',
        'java',
        'kotlin',
        'objectivec',
        'swift',
        'groovy',
        'ruby',
        'json',
        'yaml',
      ],
    },
    navbar: {
      title: 'FlutterFire',
      logo: {
        alt: 'FlutterFire Logo',
        src: '/img/flutterfire_300x.png',
      },
      items: [
        {
          href: 'https://dartpad.dev/?id=d57c6c898dabb8c6fb41018588b8cf73',
          label: 'DartPad',
          position: 'right',
        },
        {
          href: 'https://twitter.com/flutterfiredev',
          label: 'Twitter',
          position: 'right',
        },
        {
          href: 'https://github.com/firebaseextended/flutterfire',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Docs',
          items: [
            {
              label: 'Getting Started',
              to: '/docs/overview',
            },
            {
              label: 'FlutterFire CLI',
              to: 'docs/cli',
            },
            {
              label: 'Manual Installation',
              to: 'docs/manual-installation',
            },
          ],
        },
        {
          title: 'Community',
          items: [
            {
              label: 'Stack Overflow',
              href: 'https://stackoverflow.com/questions/tagged/flutterfire',
            },
            {
              label: 'Flutter',
              href: 'https://flutter.dev/',
            },
            {
              label: 'pub.dev',
              href: 'https://pub.dev/',
            },
          ],
        },
        {
          title: 'Social',
          items: [
            {
              label: 'GitHub',
              href: 'https://github.com/FirebaseExtended/flutterfire',
            },
            {
              label: 'Twitter',
              href: 'https://twitter.com/flutterfiredev',
            },
          ],
        },
      ],
      copyright: `<div style="margin-top: 3rem"><small>Except as otherwise noted, this work is licensed under a Creative Commons Attribution 4.0 International License, and code samples are licensed under the BSD License.</small></div>`,
    },
    gtag: {
      trackingID: 'G-8PJJN5LRR7',
      anonymizeIP: true,
    },
  },
  plugins: [
    require.resolve('docusaurus-plugin-sass'),
    path.resolve(__dirname, './docusaurus-plugins/favicon-tags'),
    path.resolve(__dirname, './docusaurus-plugins/source-versions'),
    path.resolve(__dirname, './docusaurus-plugins/source-api-reference'),
    path.resolve(__dirname, './docusaurus-plugins/source-ui-widgets'),
  ],
  presets: [
    [
      '@docusaurus/preset-classic',
      {
        docs: {
          path: '../docs',
          sidebarPath: require.resolve('../docs/sidebars.js'),
          editUrl: 'https://github.com/FirebaseExtended/flutterfire/edit/master/docs/',
        },
        theme: {
          customCss: require.resolve('./src/styles.scss'),
        },
      },
    ],
  ],
};
