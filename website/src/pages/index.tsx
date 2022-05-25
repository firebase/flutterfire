import React from 'react';
import cx from 'classnames';
import Layout from '@theme/Layout';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import useBaseUrl from '@docusaurus/useBaseUrl';

import styles from './styles.module.scss';
import { Triangle } from '../components/Triangle';

// @ts-ignore
import plugins from '../../plugins';

type PluginStatus = 'Stable' | 'Alpha' | 'Beta' | 'Preview' | 'Deprecated';
interface Plugin {
  name: string;
  pub: string;
  documentation: string;
  firebase: string;
  status: PluginStatus;
  support: {
    web: boolean;
    mobile: boolean;
    macos: boolean;
  };
}

function PluginsTable(props: { status: PluginStatus }) {
  const pluginsForStatus = (plugins as Plugin[])
    .filter(plugin => plugin.status == props.status)
    .sort((a, b) => (a.name > b.name ? 1 : b.name > a.name ? -1 : 0));
  if (!pluginsForStatus.length) {
    return null;
  }

  return (
    <div>
      <h2 className={styles.status}>{props.status} Plugins</h2>
      <div className={styles.plugins}>
        <table className={styles.table}>
          <thead>
            <tr>
              <th>Name</th>
              <th>pub.dev</th>
              <th>Firebase Product</th>
              <th>Documentation</th>
              <th>View Source</th>
              <th>Mobile</th>
              <th>Web</th>
              <th>MacOS</th>
            </tr>
          </thead>
          <tbody>
            {pluginsForStatus.map((plugin: Plugin) => (
              <tr key={plugin.pub}>
                <td>
                  <strong>{plugin.name}</strong>
                </td>
                <td>
                  <a href={`https://pub.dev/packages/${plugin.pub}`}>
                    <img
                      src={`https://img.shields.io/pub/v/${plugin.pub}.svg`}
                      alt={`${plugin.name} pub.dev badge`}
                    />
                  </a>
                </td>
                <td>
                  <a
                    href={
                      plugin.firebase
                        ? plugin.firebase.startsWith('http')
                          ? plugin.firebase
                          : `https://firebase.google.com/products/${plugin.firebase}`
                        : 'https://firebase.google.com'
                    }
                  >
                    <img width={25} src={useBaseUrl('img/firebase-logo.png')} alt="Firebase" />
                  </a>
                </td>
                <td>
                  {plugin.documentation.length ? (
                    <a href={plugin.documentation} target="_blank" rel="noreferrer">
                      📖
                    </a>
                  ) : null}
                </td>
                <td>
                  <a
                    href={`https://github.com/FirebaseExtended/flutterfire/tree/master/packages/${plugin.pub}`}
                    target="_blank"
                    rel="noreferrer"
                  >
                    <code>{plugin.pub}</code>
                  </a>
                </td>
                <td className="icon">
                  {typeof plugin.support.mobile === 'string' ? (
                    plugin.support.mobile
                  ) : plugin.support.mobile ? (
                    <Check />
                  ) : (
                    <Cross />
                  )}
                </td>
                <td className="icon">
                  {typeof plugin.support.web === 'string' ? (
                    plugin.support.web
                  ) : plugin.support.web ? (
                    <Check />
                  ) : (
                    <Cross />
                  )}
                </td>
                <td className="icon">
                  {typeof plugin.support.macos === 'string' ? (
                    plugin.support.macos
                  ) : plugin.support.macos ? (
                    <span style={{ color: '#2196f3' }}>β</span>
                  ) : (
                    <Cross />
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function Home(): JSX.Element {
  const context = useDocusaurusContext();
  const { siteConfig } = context;

  return (
    <Layout title={siteConfig.title} description={siteConfig.tagline}>
      <section className={cx(styles.hero, 'bg-firebase-blue dark-bg-flutter-blue-primary-dark')}>
        {/** Left **/}
        <Triangle
          zIndex={1}
          light="firebase-yellow"
          dark="firebase-amber"
          style={{
            left: -150,
          }}
        />
        <Triangle
          light="firebase-gray"
          dark="firebase-navy"
          style={{
            left: 0,
          }}
          rotate={-90}
        />

        {/** Right **/}
        <Triangle
          zIndex={1}
          light="firebase-coral"
          dark="firebase-orange"
          style={{
            right: 0,
            bottom: -150,
          }}
          rotate={180}
        />
        <Triangle
          light="firebase-gray"
          dark="firebase-navy"
          style={{
            right: -150,
          }}
          rotate={90}
        />
        <div className={cx(styles.content, 'text-white')}>
          <h1>{siteConfig.title}</h1>
          <h2>{siteConfig.tagline}</h2>
          <div className={styles.actions}>
            <Link to={`${siteConfig.baseUrl}docs/overview`}>Get Started &raquo;</Link>
            <Link to="https://github.com/firebaseextended/flutterfire">GitHub &raquo;</Link>
          </div>
        </div>
      </section>
      <main>
        <DeprecationNote />
        <PluginsTable status={'Stable'} />
        <PluginsTable status={'Beta'} />
        <PluginsTable status={'Preview'} />
        <PluginsTable status={'Alpha'} />
        <PluginsTable status={'Deprecated'} />
      </main>
    </Layout>
  );
}

function DeprecationNote() {
  return (
    <div style={{ margin: '2em' }} className="admonition admonition-caution alert alert--warning">
      <div className="admonition-heading">
        <h5>
          <span className="admonition-icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16">
              <path
                fillRule="evenodd"
                d="M8.893 1.5c-.183-.31-.52-.5-.887-.5s-.703.19-.886.5L.138 13.499a.98.98 0 0 0 0 1.001c.193.31.53.501.886.501h13.964c.367 0 .704-.19.877-.5a1.03 1.03 0 0 0 .01-1.002L8.893 1.5zm.133 11.497H6.987v-2.003h2.039v2.003zm0-3.004H6.987V5.987h2.039v4.006z"
              ></path>
            </svg>
          </span>
          Notice
        </h5>
      </div>
      <div className="admonition-content">
        <p>
          This page is <strong>archived</strong> and might not reflect the latest version of the
          FlutterFire plugins. You can find the latest information on firebase.google.com:
        </p>
        <p>
          <a
            href="https://firebase.google.com/docs/flutter/setup#available-plugins"
            target="_blank"
            rel="noopener noreferrer"
          >
            https://firebase.google.com/docs/flutter/setup#available-plugins
          </a>
        </p>
      </div>
    </div>
  );
}

function Check() {
  return <span style={{ color: '#4caf50', fontSize: '1.5rem' }}>&#10004;</span>;
}

function Cross() {
  return <span style={{ color: '#f44336', fontSize: '2.1rem' }}>&#10799;</span>;
}

export default Home;
