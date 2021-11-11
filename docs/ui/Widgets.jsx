import React, { useState } from 'react';
import Link from '@docusaurus/Link';

export const widgets = [
  {
    id: 'SignInView',
    description: 'Sign in form',
    plugin: 'auth',
  },
  {
    id: 'SignInScreen',
    description: 'Sign in form',
    plugin: 'auth',
  },
  {
    id: 'FirestoreListView',
    description:
      'A ListView to render infinite data using a Firestore Collection.',
    plugin: 'firestore',
  },
  {
    id: 'GoogleSignInButton',
    description: 'A standalone styled button to trigger Google Sign In.',
    plugin: 'auth',
  },
];

function Card({ id, description, plugin }) {
  return (
    <Link
      to={`/docs/ui/widgets/${id}`}
      style={{
        textDecoration: 'inherit',
        color: 'inherit',
        display: 'flex',
        height: '100%',
        flexDirection: 'column',
        backgroundColor: '#fff',
        borderRadius: '0.5rem',
        boxShadow:
          'rgba(0, 0, 0, 0.05) 0px 6px 24px 0px, rgba(0, 0, 0, 0.08) 0px 0px 0px 1px',
        overflow: 'hidden',
      }}
    >
      <div
        style={{
          position: 'relative',
          height: 150,
          background: `url(${
            require(`../_assets/widgets/${id}.jpg`).default
          }) no-repeat center center`,
          backgroundSize: 'contain',
        }}
      />
      <div
        style={{
          flexGrow: 1,
          backgroundColor: '#F9FAFB',
          padding: '1rem',
          borderTop: '1px solid rgba(0, 0, 0, 0.08)',
        }}
      >
        <span
          style={{
            backgroundColor:
              plugin === 'auth'
                ? '#2196f3'
                : plugin === 'firestore'
                ? '#ff9800'
                : '#4caf50',
            fontSize: '.85rem',
            padding: '.2rem .6rem',
            borderRadius: '999px',
            color: '#fff',
          }}
        >
          {plugin}
        </span>
        <h4 style={{ marginTop: '.5rem' }}>{id}</h4>
        <p
          style={{
            margin: 0,
            fontSize: '.9rem',
          }}
        >
          {description}
        </p>
      </div>
    </Link>
  );
}

export function Catalog() {
  const params = new URLSearchParams(window.location.search);
  const [query, setQuery] = useState(params.get('query') || '');
  const [plugin, setPlugin] = useState(params.get('plugin') || 'all');

  function updateSearchParams() {
    const path =
      window.location.protocol +
      '//' +
      window.location.host +
      window.location.pathname +
      '?' +
      params.toString();
    window.history.pushState({ path }, '', path);
  }

  let filtered = widgets;

  if (query) {
    filtered = filtered.filter((widget) => {
      return (
        widget.id.toLowerCase().includes(query.toLowerCase()) ||
        widget.description.toLowerCase().includes(query.toLowerCase())
      );
    });
  }

  if (plugin !== 'all') {
    filtered = filtered.filter((widget) => widget.plugin === plugin);
  }

  return (
    <section>
      <div
        style={{
          marginBottom: '1rem',
          display: 'flex',
          gap: '1rem',
          alignItems: 'center',
        }}
      >
        <input
          name="search"
          value={query}
          placeholder="Search widgets..."
          onChange={(e) => {
            const query = e.target.value;
            setQuery(query);
            params.set('query', query);
            updateSearchParams();
          }}
          style={{
            width: 300,
            padding: '.4rem .6rem',
          }}
        />
        <select
          name="plugin"
          style={{ width: 150, padding: '.4rem .6rem' }}
          value={plugin}
          onChange={(e) => {
            const plugin = e.target.value;
            setPlugin(plugin);
            params.set('plugin', plugin);
            updateSearchParams();
          }}
        >
          <option value="all">All Plugins</option>
          <option value="auth">Auth</option>
          <option value="firestore">Firestore</option>
        </select>
      </div>
      <div className="grid grid-3">
        {filtered.map(({ id, description, plugin }) => (
          <div key={id}>
            <Card id={id} description={description} plugin={plugin} />
          </div>
        ))}
      </div>
    </section>
  );
}
