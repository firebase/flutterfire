module.exports = {
  title: 'FlutterFire',
  tagline: 'The official Firebase plugins for Flutter',
  url: 'http://firebaseextended.github.io/flutterfire',
  baseUrl: '/',
  favicon: 'img/favicon.ico',
  organizationName: 'FirebaseExtended',
  projectName: 'flutterfire',
  themeConfig: {
    navbar: {
      title: 'FlutterFire',
      links: [
        {
          to: 'docs/overview',
          activeBasePath: 'docs',
          label: 'Docs',
          position: 'left',
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
              label: 'Overview',
              to: 'docs/',
            },
            {
              label: 'Android Installation',
              to: 'docs/install/android',
            },
            {
              label: 'iOS Installation',
              to: 'docs/install/ios',
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
          ],
        },
        {
          title: 'Social',
          items: [
            {
              label: 'GitHub',
              href: 'https://github.com/FirebaseExtended/flutterfire',
            },
          ],
        },
      ],
      copyright: `<div style="margin-top: 3rem"><small>Except as otherwise noted, this work is licensed under a Creative Commons Attribution 4.0 International License, and code samples are licensed under the BSD License.</small></div>`,
    },
  },
  plugins: [
    'docusaurus-plugin-sass'
  ],
  presets: [
    [
      '@docusaurus/preset-classic',
      {
        docs: {
          path: '../docs',
          sidebarPath: require.resolve('../docs/sidebars.js'),
          editUrl:
            'https://github.com/FirebaseExtended/flutterfire/edit/next/docs/',
        },
        theme: {
          customCss: require.resolve('./src/styles.scss'),
        },
      },
    ],
  ],
};
