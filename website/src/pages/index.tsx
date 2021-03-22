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

interface Plugin {
  name: string;
  pub: string;
  documentation: string;
  firebase: string;
  support: {
    web: boolean;
    mobile: boolean;
    macos: boolean;
  };
}

function Home() {
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
        <div className={styles.plugins}>
          <table className={styles.table}>
            <thead>
              <tr>
                <th>Plugin</th>
                <th>Version</th>
                <th>pub.dev</th>
                <th>Firebase</th>
                <th>Documentation</th>
                <th>View Source</th>
                <th>Mobile</th>
                <th>Web</th>
                <th>MacOS</th>
              </tr>
            </thead>
            <tbody>
              {plugins.map((plugin: Plugin) => (
                <tr key={plugin.pub}>
                  <td>
                    <strong>{plugin.name}</strong>
                  </td>
                  <td style={{ minWidth: 150 }}>
                    <img
                      src={`https://img.shields.io/pub/v/${plugin.pub}.svg`}
                      alt={`${plugin.name} Badge`}
                    />
                  </td>
                  <td>
                    <a href={`https://pub.dev/packages/${plugin.pub}`}>
                      <img width={25} src={useBaseUrl('img/dart-logo.png')} alt="Pub" />
                    </a>
                  </td>
                  <td>
                    <a
                      href={
                        plugin.firebase
                          ? `https://firebase.google.com/products/${plugin.firebase}`
                          : 'https://firebase.google.com'
                      }
                    >
                      <img width={25} src={useBaseUrl('img/firebase-logo.png')} alt="Firebase" />
                    </a>
                  </td>
                  <td>
                    {plugin.documentation.length ? (
                      <a href={plugin.documentation} target="_blank">
                        📖
                      </a>
                    ) : null}
                  </td>
                  <td>
                    <a
                      href={`https://github.com/FirebaseExtended/flutterfire/tree/master/packages/${plugin.pub}`}
                      target="_blank"
                    >
                      <code>{plugin.pub}</code>
                    </a>
                  </td>
                  <td className="icon">{plugin.support.mobile ? <Check /> : <Cross />}</td>
                  <td>{plugin.support.web ? <Check /> : <Cross />}</td>
                  <td>{plugin.support.macos ? <Check /> : <Cross />}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </main>
    </Layout>
  );
}

function Check() {
  return <span style={{ color: '#4caf50', fontSize: '1.5rem' }}>&#10004;</span>;
}

function Cross() {
  return <span style={{ color: '#f44336', fontSize: '2.1rem' }}>&#10799;</span>;
}

export default Home;
